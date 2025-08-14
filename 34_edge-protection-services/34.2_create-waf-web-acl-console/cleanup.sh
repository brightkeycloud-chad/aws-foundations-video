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

# Get the Web ACL ID and scope
WEB_ACL_INFO=$(aws wafv2 list-web-acls --scope CLOUDFRONT --query "WebACLs[?Name=='$WEB_ACL_NAME'].[Id,LockToken]" --output text 2>/dev/null || echo "")

if [ -z "$WEB_ACL_INFO" ]; then
    echo "ℹ️  No Web ACL found with name '$WEB_ACL_NAME'. Nothing to clean up."
    exit 0
fi

# Extract ID and LockToken
WEB_ACL_ID=$(echo $WEB_ACL_INFO | cut -d$'\t' -f1)
LOCK_TOKEN=$(echo $WEB_ACL_INFO | cut -d$'\t' -f2)

echo "🔍 Found Web ACL ID: $WEB_ACL_ID"

# Get Web ACL details to show what's being deleted
echo "📊 Retrieving Web ACL configuration..."
WEB_ACL_DETAILS=$(aws wafv2 get-web-acl --scope CLOUDFRONT --id "$WEB_ACL_ID" --query "WebACL" 2>/dev/null || echo "")

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
ASSOCIATED_RESOURCES=$(aws wafv2 list-resources-for-web-acl --web-acl-arn "arn:aws:wafv2:us-east-1:$(aws sts get-caller-identity --query Account --output text):webacl/$WEB_ACL_ID" --resource-type CLOUDFRONT --query "ResourceArns" --output text 2>/dev/null || echo "")

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
