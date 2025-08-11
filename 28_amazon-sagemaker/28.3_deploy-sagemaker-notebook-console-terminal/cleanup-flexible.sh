#!/bin/bash

# Flexible SageMaker AI Studio Domain Cleanup Script
# This script can clean up any SageMaker domain by name or interactively

set -e

REGION="us-east-1"

echo "🧹 SageMaker AI Studio Domain Cleanup Tool"
echo "=========================================="
echo ""

# Check if domain name was provided as argument
if [ $# -eq 1 ]; then
    DOMAIN_NAME="$1"
    echo "🎯 Target domain specified: $DOMAIN_NAME"
else
    # Show available domains and let user choose
    echo "🔍 Checking all domains in region $REGION..."
    DOMAINS_JSON=$(aws sagemaker list-domains --region "$REGION" --output json 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "❌ Error accessing SageMaker service. Check your AWS credentials and permissions."
        exit 1
    fi
    
    DOMAIN_COUNT=$(echo "$DOMAINS_JSON" | jq '.Domains | length' 2>/dev/null || echo "0")
    
    if [ "$DOMAIN_COUNT" -eq 0 ]; then
        echo "✅ No SageMaker domains found in region $REGION"
        exit 0
    fi
    
    echo "📊 Found $DOMAIN_COUNT domain(s):"
    echo "$DOMAINS_JSON" | jq -r '.Domains[] | "\(.DomainName) (ID: \(.DomainId), Status: \(.Status))"' 2>/dev/null || {
        # Fallback if jq is not available
        aws sagemaker list-domains --region "$REGION" --query 'Domains[].[DomainName,DomainId,Status]' --output table
    }
    
    echo ""
    echo "Please specify which domain to delete:"
    echo "Usage: $0 <domain-name>"
    echo "Example: $0 QuickSetupDomain-20250809T190327"
    exit 0
fi

echo "Region: $REGION"
echo ""

# Function to get domain ID by name with better error handling
get_domain_id() {
    local result
    result=$(aws sagemaker list-domains \
        --region "$REGION" \
        --query "Domains[?DomainName=='$DOMAIN_NAME'].DomainId" \
        --output text 2>/dev/null)
    
    # Clean up the result and check if it's valid
    result=$(echo "$result" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [ -z "$result" ] || [ "$result" = "None" ]; then
        echo "NotFound"
    else
        echo "$result"
    fi
}

# Function to get domain status
get_domain_status() {
    local domain_id=$1
    if [ -z "$domain_id" ] || [ "$domain_id" = "NotFound" ]; then
        echo "NotFound"
        return
    fi
    
    aws sagemaker describe-domain \
        --domain-id "$domain_id" \
        --region "$REGION" \
        --query 'Status' \
        --output text 2>/dev/null || echo "NotFound"
}

# Function to list running applications in domain
list_running_apps() {
    local domain_id=$1
    if [ -z "$domain_id" ] || [ "$domain_id" = "NotFound" ]; then
        echo "No domain ID provided"
        return
    fi
    
    aws sagemaker list-apps \
        --domain-id-equals "$domain_id" \
        --region "$REGION" \
        --query 'Apps[?Status==`InService`].[AppName,AppType,UserProfileName]' \
        --output table 2>/dev/null || echo "No running apps"
}

# Get domain ID for our specific domain
DOMAIN_ID=$(get_domain_id)

echo "🔍 Looking for domain: $DOMAIN_NAME"
echo "🔍 Domain ID result: '$DOMAIN_ID'"

if [ "$DOMAIN_ID" = "NotFound" ] || [ -z "$DOMAIN_ID" ]; then
    echo "❌ Domain '$DOMAIN_NAME' not found."
    echo ""
    echo "Available domains:"
    aws sagemaker list-domains --region "$REGION" --query 'Domains[].[DomainName,DomainId,Status]' --output table 2>/dev/null
    exit 1
fi

echo "📊 Found target domain: $DOMAIN_NAME (ID: $DOMAIN_ID)"

# Get current status
STATUS=$(get_domain_status "$DOMAIN_ID")
echo "📊 Current domain status: $STATUS"

# Confirmation prompt
echo ""
echo "⚠️  WARNING: This will permanently delete the domain '$DOMAIN_NAME' and all associated resources!"
echo "   - All user profiles will be deleted"
echo "   - All applications will be stopped and deleted"
echo "   - All EFS data will be deleted (unless you choose to retain it)"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Operation cancelled."
    exit 0
fi

# Check for running applications
echo ""
echo "🔍 Checking for running applications..."
RUNNING_APPS=$(list_running_apps "$DOMAIN_ID")
echo "$RUNNING_APPS"

if echo "$RUNNING_APPS" | grep -q "InService"; then
    echo ""
    echo "🛑 Stopping running applications first..."
    
    # Stop all running apps
    aws sagemaker list-apps \
        --domain-id-equals "$DOMAIN_ID" \
        --region "$REGION" \
        --query 'Apps[?Status==`InService`]' \
        --output json 2>/dev/null | jq -r '.[] | [.DomainId, .UserProfileName, .AppType, .AppName] | @tsv' | while IFS=$'\t' read -r domain_id user_profile app_type app_name; do
        echo "   Stopping $app_type app: $app_name (user: $user_profile)"
        aws sagemaker delete-app \
            --domain-id "$domain_id" \
            --user-profile-name "$user_profile" \
            --app-type "$app_type" \
            --app-name "$app_name" \
            --region "$REGION" 2>/dev/null || echo "   Failed to stop $app_name"
    done
    
    echo "⏳ Waiting for applications to stop..."
    while true; do
        RUNNING_COUNT=$(aws sagemaker list-apps --domain-id-equals "$DOMAIN_ID" --region "$REGION" --query 'Apps[?Status==`InService`] | length(@)' --output text 2>/dev/null)
        if [ "$RUNNING_COUNT" = "0" ]; then
            break
        fi
        echo "   Still stopping applications... ($RUNNING_COUNT remaining)"
        sleep 10
    done
    echo "✅ All applications stopped"
fi

# Delete spaces first (required before deleting user profiles)
echo ""
echo "🗑️  Deleting spaces..."
SPACES=$(aws sagemaker list-spaces \
    --domain-id-equals "$DOMAIN_ID" \
    --region "$REGION" \
    --query 'Spaces[].[SpaceName,Status]' \
    --output json 2>/dev/null || echo "[]")

SPACE_COUNT=$(echo "$SPACES" | jq '. | length' 2>/dev/null || echo "0")

if [ "$SPACE_COUNT" -gt 0 ]; then
    echo "   Found $SPACE_COUNT space(s) to delete"
    echo "$SPACES" | jq -r '.[] | @tsv' 2>/dev/null | while IFS=$'\t' read -r space_name space_status; do
        echo "   Deleting space: $space_name (status: $space_status)"
        aws sagemaker delete-space \
            --domain-id "$DOMAIN_ID" \
            --space-name "$space_name" \
            --region "$REGION" 2>/dev/null || echo "   Failed to delete space: $space_name"
    done
    
    echo "⏳ Waiting for spaces to be deleted..."
    while true; do
        REMAINING_SPACES=$(aws sagemaker list-spaces --domain-id-equals "$DOMAIN_ID" --region "$REGION" --query 'Spaces | length(@)' --output text 2>/dev/null)
        if [ "$REMAINING_SPACES" = "0" ]; then
            break
        fi
        echo "   Still deleting spaces... ($REMAINING_SPACES remaining)"
        sleep 10
    done
    echo "✅ Spaces deleted"
else
    echo "✅ No spaces to delete"
fi

# Delete user profiles first
echo ""
echo "🗑️  Deleting user profiles..."
USER_PROFILES=$(aws sagemaker list-user-profiles \
    --domain-id-equals "$DOMAIN_ID" \
    --region "$REGION" \
    --query 'UserProfiles[].UserProfileName' \
    --output text 2>/dev/null)

if [ -n "$USER_PROFILES" ] && [ "$USER_PROFILES" != "None" ]; then
    for profile in $USER_PROFILES; do
        echo "   Deleting user profile: $profile"
        aws sagemaker delete-user-profile \
            --domain-id "$DOMAIN_ID" \
            --user-profile-name "$profile" \
            --region "$REGION"
    done
    
    echo "⏳ Waiting for user profiles to be deleted..."
    while true; do
        REMAINING_PROFILES=$(aws sagemaker list-user-profiles --domain-id-equals "$DOMAIN_ID" --region "$REGION" --query 'UserProfiles[].UserProfileName' --output text 2>/dev/null)
        if [ -z "$REMAINING_PROFILES" ] || [ "$REMAINING_PROFILES" = "None" ]; then
            break
        fi
        echo "   Still deleting user profiles..."
        sleep 10
    done
    echo "✅ User profiles deleted"
else
    echo "✅ No user profiles to delete"
fi

# Delete the domain
echo ""
if [ "$STATUS" = "InService" ] || [ "$STATUS" = "Failed" ]; then
    echo "🗑️  Deleting SageMaker AI domain..."
    aws sagemaker delete-domain \
        --domain-id "$DOMAIN_ID" \
        --region "$REGION" \
        --retention-policy HomeEfsFileSystem=Delete
    
    echo "⏳ Waiting for domain to be deleted..."
    while true; do
        current_status=$(get_domain_status "$DOMAIN_ID")
        if [ "$current_status" = "NotFound" ]; then
            break
        fi
        echo "   Domain status: $current_status"
        sleep 15
    done
    
    echo "✅ Domain deleted successfully!"
else
    echo "⚠️  Cannot delete domain in status: $STATUS"
    echo "   Please wait for it to reach 'InService' status and run this script again."
    exit 1
fi

echo ""
echo "🎉 Cleanup completed successfully!"
echo ""
echo "Summary of cleaned up resources:"
echo "- SageMaker AI Domain: $DOMAIN_NAME"
echo "- All associated user profiles, spaces, and applications"
echo ""
echo "💰 Cost Impact:"
echo "- Domain deletion stops all ongoing compute charges"
echo "- Storage charges may continue for a short time during cleanup"
echo "- Check your AWS billing dashboard to confirm"
