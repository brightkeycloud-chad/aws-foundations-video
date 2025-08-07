#!/bin/bash

# Quick AWS Resource Cleanup Script
# Simple script to remove Lambda demonstration resources using AWS CLI

set -e

FUNCTION_NAME="myLambdaFunction"
ROLE_NAME="${FUNCTION_NAME}-role"
LOG_GROUP_NAME="/aws/lambda/${FUNCTION_NAME}"

echo "🧹 Quick Lambda Demonstration Cleanup"
echo "====================================="

# Check AWS CLI
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure'"
    exit 1
fi

echo "✅ AWS CLI configured"

# Get current identity
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
echo "🔐 AWS Account: $ACCOUNT"

echo ""
echo "Cleaning up resources:"
echo "  • Lambda function: $FUNCTION_NAME"
echo "  • IAM role: $ROLE_NAME"  
echo "  • CloudWatch log group: $LOG_GROUP_NAME"
echo ""

# Delete Lambda function
echo "🗑️  Deleting Lambda function..."
if aws lambda delete-function --function-name "$FUNCTION_NAME" 2>/dev/null; then
    echo "✅ Lambda function deleted: $FUNCTION_NAME"
else
    echo "ℹ️  Lambda function not found: $FUNCTION_NAME"
fi

# Delete IAM role (detach policies first)
echo "🗑️  Deleting IAM role..."
if aws iam get-role --role-name "$ROLE_NAME" &>/dev/null; then
    # Detach managed policies
    aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query 'AttachedPolicies[].PolicyArn' --output text | \
    while read -r policy_arn; do
        if [ -n "$policy_arn" ]; then
            aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$policy_arn"
            echo "✅ Detached policy: $(basename $policy_arn)"
        fi
    done
    
    # Delete the role
    aws iam delete-role --role-name "$ROLE_NAME"
    echo "✅ IAM role deleted: $ROLE_NAME"
else
    echo "ℹ️  IAM role not found: $ROLE_NAME"
fi

# Delete CloudWatch log group
echo "🗑️  Deleting CloudWatch log group..."
if aws logs delete-log-group --log-group-name "$LOG_GROUP_NAME" 2>/dev/null; then
    echo "✅ CloudWatch log group deleted: $LOG_GROUP_NAME"
else
    echo "ℹ️  CloudWatch log group not found: $LOG_GROUP_NAME"
fi

# Clean up local files
echo "🗑️  Cleaning up local files..."
if [ -d "venv" ]; then
    rm -rf venv
    echo "✅ Removed virtual environment"
fi

if [ -d "__pycache__" ]; then
    rm -rf __pycache__
    echo "✅ Removed Python cache"
fi

echo ""
echo "🎉 Quick cleanup completed!"
echo ""
echo "Note: Resources may take a few minutes to be fully removed from AWS."
