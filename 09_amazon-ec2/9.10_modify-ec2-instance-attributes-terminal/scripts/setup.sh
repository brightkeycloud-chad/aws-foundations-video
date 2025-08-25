#!/bin/bash

# EC2 Instance Attributes Demo - Setup Script
# This script verifies AWS CLI configuration and lists available instances

set -e  # Exit on any error

echo "=== EC2 Instance Attributes Demo - Setup ==="
echo

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    echo "Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Verify AWS CLI configuration
echo "🔍 Verifying AWS CLI configuration..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI is not configured or credentials are invalid."
    echo "Run 'aws configure' to set up your credentials."
    exit 1
fi

echo "✅ AWS CLI is properly configured"
echo

# Display current AWS identity
echo "📋 Current AWS Identity:"
aws sts get-caller-identity --output table
echo

# List available EC2 instances
echo "🖥️  Available EC2 Instances:"
INSTANCES=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0]]' --output table)

if [[ -z "$INSTANCES" || "$INSTANCES" == *"None"* ]]; then
    echo "❌ No EC2 instances found in your account."
    echo "Please create an EC2 instance first before running this demo."
    exit 1
fi

echo "$INSTANCES"
echo

# Prompt user to set instance ID
echo "📝 Please set your instance ID as an environment variable:"
echo "export INSTANCE_ID=i-1234567890abcdef0"
echo
echo "Replace 'i-1234567890abcdef0' with your actual instance ID from the list above."
echo
echo "After setting the INSTANCE_ID, you can run the other demo scripts:"
echo "  ./scripts/view-attributes.sh"
echo "  ./scripts/modify-termination-protection.sh"
echo "  ./scripts/modify-source-dest-check.sh"
echo "  ./scripts/modify-instance-type.sh"
echo "  ./scripts/cleanup.sh"
