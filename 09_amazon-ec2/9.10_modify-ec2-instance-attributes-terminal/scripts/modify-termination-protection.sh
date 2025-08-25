#!/bin/bash

# EC2 Instance Attributes Demo - Modify Termination Protection
# This script demonstrates enabling and disabling termination protection

set -e  # Exit on any error

echo "=== EC2 Instance Attributes Demo - Termination Protection ==="
echo

# Check if INSTANCE_ID is set
if [[ -z "$INSTANCE_ID" ]]; then
    echo "❌ INSTANCE_ID environment variable is not set."
    echo "Please run: export INSTANCE_ID=your-instance-id"
    exit 1
fi

echo "🔍 Working with instance: $INSTANCE_ID"
echo

# Function to check current termination protection status
check_termination_protection() {
    local status
    status=$(aws ec2 describe-instance-attribute --instance-id "$INSTANCE_ID" --attribute disableApiTermination --query 'DisableApiTermination.Value' --output text)
    echo "Current termination protection: $status"
}

# Show current status
echo "📋 Current Status:"
check_termination_protection
echo

# Enable termination protection
echo "🛡️  Enabling termination protection..."
if aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --disable-api-termination; then
    echo "✅ Successfully enabled termination protection"
else
    echo "❌ Failed to enable termination protection"
    exit 1
fi

# Verify the change
echo
echo "🔍 Verifying change:"
check_termination_protection
echo

# Wait for user input before disabling
echo "⏸️  Termination protection is now enabled."
echo "Press Enter to disable it (for demo cleanup), or Ctrl+C to keep it enabled..."
read -r

# Disable termination protection
echo "🔓 Disabling termination protection..."
if aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --no-disable-api-termination; then
    echo "✅ Successfully disabled termination protection"
else
    echo "❌ Failed to disable termination protection"
    exit 1
fi

# Verify the change
echo
echo "🔍 Final verification:"
check_termination_protection
echo

echo "✅ Termination protection demo complete!"
echo
echo "💡 Key Points:"
echo "   • Termination protection prevents accidental instance deletion"
echo "   • Enable for production instances"
echo "   • Must be disabled before legitimate termination"
echo "   • Changes take effect immediately"
