#!/bin/bash

# EC2 Instance Attributes Demo - Modify IMDS Settings
# This script demonstrates modifying Instance Metadata Service (IMDS) settings

set -e  # Exit on any error

echo "=== EC2 Instance Attributes Demo - IMDS Settings ==="
echo

# Check if INSTANCE_ID is set
if [[ -z "$INSTANCE_ID" ]]; then
    echo "❌ INSTANCE_ID environment variable is not set."
    echo "Please run: export INSTANCE_ID=your-instance-id"
    exit 1
fi

echo "🔍 Working with instance: $INSTANCE_ID"
echo

# Function to check current IMDS settings
check_imds_settings() {
    echo "📋 Current IMDS Settings:"
    
    # Get IMDS configuration
    local imds_info
    imds_info=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].MetadataOptions' --output json)
    
    if [[ "$imds_info" == "null" ]]; then
        echo "   ⚠️  IMDS settings not available (older instance or unsupported)"
        return 1
    fi
    
    # Parse IMDS settings
    local state=$(echo "$imds_info" | jq -r '.State // "unknown"')
    local http_tokens=$(echo "$imds_info" | jq -r '.HttpTokens // "unknown"')
    local http_put_response_hop_limit=$(echo "$imds_info" | jq -r '.HttpPutResponseHopLimit // "unknown"')
    local http_endpoint=$(echo "$imds_info" | jq -r '.HttpEndpoint // "unknown"')
    local instance_metadata_tags=$(echo "$imds_info" | jq -r '.InstanceMetadataTags // "unknown"')
    
    echo "   IMDS State: $state"
    echo "   HTTP Endpoint: $http_endpoint"
    echo "   HTTP Tokens: $http_tokens"
    echo "   Hop Limit: $http_put_response_hop_limit"
    echo "   Instance Metadata Tags: $instance_metadata_tags"
    
    # Explain the settings
    echo
    echo "💡 IMDS Setting Explanations:"
    case "$http_tokens" in
        "optional")
            echo "   🟡 HTTP Tokens: OPTIONAL (IMDSv1 and IMDSv2 allowed - less secure)"
            ;;
        "required")
            echo "   🟢 HTTP Tokens: REQUIRED (IMDSv2 only - more secure)"
            ;;
        *)
            echo "   ❓ HTTP Tokens: $http_tokens"
            ;;
    esac
    
    case "$http_endpoint" in
        "enabled")
            echo "   🟢 HTTP Endpoint: ENABLED (IMDS accessible)"
            ;;
        "disabled")
            echo "   🔴 HTTP Endpoint: DISABLED (IMDS not accessible)"
            ;;
        *)
            echo "   ❓ HTTP Endpoint: $http_endpoint"
            ;;
    esac
    
    echo "   📏 Hop Limit: $http_put_response_hop_limit (network hops allowed for IMDS requests)"
}

# Show current IMDS settings
check_imds_settings
echo

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "⚠️  Note: 'jq' is not installed. IMDS settings display may be limited."
    echo "   Install jq for better output formatting: brew install jq (macOS) or apt-get install jq (Ubuntu)"
    echo
fi

# Demonstrate IMDS security hardening
echo "🔒 IMDS Security Hardening Demonstration"
echo "   This will configure IMDS to require tokens (IMDSv2 only) for better security."
echo
echo "Continue with IMDS hardening? (y/N): "
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "⏭️  Skipping IMDS hardening demonstration"
    exit 0
fi

echo
echo "🔧 Configuring IMDS to require tokens (IMDSv2 only)..."

# Configure IMDS to require tokens (IMDSv2 only)
if aws ec2 modify-instance-metadata-options \
    --instance-id "$INSTANCE_ID" \
    --http-tokens required \
    --http-put-response-hop-limit 1 \
    --http-endpoint enabled; then
    echo "✅ Successfully configured IMDS security settings"
else
    echo "❌ Failed to configure IMDS settings"
    exit 1
fi

echo
echo "⏳ Waiting for IMDS configuration to take effect..."
sleep 5

# Verify the changes
echo "🔍 Verifying IMDS configuration changes:"
check_imds_settings
echo

# Demonstrate the difference
echo "🧪 Testing IMDS Access Methods:"
echo
echo "1. Testing IMDSv1 (should fail with current settings):"
echo "   Command: curl -s http://169.254.169.254/latest/meta-data/instance-id"
if timeout 5 curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null; then
    echo "   🟡 IMDSv1 still works (unexpected with required tokens)"
else
    echo "   ✅ IMDSv1 blocked (as expected with required tokens)"
fi

echo
echo "2. Testing IMDSv2 (should work with current settings):"
echo "   Commands:"
echo "   TOKEN=\$(curl -X PUT -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600' http://169.254.169.254/latest/api/token)"
echo "   curl -H \"X-aws-ec2-metadata-token: \$TOKEN\" http://169.254.169.254/latest/meta-data/instance-id"

# Only test if we're running on an EC2 instance
if timeout 5 curl -s http://169.254.169.254/latest/meta-data/ &>/dev/null; then
    echo "   🔍 Attempting IMDSv2 test..."
    TOKEN=$(timeout 5 curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s http://169.254.169.254/latest/api/token 2>/dev/null || echo "")
    if [[ -n "$TOKEN" ]]; then
        INSTANCE_ID_FROM_IMDS=$(timeout 5 curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "")
        if [[ -n "$INSTANCE_ID_FROM_IMDS" ]]; then
            echo "   ✅ IMDSv2 works: Retrieved instance ID: $INSTANCE_ID_FROM_IMDS"
        else
            echo "   ❌ IMDSv2 failed to retrieve instance ID"
        fi
    else
        echo "   ❌ Failed to get IMDSv2 token"
    fi
else
    echo "   ℹ️  Not running on EC2 instance - cannot test IMDS access directly"
fi

echo

# Ask about reverting settings
echo "🔄 Revert IMDS settings to less restrictive configuration? (y/N): "
read -r REVERT_CONFIRM

if [[ "$REVERT_CONFIRM" =~ ^[Yy]$ ]]; then
    echo "🔧 Reverting IMDS settings to allow both IMDSv1 and IMDSv2..."
    
    if aws ec2 modify-instance-metadata-options \
        --instance-id "$INSTANCE_ID" \
        --http-tokens optional \
        --http-put-response-hop-limit 2 \
        --http-endpoint enabled; then
        echo "✅ Successfully reverted IMDS settings"
    else
        echo "❌ Failed to revert IMDS settings"
        exit 1
    fi
    
    echo
    echo "⏳ Waiting for IMDS configuration to take effect..."
    sleep 5
    
    echo "🔍 Final IMDS configuration:"
    check_imds_settings
else
    echo "⚠️  IMDS remains in secure configuration (tokens required)"
fi

echo
echo "✅ IMDS settings demonstration complete!"
echo
echo "💡 Key Points:"
echo "   • IMDSv2 (required tokens) is more secure than IMDSv1"
echo "   • Hop limit controls how many network hops IMDS requests can traverse"
echo "   • Disabling HTTP endpoint completely blocks IMDS access"
echo "   • Instance metadata tags can be enabled/disabled separately"
echo "   • IMDS changes take effect immediately"
echo
echo "🔒 Security Recommendations:"
echo "   • Always use 'http-tokens required' for production instances"
echo "   • Set hop limit to 1 for containers to prevent SSRF attacks"
echo "   • Consider disabling IMDS entirely if not needed"
echo "   • Monitor IMDS usage in CloudTrail logs"
