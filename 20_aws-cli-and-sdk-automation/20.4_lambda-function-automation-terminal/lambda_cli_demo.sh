#!/bin/bash

# AWS Lambda CLI Demonstration Script

set -e

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
FUNCTION_NAME="cli-demo-function-${TIMESTAMP}"
ROLE_NAME="cli-demo-role-${TIMESTAMP}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "=== AWS Lambda CLI Demonstration ==="
echo "Function: $FUNCTION_NAME"
echo "Role: $ROLE_NAME"
echo

# Create simple Lambda function code
cat > simple_lambda.py << 'LAMBDA_CODE'
import json
import datetime

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from CLI-deployed Lambda!',
            'timestamp': datetime.datetime.utcnow().isoformat(),
            'event': event
        })
    }
LAMBDA_CODE

# Create deployment package
zip function.zip simple_lambda.py

echo "1. Creating IAM role..."
aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
echo "Created role: $ROLE_ARN"

# Wait for role propagation
echo "Waiting for role propagation..."
sleep 10

echo "2. Creating Lambda function..."
aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --runtime python3.9 \
    --role "$ROLE_ARN" \
    --handler simple_lambda.lambda_handler \
    --zip-file fileb://function.zip \
    --description "CLI deployed demo function"

echo "3. Testing Lambda function..."
aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --payload file://test-payload.json \
    response.json

echo "Response:"
cat response.json
echo

echo "4. Listing Lambda functions..."
aws lambda list-functions \
    --query 'Functions[?contains(FunctionName, `cli-demo`)].[FunctionName,Runtime,LastModified]' \
    --output table

echo "5. Getting function configuration..."
aws lambda get-function-configuration \
    --function-name "$FUNCTION_NAME" \
    --query '{Name:FunctionName,Runtime:Runtime,Timeout:Timeout,Memory:MemorySize}' \
    --output table

# Cleanup function
cleanup() {
    echo "Cleaning up resources..."
    aws lambda delete-function --function-name "$FUNCTION_NAME" 2>/dev/null || true
    aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null || true
    aws iam delete-role --role-name "$ROLE_NAME" 2>/dev/null || true
    rm -f simple_lambda.py function.zip response.json
    echo "Cleanup completed!"
}

echo
read -p "Do you want to clean up resources? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cleanup
else
    echo "Resources left in place. Function: $FUNCTION_NAME"
fi
