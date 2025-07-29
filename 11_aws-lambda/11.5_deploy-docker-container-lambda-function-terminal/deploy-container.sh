#!/bin/bash

# Deploy Lambda Function using Docker Container
# This script builds a container image and deploys it to AWS Lambda

set -e

# Configuration
FUNCTION_NAME="AnalyticsProcessorFunction"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO_NAME="lambda-analytics-processor"
IMAGE_TAG="latest"
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}"

echo "🚀 Starting container Lambda deployment process..."
echo "📋 Configuration:"
echo "   Function Name: $FUNCTION_NAME"
echo "   Region: $REGION"
echo "   Account ID: $ACCOUNT_ID"
echo "   ECR Repository: $ECR_REPO_NAME"

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Create ECR repository if it doesn't exist
echo "🏗️  Setting up ECR repository..."
if ! aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $REGION > /dev/null 2>&1; then
    echo "📦 Creating ECR repository: $ECR_REPO_NAME"
    aws ecr create-repository \
        --repository-name $ECR_REPO_NAME \
        --region $REGION \
        --image-scanning-configuration scanOnPush=true
else
    echo "✅ ECR repository already exists"
fi

# Get ECR login token
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

# Build Docker image
echo "🔨 Building Docker image for x86_64 architecture..."
docker build --platform linux/amd64 -t $ECR_REPO_NAME:$IMAGE_TAG .

# Tag image for ECR
echo "🏷️  Tagging image for ECR..."
docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

# Push image to ECR
echo "📤 Pushing image to ECR..."
docker push $ECR_URI:$IMAGE_TAG

# Check if Lambda function exists
echo "🔍 Checking if Lambda function exists..."
if aws lambda get-function --function-name $FUNCTION_NAME --region $REGION > /dev/null 2>&1; then
    echo "🔄 Function exists. Updating function code..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --image-uri $ECR_URI:$IMAGE_TAG \
        --region $REGION
    echo "✅ Function code updated successfully!"
else
    echo "🆕 Creating new Lambda function..."
    
    # Create execution role if it doesn't exist
    ROLE_NAME="${FUNCTION_NAME}Role"
    ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
    
    if ! aws iam get-role --role-name $ROLE_NAME > /dev/null 2>&1; then
        echo "👤 Creating IAM role: $ROLE_NAME"
        
        # Create trust policy
        cat > trust-policy.json << EOF
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
        
        aws iam create-role \
            --role-name $ROLE_NAME \
            --assume-role-policy-document file://trust-policy.json
        
        # Attach basic execution policy
        aws iam attach-role-policy \
            --role-name $ROLE_NAME \
            --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
        
        # Attach S3 full access (for demo purposes)
        aws iam attach-role-policy \
            --role-name $ROLE_NAME \
            --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
        
        # Clean up temp file
        rm trust-policy.json
        
        echo "⏳ Waiting for role to be available..."
        sleep 10
    fi
    
    # Create Lambda function
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --role $ROLE_ARN \
        --code ImageUri=$ECR_URI:$IMAGE_TAG \
        --package-type Image \
        --timeout 60 \
        --memory-size 512 \
        --region $REGION
    
    echo "✅ Lambda function created successfully!"
fi

# Update function configuration
echo "⚙️  Updating function configuration..."
aws lambda update-function-configuration \
    --function-name $FUNCTION_NAME \
    --timeout 60 \
    --memory-size 512 \
    --region $REGION

echo "🎉 Deployment completed successfully!"
echo ""
echo "📊 Function Details:"
aws lambda get-function --function-name $FUNCTION_NAME --region $REGION --query 'Configuration.[FunctionName,Runtime,CodeSize,Timeout,MemorySize]' --output table

echo ""
echo "🧪 To test the function:"
echo "aws lambda invoke --function-name $FUNCTION_NAME --payload '{\"data_type\":\"sales\",\"output_bucket\":\"your-bucket-name\"}' response.json"
