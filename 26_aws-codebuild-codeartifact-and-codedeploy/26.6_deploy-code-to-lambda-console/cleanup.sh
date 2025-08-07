#!/bin/bash

# Lambda Demonstration Cleanup Script
# This script removes all resources created during the Lambda demonstration

set -e

echo "🧹 Lambda Demonstration Cleanup"
echo "==============================="

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Error: AWS CLI is not configured or credentials are invalid."
    echo "Please run 'aws configure' to set up your credentials."
    exit 1
fi

echo "✅ AWS credentials are configured"

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required but not installed."
    exit 1
fi

echo "✅ Python 3 is available"

# Check if boto3 is available, use virtual environment if needed
if ! python3 -c "import boto3" &> /dev/null; then
    if [ -d "venv" ]; then
        echo "📦 Using existing virtual environment..."
        source venv/bin/activate
    else
        echo "📦 Creating virtual environment for cleanup..."
        python3 -m venv cleanup_venv
        source cleanup_venv/bin/activate
        pip install boto3 > /dev/null 2>&1
    fi
fi

echo "✅ boto3 is available"

# Get current AWS region
AWS_REGION=$(aws configure get region)
if [ -z "$AWS_REGION" ]; then
    echo "⚠️  Warning: No default region configured. Using us-east-1"
    export AWS_DEFAULT_REGION=us-east-1
else
    echo "🌍 Using AWS region: $AWS_REGION"
fi

echo ""
echo "This script will clean up the following resources:"
echo "  • Lambda function: myLambdaFunction"
echo "  • IAM execution role: myLambdaFunction-role"
echo "  • CloudWatch log group: /aws/lambda/myLambdaFunction"
echo "  • Local test files and virtual environments"
echo ""

# Run the cleanup
python3 cleanup.py

# Clean up temporary virtual environment if we created one
if [ -d "cleanup_venv" ]; then
    echo "🧹 Removing temporary virtual environment..."
    rm -rf cleanup_venv
    echo "✅ Temporary virtual environment removed"
fi

echo ""
echo "🎉 Cleanup script completed!"
