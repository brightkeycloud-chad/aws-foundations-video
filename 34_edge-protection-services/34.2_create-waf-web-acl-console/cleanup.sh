#!/bin/bash

# Cleanup script for Demo 34.2: Create WAF Web ACL
# This script removes the Web ACL created during the demonstration
# Handles Web ACLs with Bot Control and other managed rule groups

set -e

echo "🧹 Starting cleanup for WAF Web ACL demo..."

# Set region for CloudFront WAF resources
export AWS_DEFAULT_REGION=us-east-1

# Web ACL name from the demo
WEB_ACL_NAME="demo-web-acl"

echo "📋 Looking for Web ACL: $WEB_ACL_NAME"

# Get the Web ACL ID
WEB_ACL_ID=$(aws wafv2 list-web-acls --scope CLOUDFRONT --query "WebACLs[?Name=='$WEB_ACL_NAME'].Id" --output text 2>/dev/null || echo "")

if [ -z "$WEB_ACL_ID" ] || [ "$WEB_ACL_ID" = "None" ]; then
    echo "ℹ️  No Web ACL found with name '$WEB_ACL_NAME'. Nothing to clean up."
    exit 0
fi

echo "🔍 Found Web ACL ID: $WEB_ACL_ID"

# Get the lock token
LOCK_TOKEN=$(aws wafv2 get-web-acl --scope CLOUDFRONT --id "$WEB_ACL_ID" --name "$WEB_ACL_NAME" --query "LockToken" --output text)

# Get Web ACL details to show what's being deleted
echo "📊 Retrieving Web ACL configuration..."
WEB_ACL_DETAILS=$(aws wafv2 get-web-acl --scope CLOUDFRONT --id "$WEB_ACL_ID" --name "$WEB_ACL_NAME" --query "WebACL" 2>/dev/null || echo "")

if [ ! -z "$WEB_ACL_DETAILS" ]; then
    echo "📋 Web ACL contains the following rules:"
    echo "$WEB_ACL_DETAILS" | jq -r '.Rules[]? | "  - \(.Name) (Priority: \(.Priority))"' 2>/dev/null || echo "  - Unable to parse rule details"
    
    # Check for Bot Control specifically
    BOT_CONTROL_RULES=$(echo "$WEB_ACL_DETAILS" | jq -r '.Rules[]? | select(.Statement.ManagedRuleGroupStatement.Name? == "AWSManagedRulesBotControlRuleSet") | .Name' 2>/dev/null || echo "")
    if [ ! -z "$BOT_CONTROL_RULES" ]; then
        echo "🤖 Bot Control rule group detected: $BOT_CONTROL_RULES"
    fi
fi

# Check if Web ACL is associated with any resources
echo "🔗 Checking for associated resources..."
WEB_ACL_ARN="arn:aws:wafv2:us-east-1:$(aws sts get-caller-identity --query Account --output text):global/webacl/$WEB_ACL_NAME/$WEB_ACL_ID"
ASSOCIATED_RESOURCES=$(aws wafv2 list-resources-for-web-acl --web-acl-arn "$WEB_ACL_ARN" --resource-type CLOUDFRONT --query "ResourceArns" --output text 2>/dev/null || echo "")

if [ ! -z "$ASSOCIATED_RESOURCES" ] && [ "$ASSOCIATED_RESOURCES" != "None" ]; then
    echo "⚠️  Warning: Web ACL is still associated with resources:"
    echo "$ASSOCIATED_RESOURCES"
    echo "❌ Cannot delete Web ACL while it's associated with resources."
    echo "💡 Please disassociate the Web ACL from all resources first, then run this script again."
    exit 1
fi

# Delete the Web ACL
echo "🗑️  Deleting Web ACL: $WEB_ACL_NAME"
echo "💡 This will remove all associated rules including Bot Control..."
aws wafv2 delete-web-acl \
    --scope CLOUDFRONT \
    --id "$WEB_ACL_ID" \
    --name "$WEB_ACL_NAME" \
    --lock-token "$LOCK_TOKEN"

echo "✅ Successfully deleted Web ACL: $WEB_ACL_NAME"
echo "🎉 Cleanup completed!"

# Verify deletion
sleep 2
REMAINING_ACLS=$(aws wafv2 list-web-acls --scope CLOUDFRONT --query "WebACLs[?Name=='$WEB_ACL_NAME'].Name" --output text)
if [ -z "$REMAINING_ACLS" ]; then
    echo "✅ Verified: Web ACL has been successfully removed."
    echo "💰 Note: Bot Control charges will stop accruing immediately."
else
    echo "⚠️  Warning: Web ACL may still exist. Please check manually."
fi
