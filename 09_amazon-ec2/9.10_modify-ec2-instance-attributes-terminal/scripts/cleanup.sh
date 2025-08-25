#!/bin/bash

# EC2 Instance Attributes Demo - Cleanup Script
# This script resets all demonstration changes to safe defaults

set -e  # Exit on any error

echo "=== EC2 Instance Attributes Demo - Cleanup ==="
echo

# Check if INSTANCE_ID is set
if [[ -z "$INSTANCE_ID" ]]; then
    echo "❌ INSTANCE_ID environment variable is not set."
    echo "Please run: export INSTANCE_ID=your-instance-id"
    exit 1
fi

echo "🔍 Cleaning up changes for instance: $INSTANCE_ID"
echo

# Function to check if instance exists
check_instance_exists() {
    if ! aws ec2 describe-instances --instance-ids "$INSTANCE_ID" &> /dev/null; then
        echo "❌ Instance $INSTANCE_ID not found or you don't have permission to access it."
        exit 1
    fi
}

# Verify instance exists
check_instance_exists

echo "🧹 Resetting instance attributes to safe defaults..."
echo

# Reset termination protection (disable it)
echo "🔓 Disabling termination protection..."
if aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --no-disable-api-termination; then
    echo "✅ Termination protection disabled"
else
    echo "⚠️  Failed to disable termination protection (may already be disabled)"
fi

# Reset source/destination check (enable it)
echo "🔒 Enabling source/destination check..."
if aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --source-dest-check '{"Value": true}'; then
    echo "✅ Source/destination check enabled"
else
    echo "⚠️  Failed to enable source/destination check (may already be enabled)"
fi

# Reset IMDS settings to secure defaults
echo "🔒 Configuring IMDS to secure defaults (IMDSv2 required)..."
if aws ec2 modify-instance-metadata-options \
    --instance-id "$INSTANCE_ID" \
    --http-tokens required \
    --http-put-response-hop-limit 1 \
    --http-endpoint enabled &> /dev/null; then
    echo "✅ IMDS configured to secure defaults"
else
    echo "⚠️  Failed to configure IMDS settings (may not be supported)"
fi

echo

# Show final status
echo "📋 Final Instance Attributes:"
echo

echo "🛡️  Termination Protection:"
TERMINATION_PROTECTION=$(aws ec2 describe-instance-attribute --instance-id "$INSTANCE_ID" --attribute disableApiTermination --query 'DisableApiTermination.Value' --output text)
if [[ "$TERMINATION_PROTECTION" == "True" ]]; then
    echo "   Status: ✅ Enabled"
else
    echo "   Status: ❌ Disabled (Safe Default)"
fi

echo "🔄 Source/Destination Check:"
SOURCE_DEST_CHECK=$(aws ec2 describe-instance-attribute --instance-id "$INSTANCE_ID" --attribute sourceDestCheck --query 'SourceDestCheck.Value' --output text)
if [[ "$SOURCE_DEST_CHECK" == "True" ]]; then
    echo "   Status: ✅ Enabled (Safe Default)"
else
    echo "   Status: ❌ Disabled"
fi

echo "🔒 IMDS Settings:"
IMDS_INFO=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].MetadataOptions' --output json 2>/dev/null || echo "null")

if [[ "$IMDS_INFO" == "null" ]]; then
    echo "   Status: ⚠️  Not available"
else
    if command -v jq &> /dev/null; then
        HTTP_TOKENS=$(echo "$IMDS_INFO" | jq -r '.HttpTokens // "unknown"')
        if [[ "$HTTP_TOKENS" == "required" ]]; then
            echo "   Status: ✅ Secure (IMDSv2 Required)"
        elif [[ "$HTTP_TOKENS" == "optional" ]]; then
            echo "   Status: 🟡 Moderate (IMDSv1 Allowed)"
        else
            echo "   Status: ❓ Unknown ($HTTP_TOKENS)"
        fi
    else
        echo "   Status: ℹ️  Available (install 'jq' for details)"
    fi
fi

echo

# Check instance state
INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].State.Name' --output text)
echo "🖥️  Instance State: $INSTANCE_STATE"

if [[ "$INSTANCE_STATE" == "stopped" ]]; then
    echo
    echo "⚠️  Note: Instance is currently stopped."
    echo "   If you modified the instance type during the demo,"
    echo "   you may want to start it manually:"
    echo "   aws ec2 start-instances --instance-ids $INSTANCE_ID"
fi

echo
echo "✅ Cleanup complete!"
echo
echo "📝 Summary of changes reset:"
echo "   • Termination protection: Disabled"
echo "   • Source/destination check: Enabled"
echo "   • IMDS settings: Configured to secure defaults (IMDSv2 required)"
echo "   • Instance type: Not automatically reset (manual action required if changed)"
echo
echo "🔒 Your instance is now in a secure default configuration."
