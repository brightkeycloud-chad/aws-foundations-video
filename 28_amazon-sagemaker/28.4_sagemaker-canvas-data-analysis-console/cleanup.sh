#!/bin/bash

# Modern SageMaker Canvas Cleanup Script
# This script provides automated cleanup for Canvas resources in the modern SageMaker AI Studio environment

set -e

REGION="us-east-1"

echo "🧹 Modern SageMaker Canvas Cleanup Tool"
echo "======================================="
echo ""

echo "⚠️  IMPORTANT: Modern Canvas is integrated with SageMaker AI Studio."
echo "This script will help you clean up Canvas resources automatically."
echo ""

# Function to check if jq is available
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "⚠️  jq is not installed. Some features will be limited."
        echo "   Install jq for better functionality: brew install jq"
        return 1
    fi
    return 0
}

# Function to get QuickSetupDomain- domains
get_quicksetup_domains() {
    aws sagemaker list-domains \
        --region "$REGION" \
        --query "Domains[?starts_with(DomainName, 'QuickSetupDomain-')].[DomainName,DomainId,Status]" \
        --output json 2>/dev/null || echo "[]"
}

# Function to stop Canvas applications in a domain
stop_canvas_apps() {
    local domain_id=$1
    local domain_name=$2
    
    echo "🛑 Stopping Canvas applications in domain: $domain_name"
    
    # Get Canvas apps
    local canvas_apps
    if check_jq; then
        canvas_apps=$(aws sagemaker list-apps \
            --domain-id-equals "$domain_id" \
            --region "$REGION" \
            --query 'Apps[?AppType==`Canvas` && Status==`InService`]' \
            --output json 2>/dev/null || echo "[]")
        
        local app_count=$(echo "$canvas_apps" | jq '. | length' 2>/dev/null || echo "0")
        
        if [ "$app_count" -gt 0 ]; then
            echo "   Found $app_count Canvas application(s) to stop"
            
            echo "$canvas_apps" | jq -r '.[] | [.DomainId, .UserProfileName, .AppType, .AppName] | @tsv' | while IFS=$'\t' read -r d_id user_profile app_type app_name; do
                echo "   Stopping Canvas app: $app_name (user: $user_profile)"
                aws sagemaker delete-app \
                    --domain-id "$d_id" \
                    --user-profile-name "$user_profile" \
                    --app-type "$app_type" \
                    --app-name "$app_name" \
                    --region "$REGION" 2>/dev/null || echo "   Failed to stop $app_name"
            done
            
            echo "⏳ Waiting for Canvas applications to stop..."
            while true; do
                local running_count=$(aws sagemaker list-apps --domain-id-equals "$domain_id" --region "$REGION" --query 'Apps[?AppType==`Canvas` && Status==`InService`] | length(@)' --output text 2>/dev/null)
                if [ "$running_count" = "0" ]; then
                    break
                fi
                echo "   Still stopping Canvas applications... ($running_count remaining)"
                sleep 10
            done
            echo "✅ Canvas applications stopped"
        else
            echo "✅ No running Canvas applications found"
        fi
    else
        # Fallback without jq
        echo "   Checking for Canvas applications (limited functionality without jq)..."
        local canvas_check=$(aws sagemaker list-apps --domain-id-equals "$domain_id" --region "$REGION" --query 'Apps[?AppType==`Canvas`].[AppName,Status,UserProfileName]' --output table 2>/dev/null || echo "No Canvas apps")
        
        if echo "$canvas_check" | grep -q "InService"; then
            echo "⚠️  Found running Canvas applications. Please stop them manually:"
            echo "$canvas_check"
            echo ""
            echo "   Use the AWS Console or run these commands manually:"
            aws sagemaker list-apps --domain-id-equals "$domain_id" --region "$REGION" --query 'Apps[?AppType==`Canvas` && Status==`InService`]' --output table
        else
            echo "✅ No running Canvas applications found"
        fi
    fi
}

# Function to provide cleanup guidance for a domain
provide_cleanup_guidance() {
    local domain_name=$1
    local domain_id=$2
    
    echo ""
    echo "📋 Manual Cleanup Steps for domain: $domain_name"
    echo "================================================"
    echo ""
    echo "1. 🗑️  Clean up Canvas Models and Datasets:"
    echo "   - Go to SageMaker Console > Domains > $domain_name"
    echo "   - Click 'Launch' to open Studio"
    echo "   - Click 'Canvas' application"
    echo "   - In Canvas interface:"
    echo "     • Go to 'Models' → Select any demo models → Delete"
    echo "     • Go to 'Datasets' → Select uploaded datasets → Delete"
    echo "     • Check 'Chat' history and clear if needed"
    echo ""
    echo "2. 🛑 Stop Canvas Application (if not already stopped):"
    echo "   - Return to Studio home interface"
    echo "   - Go to 'Running instances and applications'"
    echo "   - Find Canvas application and click 'Stop'"
    echo ""
    echo "3. 🗑️  Delete Domain (if created for demo only):"
    echo "   - Use the main cleanup script in the Studio demo folder:"
    echo "   cd ../28.3_deploy-sagemaker-notebook-console-terminal/"
    echo "   ./cleanup.sh"
    echo ""
}

# Main execution starts here
echo "🔍 Checking for SageMaker AI domains..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity --region "$REGION" >/dev/null 2>&1; then
    echo "❌ AWS CLI not configured or no permissions. Please run 'aws configure'"
    exit 1
fi

# Get all domains
ALL_DOMAINS=$(aws sagemaker list-domains --region "$REGION" --query 'Domains[].[DomainName,DomainId,Status]' --output table 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$ALL_DOMAINS" ]; then
    echo "✅ No SageMaker domains found in region $REGION"
    exit 0
fi

echo "📊 All domains found:"
echo "$ALL_DOMAINS"
echo ""

# Get QuickSetupDomain- domains specifically
QUICKSETUP_DOMAINS=$(get_quicksetup_domains)

if check_jq; then
    DOMAIN_COUNT=$(echo "$QUICKSETUP_DOMAINS" | jq '. | length' 2>/dev/null || echo "0")
else
    DOMAIN_COUNT=$(echo "$QUICKSETUP_DOMAINS" | grep -c "QuickSetupDomain-" 2>/dev/null || echo "0")
fi

echo "🎯 Found $DOMAIN_COUNT QuickSetupDomain- domain(s) (likely from demos)"

if [ "$DOMAIN_COUNT" -eq 0 ]; then
    echo ""
    echo "💡 No QuickSetupDomain- domains found."
    echo "   If you have other domains with Canvas, you can:"
    echo "   1. Use the flexible cleanup script: ../28.3_deploy-sagemaker-notebook-console-terminal/cleanup-flexible.sh"
    echo "   2. Or manually clean up Canvas resources through the AWS Console"
    exit 0
fi

echo ""
echo "📋 Processing QuickSetupDomain- domains for Canvas cleanup:"

# Process each QuickSetupDomain- domain
if check_jq; then
    echo "$QUICKSETUP_DOMAINS" | jq -r '.[] | @tsv' | while IFS=$'\t' read -r domain_name domain_id status; do
        echo ""
        echo "🎯 Processing domain: $domain_name (ID: $domain_id, Status: $status)"
        
        # Stop Canvas applications
        stop_canvas_apps "$domain_id" "$domain_name"
        
        # Provide cleanup guidance
        provide_cleanup_guidance "$domain_name" "$domain_id"
    done
else
    # Fallback processing without jq
    echo "$QUICKSETUP_DOMAINS" | grep "QuickSetupDomain-" | while read -r line; do
        # Extract domain info (this is a simplified approach)
        domain_name=$(echo "$line" | cut -d'"' -f2)
        domain_id=$(echo "$line" | cut -d'"' -f4)
        
        echo ""
        echo "🎯 Processing domain: $domain_name (ID: $domain_id)"
        
        # Stop Canvas applications
        stop_canvas_apps "$domain_id" "$domain_name"
        
        # Provide cleanup guidance
        provide_cleanup_guidance "$domain_name" "$domain_id"
    done
fi

echo ""
echo "🔍 Additional Verification Commands:"
echo "===================================="
echo ""

echo "📊 Check for Canvas-related S3 buckets:"
echo "aws s3 ls | grep -E \"(canvas|sagemaker)\""
echo ""

echo "📊 Check for recent SageMaker training jobs:"
echo "aws sagemaker list-training-jobs --region $REGION --creation-time-after \"\$(date -u -v-2H +%Y-%m-%dT%H:%M:%S)\" --query 'TrainingJobSummaries[].TrainingJobName' --output table"
echo ""

echo "📊 Verify all Canvas applications are stopped:"
if check_jq; then
    echo "$QUICKSETUP_DOMAINS" | jq -r '.[] | @tsv' | while IFS=$'\t' read -r domain_name domain_id status; do
        echo "# Check Canvas apps in domain: $domain_name"
        echo "aws sagemaker list-apps --domain-id-equals $domain_id --region $REGION --query 'Apps[?AppType==\`Canvas\`].[AppName,Status,UserProfileName]' --output table"
        echo ""
    done
else
    echo "# List all Canvas applications across domains:"
    echo "aws sagemaker list-domains --region $REGION --query 'Domains[].DomainId' --output text | xargs -I {} aws sagemaker list-apps --domain-id-equals {} --region $REGION --query 'Apps[?AppType==\`Canvas\`].[AppName,Status,UserProfileName]' --output table"
fi

echo ""
echo "💰 Cost Considerations:"
echo "======================"
echo "- Canvas session charges stop when applications are stopped"
echo "- Model building charges are one-time per model"
echo "- Generative AI chat features charge per token"
echo "- Ready-to-use models charge per API call"
echo "- Domain storage charges continue until domain deletion"
echo "- Check AWS Cost Explorer for detailed Canvas usage"
echo ""

echo "🎯 Recommended Next Steps:"
echo "========================="
echo "1. ✅ Canvas applications have been stopped (if any were running)"
echo "2. 🗑️  Manually delete Canvas models and datasets through the Console"
echo "3. 🗑️  Use the main cleanup script to delete domains:"
echo "   cd ../28.3_deploy-sagemaker-notebook-console-terminal/"
echo "   ./cleanup.sh"
echo "4. 💰 Monitor AWS billing for Canvas-related charges"
echo ""

echo "✅ Canvas cleanup guidance completed!"
echo ""
echo "💡 Pro Tip: The main cleanup script (../28.3_deploy-sagemaker-notebook-console-terminal/cleanup.sh)"
echo "   will handle complete domain deletion including all Canvas resources."
