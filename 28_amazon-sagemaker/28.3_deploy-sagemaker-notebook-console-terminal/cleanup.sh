#!/bin/bash

# SageMaker AI Studio Domain Cleanup Script
# This script cleans up QuickSetupDomain- resources created during the modern SageMaker AI Studio demonstration

set -e

REGION="us-east-1"

echo "🧹 Starting SageMaker AI Studio Domain cleanup..."
echo "Looking for QuickSetupDomain- domains in region: $REGION"
echo ""

# Function to get QuickSetupDomain- domain info
get_quicksetup_domains() {
    aws sagemaker list-domains \
        --region "$REGION" \
        --query "Domains[?starts_with(DomainName, 'QuickSetupDomain-')].[DomainName,DomainId,Status]" \
        --output json 2>/dev/null || echo "[]"
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

# Function to cleanup a single domain
cleanup_domain() {
    local domain_name=$1
    local domain_id=$2
    local status=$3
    
    echo "🎯 Processing domain: $domain_name (ID: $domain_id)"
    echo "📊 Current domain status: $status"
    
    # Check for running applications
    echo ""
    echo "🔍 Checking for running applications..."
    RUNNING_APPS=$(list_running_apps "$domain_id")
    echo "$RUNNING_APPS"
    
    if echo "$RUNNING_APPS" | grep -q "InService"; then
        echo ""
        echo "🛑 Stopping running applications first..."
        
        # Stop all running apps
        aws sagemaker list-apps \
            --domain-id-equals "$domain_id" \
            --region "$REGION" \
            --query 'Apps[?Status==`InService`]' \
            --output json 2>/dev/null | jq -r '.[] | [.DomainId, .UserProfileName, .AppType, .AppName] | @tsv' 2>/dev/null | while IFS=$'\t' read -r d_id user_profile app_type app_name; do
            echo "   Stopping $app_type app: $app_name (user: $user_profile)"
            aws sagemaker delete-app \
                --domain-id "$d_id" \
                --user-profile-name "$user_profile" \
                --app-type "$app_type" \
                --app-name "$app_name" \
                --region "$REGION" 2>/dev/null || echo "   Failed to stop $app_name"
        done
        
        echo "⏳ Waiting for applications to stop..."
        while true; do
            RUNNING_COUNT=$(aws sagemaker list-apps --domain-id-equals "$domain_id" --region "$REGION" --query 'Apps[?Status==`InService`] | length(@)' --output text 2>/dev/null)
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
        --domain-id-equals "$domain_id" \
        --region "$REGION" \
        --query 'Spaces[].[SpaceName,Status]' \
        --output json 2>/dev/null || echo "[]")
    
    SPACE_COUNT=$(echo "$SPACES" | jq '. | length' 2>/dev/null || echo "0")
    
    if [ "$SPACE_COUNT" -gt 0 ]; then
        echo "   Found $SPACE_COUNT space(s) to delete"
        echo "$SPACES" | jq -r '.[] | @tsv' 2>/dev/null | while IFS=$'\t' read -r space_name space_status; do
            echo "   Deleting space: $space_name (status: $space_status)"
            aws sagemaker delete-space \
                --domain-id "$domain_id" \
                --space-name "$space_name" \
                --region "$REGION" 2>/dev/null || echo "   Failed to delete space: $space_name"
        done
        
        echo "⏳ Waiting for spaces to be deleted..."
        while true; do
            REMAINING_SPACES=$(aws sagemaker list-spaces --domain-id-equals "$domain_id" --region "$REGION" --query 'Spaces | length(@)' --output text 2>/dev/null)
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
    
    # Delete user profiles after spaces are deleted
    echo ""
    echo "🗑️  Deleting user profiles..."
    USER_PROFILES=$(aws sagemaker list-user-profiles \
        --domain-id-equals "$domain_id" \
        --region "$REGION" \
        --query 'UserProfiles[].UserProfileName' \
        --output text 2>/dev/null)
    
    if [ -n "$USER_PROFILES" ] && [ "$USER_PROFILES" != "None" ]; then
        for profile in $USER_PROFILES; do
            echo "   Deleting user profile: $profile"
            aws sagemaker delete-user-profile \
                --domain-id "$domain_id" \
                --user-profile-name "$profile" \
                --region "$REGION"
        done
        
        echo "⏳ Waiting for user profiles to be deleted..."
        while true; do
            REMAINING_PROFILES=$(aws sagemaker list-user-profiles --domain-id-equals "$domain_id" --region "$REGION" --query 'UserProfiles[].UserProfileName' --output text 2>/dev/null)
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
    if [ "$status" = "InService" ] || [ "$status" = "Failed" ]; then
        echo "🗑️  Deleting SageMaker AI domain: $domain_name..."
        aws sagemaker delete-domain \
            --domain-id "$domain_id" \
            --region "$REGION" \
            --retention-policy HomeEfsFileSystem=Delete
        
        echo "⏳ Waiting for domain to be deleted..."
        while true; do
            current_status=$(get_domain_status "$domain_id")
            if [ "$current_status" = "NotFound" ]; then
                break
            fi
            echo "   Domain status: $current_status"
            sleep 15
        done
        
        echo "✅ Domain $domain_name deleted successfully!"
    else
        echo "⚠️  Cannot delete domain in status: $status"
        echo "   Please wait for it to reach 'InService' status and run this script again."
        return 1
    fi
}

# First, let's see what domains exist
echo "🔍 Checking all domains in region $REGION..."
ALL_DOMAINS=$(aws sagemaker list-domains --region "$REGION" --query 'Domains[].[DomainName,DomainId,Status]' --output table 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$ALL_DOMAINS" ]; then
    echo "📊 All domains found:"
    echo "$ALL_DOMAINS"
else
    echo "✅ No domains found in region $REGION"
    exit 0
fi
echo ""

# Get QuickSetupDomain- domains specifically
QUICKSETUP_DOMAINS=$(get_quicksetup_domains)
DOMAIN_COUNT=$(echo "$QUICKSETUP_DOMAINS" | jq '. | length' 2>/dev/null || echo "0")

echo "🔍 Looking specifically for QuickSetupDomain- domains..."
echo "📊 Found $DOMAIN_COUNT QuickSetupDomain- domain(s)"

if [ "$DOMAIN_COUNT" -eq 0 ]; then
    echo "✅ No QuickSetupDomain- domains found. Nothing to clean up."
    echo ""
    echo "💡 This script looks for domains that start with 'QuickSetupDomain-'"
    echo "   If you have domains with different names, use cleanup-flexible.sh instead"
    exit 0
fi

# Show the domains we found
echo ""
echo "📋 QuickSetupDomain- domains to be cleaned up:"
echo "$QUICKSETUP_DOMAINS" | jq -r '.[] | "  - \(.[0]) (ID: \(.[1]), Status: \(.[2]))"' 2>/dev/null || {
    echo "$QUICKSETUP_DOMAINS" | jq -r '.[] | @tsv' | while IFS=$'\t' read -r name id status; do
        echo "  - $name (ID: $id, Status: $status)"
    done
}

# Confirmation prompt for multiple domains
if [ "$DOMAIN_COUNT" -gt 1 ]; then
    echo ""
    echo "⚠️  WARNING: This will delete $DOMAIN_COUNT QuickSetupDomain- domains!"
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        echo "❌ Operation cancelled."
        exit 0
    fi
fi

echo ""
echo "🚀 Starting cleanup process..."

# Process each QuickSetupDomain- domain
CLEANED_DOMAINS=()
FAILED_DOMAINS=()

echo "$QUICKSETUP_DOMAINS" | jq -r '.[] | @tsv' 2>/dev/null | while IFS=$'\t' read -r domain_name domain_id status; do
    echo ""
    echo "=" $(printf '%.0s' {1..60})
    
    if cleanup_domain "$domain_name" "$domain_id" "$status"; then
        echo "✅ Successfully cleaned up: $domain_name"
        CLEANED_DOMAINS+=("$domain_name")
    else
        echo "❌ Failed to clean up: $domain_name"
        FAILED_DOMAINS+=("$domain_name")
    fi
done

# Check for any remaining SageMaker resources
echo ""
echo "=" $(printf '%.0s' {1..60})
echo "🔍 Final verification - checking for remaining resources..."

# Check for any remaining domains
REMAINING_DOMAINS=$(aws sagemaker list-domains --region "$REGION" --query 'Domains[].DomainName' --output text 2>/dev/null)
if [ -n "$REMAINING_DOMAINS" ] && [ "$REMAINING_DOMAINS" != "None" ]; then
    echo "📊 Other SageMaker domains still exist:"
    echo "$REMAINING_DOMAINS"
else
    echo "✅ No SageMaker domains remaining"
fi

# Check for any training jobs (in case they were started during demo)
RECENT_JOBS=$(aws sagemaker list-training-jobs \
    --region "$REGION" \
    --creation-time-after "$(date -u -v-1H +%Y-%m-%dT%H:%M:%S)" \
    --query 'TrainingJobSummaries[].TrainingJobName' \
    --output text 2>/dev/null || echo "")

if [ -n "$RECENT_JOBS" ] && [ "$RECENT_JOBS" != "None" ]; then
    echo "📊 Recent training jobs found (may need manual cleanup):"
    echo "$RECENT_JOBS"
else
    echo "✅ No recent training jobs found"
fi

echo ""
echo "🎉 Cleanup process completed!"
echo ""
echo "Summary:"
echo "- Processed $DOMAIN_COUNT QuickSetupDomain- domain(s)"
echo "- All associated user profiles and applications cleaned up"
echo ""
echo "💰 Cost Impact:"
echo "- Domain deletion stops all ongoing compute charges"
echo "- Storage charges may continue for a short time during cleanup"
echo "- Check your AWS billing dashboard to confirm"
echo ""
echo "Note: IAM roles created during the demo may still exist."
echo "Review and delete them manually if they're no longer needed."
