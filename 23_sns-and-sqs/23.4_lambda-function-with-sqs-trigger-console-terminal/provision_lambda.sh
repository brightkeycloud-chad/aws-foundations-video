#!/bin/bash

# Provision Lambda function for SQS trigger demo
# Usage: ./provision_lambda.sh [function-name] [region]

FUNCTION_NAME=${1:-"demo-sqs-processor"}
REGION=${2:-"us-east-1"}
ROLE_NAME="demo-sqs-lambda-execution-role"

echo "Provisioning Lambda function: $FUNCTION_NAME in region: $REGION"
echo "=================================================="

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "Error: AWS CLI is not configured or credentials are invalid."
    echo "Please run 'aws configure' first."
    exit 1
fi

# Get account ID for role ARN
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

echo "Account ID: $ACCOUNT_ID"
echo ""

# Step 1: Create IAM role for Lambda execution
echo "Step 1: Creating IAM execution role..."

# Create trust policy for Lambda
cat > /tmp/lambda-trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

# Create the role
aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document file:///tmp/lambda-trust-policy.json \
    --description "Execution role for demo SQS Lambda function" \
    --region "$REGION" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ IAM role created successfully"
else
    echo "ℹ IAM role already exists or creation failed - continuing..."
fi

# Step 2: Attach necessary policies to the role
echo "Step 2: Attaching policies to execution role..."

# Attach basic Lambda execution policy
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" \
    --region "$REGION"

# Create and attach SQS access policy
cat > /tmp/sqs-lambda-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
            ],
            "Resource": "*"
        }
    ]
}
EOF

aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "SQSAccessPolicy" \
    --policy-document file:///tmp/sqs-lambda-policy.json \
    --region "$REGION"

echo "✓ Policies attached successfully"

# Step 3: Wait for role to be available
echo "Step 3: Waiting for IAM role to be available..."
sleep 10

# Step 4: Create deployment package
echo "Step 4: Creating deployment package..."

# Create a temporary directory for the deployment package
TEMP_DIR=$(mktemp -d)
cp lambda_function.py "$TEMP_DIR/"

# Create the zip file
cd "$TEMP_DIR"
zip -q lambda-deployment.zip lambda_function.py
cd - > /dev/null

echo "✓ Deployment package created"

# Step 5: Create Lambda function
echo "Step 5: Creating Lambda function..."

aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --runtime python3.13 \
    --role "$ROLE_ARN" \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://"$TEMP_DIR"/lambda-deployment.zip \
    --description "Demo Lambda function for processing SQS messages" \
    --timeout 30 \
    --memory-size 128 \
    --region "$REGION"

if [ $? -eq 0 ]; then
    echo "✓ Lambda function created successfully"
else
    echo "❌ Failed to create Lambda function"
    # Cleanup temp files
    rm -rf "$TEMP_DIR"
    rm -f /tmp/lambda-trust-policy.json /tmp/sqs-lambda-policy.json
    exit 1
fi

# Step 6: Wait for function to be active
echo "Step 6: Waiting for function to be active..."
aws lambda wait function-active --function-name "$FUNCTION_NAME" --region "$REGION"
echo "✓ Function is now active"

# Cleanup temp files
rm -rf "$TEMP_DIR"
rm -f /tmp/lambda-trust-policy.json /tmp/sqs-lambda-policy.json

echo ""
echo "=================================================="
echo "✅ Lambda function provisioned successfully!"
echo ""
echo "Function Details:"
echo "- Function Name: $FUNCTION_NAME"
echo "- Region: $REGION"
echo "- Runtime: Python 3.13"
echo "- Role: $ROLE_NAME"
echo ""
echo "Next Steps for Demo:"
echo "1. Create an SQS queue in the console"
echo "2. Add SQS trigger to the Lambda function in the console"
echo "3. Test with: ./send_test_messages.sh"
echo ""
echo "To view the function in console:"
echo "https://console.aws.amazon.com/lambda/home?region=$REGION#/functions/$FUNCTION_NAME"
echo ""
echo "To delete resources later, run:"
echo "./cleanup_lambda.sh $FUNCTION_NAME $REGION"
