#!/bin/bash

# EC2 Instance Attributes Demo - Modify Instance Type
# This script demonstrates changing instance type (requires stopping the instance)

set -e  # Exit on any error

echo "=== EC2 Instance Attributes Demo - Instance Type Modification ==="
echo

# Check if INSTANCE_ID is set
if [[ -z "$INSTANCE_ID" ]]; then
    echo "❌ INSTANCE_ID environment variable is not set."
    echo "Please run: export INSTANCE_ID=your-instance-id"
    exit 1
fi

echo "🔍 Working with instance: $INSTANCE_ID"
echo

# Function to get current instance type and state
get_instance_info() {
    aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].[InstanceType,State.Name]' \
        --output text
}

# Show current instance information
echo "📋 Current Instance Information:"
INSTANCE_INFO=$(get_instance_info)
CURRENT_TYPE=$(echo "$INSTANCE_INFO" | cut -f1)
CURRENT_STATE=$(echo "$INSTANCE_INFO" | cut -f2)

echo "   Instance Type: $CURRENT_TYPE"
echo "   Current State: $CURRENT_STATE"
echo

# Determine target instance type based on current type
if [[ "$CURRENT_TYPE" == "t2.micro" ]]; then
    TARGET_TYPE="t3.micro"
elif [[ "$CURRENT_TYPE" == "t3.micro" ]]; then
    TARGET_TYPE="t2.micro"
else
    TARGET_TYPE="t3.small"
fi

echo "🎯 Target instance type: $TARGET_TYPE"
echo

# Warning about stopping the instance
echo "⚠️  WARNING: This operation requires stopping the instance!"
echo "   • The instance will be temporarily unavailable"
echo "   • Any data in instance store volumes will be lost"
echo "   • The instance will get a new public IP (if not using Elastic IP)"
echo
echo "Continue with instance type change? (y/N): "
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled by user"
    exit 0
fi

# Check if instance needs to be stopped
if [[ "$CURRENT_STATE" != "stopped" ]]; then
    echo "🛑 Stopping instance..."
    if aws ec2 stop-instances --instance-ids "$INSTANCE_ID" > /dev/null; then
        echo "✅ Stop command sent successfully"
    else
        echo "❌ Failed to stop instance"
        exit 1
    fi
    
    echo "⏳ Waiting for instance to stop (this may take a few minutes)..."
    if aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID"; then
        echo "✅ Instance stopped successfully"
    else
        echo "❌ Timeout waiting for instance to stop"
        exit 1
    fi
else
    echo "✅ Instance is already stopped"
fi

echo

# Change instance type
echo "🔄 Changing instance type from $CURRENT_TYPE to $TARGET_TYPE..."
if aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --instance-type "{\"Value\": \"$TARGET_TYPE\"}"; then
    echo "✅ Successfully changed instance type"
else
    echo "❌ Failed to change instance type"
    exit 1
fi

echo

# Ask if user wants to start the instance
echo "🚀 Start the instance now? (Y/n): "
read -r START_CONFIRM

if [[ ! "$START_CONFIRM" =~ ^[Nn]$ ]]; then
    echo "▶️  Starting instance..."
    if aws ec2 start-instances --instance-ids "$INSTANCE_ID" > /dev/null; then
        echo "✅ Start command sent successfully"
    else
        echo "❌ Failed to start instance"
        exit 1
    fi
    
    echo "⏳ Waiting for instance to start..."
    if aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"; then
        echo "✅ Instance started successfully"
    else
        echo "❌ Timeout waiting for instance to start"
        exit 1
    fi
else
    echo "⏸️  Instance left in stopped state"
fi

echo

# Show final instance information
echo "📋 Final Instance Information:"
FINAL_INFO=$(get_instance_info)
FINAL_TYPE=$(echo "$FINAL_INFO" | cut -f1)
FINAL_STATE=$(echo "$FINAL_INFO" | cut -f2)

echo "   Instance Type: $FINAL_TYPE"
echo "   Current State: $FINAL_STATE"
echo

echo "✅ Instance type modification demo complete!"
echo
echo "💡 Key Points:"
echo "   • Instance type changes require stopping the instance"
echo "   • Choose compatible instance types for your workload"
echo "   • Consider network performance, CPU, memory, and storage requirements"
echo "   • Test performance after instance type changes"
echo "   • Instance store data is lost when stopping instances"
