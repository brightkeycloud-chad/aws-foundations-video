#!/bin/bash

# EC2 Instance Attributes Demo - Modify Source/Destination Check
# This script demonstrates disabling and enabling source/destination checking

set -e  # Exit on any error

echo "=== EC2 Instance Attributes Demo - Source/Destination Check ==="
echo

# Check if INSTANCE_ID is set
if [[ -z "$INSTANCE_ID" ]]; then
    echo "❌ INSTANCE_ID environment variable is not set."
    echo "Please run: export INSTANCE_ID=your-instance-id"
    exit 1
fi

echo "🔍 Working with instance: $INSTANCE_ID"
echo

# Function to check current source/destination check status
check_source_dest_check() {
    local status
    status=$(aws ec2 describe-instance-attribute --instance-id "$INSTANCE_ID" --attribute sourceDestCheck --query 'SourceDestCheck.Value' --output text)
    echo "Current source/destination check: $status"
}

# Show current status
echo "📋 Current Status:"
check_source_dest_check
echo

# Disable source/destination checking
echo "🔄 Disabling source/destination check..."
echo "   (This is typically done for NAT instances or custom routing scenarios)"
if aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --source-dest-check '{"Value": false}'; then
    echo "✅ Successfully disabled source/destination check"
else
    echo "❌ Failed to disable source/destination check"
    exit 1
fi

# Verify the change
echo
echo "🔍 Verifying change:"
check_source_dest_check
echo

# Wait for user input before re-enabling
echo "⏸️  Source/destination check is now disabled."
echo "Press Enter to re-enable it (recommended for security), or Ctrl+C to keep it disabled..."
read -r

# Re-enable source/destination checking
echo "🔒 Re-enabling source/destination check..."
if aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --source-dest-check '{"Value": true}'; then
    echo "✅ Successfully re-enabled source/destination check"
else
    echo "❌ Failed to re-enable source/destination check"
    exit 1
fi

# Verify the change
echo
echo "🔍 Final verification:"
check_source_dest_check
echo

echo "✅ Source/destination check demo complete!"
echo
echo "💡 Key Points:"
echo "   • Source/destination check should be DISABLED for:"
echo "     - NAT instances"
echo "     - Custom routing scenarios"
echo "     - Load balancers or proxies"
echo "   • Keep ENABLED for regular instances (security best practice)"
echo "   • Changes take effect immediately"
echo "   • Disabling allows the instance to forward traffic"
