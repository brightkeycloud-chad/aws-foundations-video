#!/bin/bash

# Cleanup script for Demo 34.3: Associate WAF with Edge Services
# This script removes WAF associations and optionally cleans up demo resources
# Supports both traditional Web ACLs and new Protection Packs

set -e

echo "🧹 Starting cleanup for WAF Edge Services Association demo..."

# Set region for CloudFront resources
export AWS_DEFAULT_REGION=us-east-1

# Configuration
WEB_ACL_NAME="demo-web-acl"
DEMO_DISTRIBUTION_COMMENT="Demo distribution for WAF association"

echo "📋 Looking for WAF Web ACL: $WEB_ACL_NAME"

# Get the Web ACL ARN (works for both Web ACLs and Protection Packs)
WEB_ACL_ARN=$(aws wafv2 list-web-acls --scope CLOUDFRONT --query "WebACLs[?Name=='$WEB_ACL_NAME'].ARN" --output text 2>/dev/null || echo "")

if [ -z "$WEB_ACL_ARN" ] || [ "$WEB_ACL_ARN" == "None" ]; then
    echo "ℹ️  No Web ACL found with name '$WEB_ACL_NAME'."
    echo "🔍 Checking for Protection Packs..."
    
    # List all Web ACLs to find any that might be Protection Packs
    ALL_ACLS=$(aws wafv2 list-web-acls --scope CLOUDFRONT --query "WebACLs[].{Name:Name,ARN:ARN}" --output json 2>/dev/null || echo "[]")
    
    if [ "$ALL_ACLS" != "[]" ] && [ ! -z "$ALL_ACLS" ]; then
        echo "📦 Found the following WAF configurations:"
        echo "$ALL_ACLS" | jq -r '.[] | "  - \(.Name) (\(.ARN | split("/") | .[-1]))"' 2>/dev/null || echo "  - Unable to parse WAF configurations"
        
        echo ""
        read -p "❓ Enter the name of the WAF configuration to clean up (or press Enter to skip): " -r USER_ACL_NAME
        
        if [ ! -z "$USER_ACL_NAME" ]; then
            WEB_ACL_ARN=$(echo "$ALL_ACLS" | jq -r ".[] | select(.Name==\"$USER_ACL_NAME\") | .ARN" 2>/dev/null || echo "")
            WEB_ACL_NAME="$USER_ACL_NAME"
        fi
    fi
fi

if [ ! -z "$WEB_ACL_ARN" ] && [ "$WEB_ACL_ARN" != "None" ]; then
    echo "🔍 Found Web ACL ARN: $WEB_ACL_ARN"
    
    # List associated CloudFront distributions
    echo "🔗 Checking for associated CloudFront distributions..."
    ASSOCIATED_DISTRIBUTIONS=$(aws wafv2 list-resources-for-web-acl --web-acl-arn "$WEB_ACL_ARN" --resource-type CLOUDFRONT --query "ResourceArns" --output text 2>/dev/null || echo "")
    
    if [ ! -z "$ASSOCIATED_DISTRIBUTIONS" ] && [ "$ASSOCIATED_DISTRIBUTIONS" != "None" ]; then
        echo "📦 Found associated distributions:"
        echo "$ASSOCIATED_DISTRIBUTIONS"
        
        # Disassociate each distribution
        for DIST_ARN in $ASSOCIATED_DISTRIBUTIONS; do
            # Extract distribution ID from ARN
            DIST_ID=$(echo "$DIST_ARN" | sed 's/.*distribution\///')
            echo "🔓 Disassociating distribution: $DIST_ID"
            
            # Method 1: Try using WAF disassociate command
            echo "   Attempting WAF disassociation..."
            aws wafv2 disassociate-web-acl --resource-arn "$DIST_ARN" 2>/dev/null && echo "   ✅ Successfully disassociated via WAF" && continue
            
            # Method 2: Fallback to CloudFront update (if WAF method fails)
            echo "   Attempting CloudFront update method..."
            
            # Get current distribution config
            ETAG=$(aws cloudfront get-distribution --id "$DIST_ID" --query "ETag" --output text 2>/dev/null || echo "")
            
            if [ ! -z "$ETAG" ]; then
                # Get distribution config and remove WAF association
                aws cloudfront get-distribution-config --id "$DIST_ID" --query "DistributionConfig" > /tmp/dist-config.json 2>/dev/null || continue
                
                # Remove WebACLId from the config
                jq 'del(.WebACLId)' /tmp/dist-config.json > /tmp/dist-config-updated.json 2>/dev/null || continue
                
                # Update the distribution
                aws cloudfront update-distribution \
                    --id "$DIST_ID" \
                    --distribution-config file:///tmp/dist-config-updated.json \
                    --if-match "$ETAG" > /dev/null 2>/dev/null && echo "   ✅ Successfully disassociated via CloudFront" || echo "   ❌ Failed to disassociate"
            else
                echo "   ❌ Could not retrieve distribution configuration"
            fi
        done
        
        # Clean up temp files
        rm -f /tmp/dist-config.json /tmp/dist-config-updated.json
        
        echo "⏳ Waiting for distributions to update..."
        sleep 10
    else
        echo "ℹ️  No associated CloudFront distributions found."
    fi
else
    echo "ℹ️  No WAF configurations found to clean up."
fi

# Optional: Clean up demo CloudFront distributions
echo ""
echo "🔍 Looking for demo CloudFront distributions..."
DEMO_DISTRIBUTIONS=$(aws cloudfront list-distributions --query "DistributionList.Items[?Comment=='$DEMO_DISTRIBUTION_COMMENT'].Id" --output text 2>/dev/null || echo "")

if [ ! -z "$DEMO_DISTRIBUTIONS" ] && [ "$DEMO_DISTRIBUTIONS" != "None" ]; then
    echo "📦 Found demo distributions to clean up:"
    for DIST_ID in $DEMO_DISTRIBUTIONS; do
        echo "  - $DIST_ID"
    done
    
    echo ""
    read -p "❓ Do you want to delete these demo CloudFront distributions? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for DIST_ID in $DEMO_DISTRIBUTIONS; do
            echo "🗑️  Disabling and deleting distribution: $DIST_ID"
            
            # Get current distribution config and ETag
            ETAG=$(aws cloudfront get-distribution --id "$DIST_ID" --query "ETag" --output text 2>/dev/null || echo "")
            
            if [ ! -z "$ETAG" ]; then
                aws cloudfront get-distribution-config --id "$DIST_ID" --query "DistributionConfig" > /tmp/dist-config.json 2>/dev/null || continue
                
                # Disable the distribution
                jq '.Enabled = false' /tmp/dist-config.json > /tmp/dist-config-disabled.json 2>/dev/null || continue
                
                aws cloudfront update-distribution \
                    --id "$DIST_ID" \
                    --distribution-config file:///tmp/dist-config-disabled.json \
                    --if-match "$ETAG" > /dev/null 2>/dev/null && echo "   ✅ Distribution disabled" || echo "   ❌ Failed to disable distribution"
            fi
            
            echo "⏳ Distribution $DIST_ID is being disabled. This may take several minutes..."
            echo "💡 You can delete it manually once it's fully disabled (Status: Disabled)"
        done
        
        # Clean up temp files
        rm -f /tmp/dist-config.json /tmp/dist-config-disabled.json
        
        echo ""
        echo "⚠️  Note: CloudFront distributions take time to disable and delete."
        echo "💡 Check the CloudFront console in 10-15 minutes to complete deletion."
    else
        echo "ℹ️  Skipping CloudFront distribution cleanup."
    fi
else
    echo "ℹ️  No demo CloudFront distributions found."
fi

echo ""
echo "✅ WAF association cleanup completed!"
echo ""
echo "📝 Summary of actions taken:"
echo "  - Disassociated WAF configurations from CloudFront distributions"
echo "  - Optionally disabled demo CloudFront distributions"
echo ""
echo "💡 Next steps:"
echo "  - Run cleanup script from Demo 34.2 to remove the Web ACL/Protection Pack"
echo "  - Manually delete disabled CloudFront distributions from console"
echo "  - Check CloudFront Security Dashboard to verify protections are removed"
echo ""
echo "🎉 Cleanup process finished!"
