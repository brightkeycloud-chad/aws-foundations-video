#!/bin/bash

# Cleanup Lambda function and associated resources
# Usage: ./cleanup_lambda.sh [function-name] [region]

FUNCTION_NAME=${1:-"demo-sqs-processor"}
REGION=${2:-"us-east-1"}
ROLE_NAME="demo-sqs-lambda-execution-role"

echo "Cleaning up Lambda function: $FUNCTION_NAME in region: $REGION"
echo "=================================================="

# Step 1: Delete Lambda function
echo "Step 1: Deleting Lambda function..."
aws lambda delete-function \
    --function-name "$FUNCTION_NAME" \
    --region "$REGION" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Lambda function deleted successfully"
else
    echo "ℹ Lambda function not found or already deleted"
fi

# Step 2: Detach policies from IAM role
echo "Step 2: Detaching policies from IAM role..."

# Detach AWS managed policy
aws iam detach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 2>/dev/null

# Delete inline policy
aws iam delete-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "SQSAccessPolicy" 2>/dev/null

echo "✓ Policies detached"

# Step 3: Delete IAM role
echo "Step 3: Deleting IAM role..."
aws iam delete-role \
    --role-name "$ROLE_NAME" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ IAM role deleted successfully"
else
    echo "ℹ IAM role not found or already deleted"
fi

echo ""
echo "=================================================="
echo "✅ Cleanup completed!"
echo ""
echo "Resources cleaned up:"
echo "- Lambda function: $FUNCTION_NAME"
echo "- IAM role: $ROLE_NAME"
echo "- Associated policies"
echo ""
echo "Note: SQS queues and CloudWatch logs are not automatically deleted."
echo "Delete them manually if no longer needed."
