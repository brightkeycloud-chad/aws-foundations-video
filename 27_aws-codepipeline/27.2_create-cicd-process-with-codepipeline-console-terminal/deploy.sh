#!/bin/bash

# AWS CodePipeline Demo Deployment Script
# This script automates the setup and deployment of the CodePipeline demo

set -e

echo "🚀 Starting AWS CodePipeline Demo Deployment"
echo "============================================="

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check if AWS CLI is installed and configured
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if CDK is installed
if ! command -v cdk &> /dev/null; then
    echo "❌ AWS CDK is not installed. Please install it with: npm install -g aws-cdk"
    exit 1
fi

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.6 or later."
    exit 1
fi

# Verify AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Create and activate virtual environment
echo "🐍 Setting up Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Get AWS account ID and region (app.py will handle this automatically now)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)

if [ -z "$AWS_REGION" ]; then
    AWS_REGION="us-east-1"
    echo "⚠️  No default region found, using us-east-1"
fi

echo "🔧 Detected AWS Account: $AWS_ACCOUNT_ID"
echo "🌍 Detected AWS Region: $AWS_REGION"
echo "ℹ️  app.py will automatically use these values via STS"

# Bootstrap CDK if needed
echo "🏗️  Bootstrapping CDK environment..."
cdk bootstrap aws://$AWS_ACCOUNT_ID/$AWS_REGION

# Deploy the stack
echo "🚀 Deploying CodePipeline stack..."
cdk deploy --require-approval never

# Create source.zip for testing
echo "📦 Creating sample source package..."
cd sample-source
zip -r ../source.zip .
cd ..

# Get the source bucket name from CDK outputs
SOURCE_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name CodepipelineDemoStack \
    --query 'Stacks[0].Outputs[?OutputKey==`SourceBucketName`].OutputValue' \
    --output text)

# Upload source.zip to trigger the pipeline
echo "📤 Uploading source code to trigger pipeline..."
aws s3 cp source.zip s3://$SOURCE_BUCKET/source.zip

echo ""
echo "🎉 Deployment completed successfully!"
echo "============================================="
echo ""
echo "📊 Stack Outputs:"
aws cloudformation describe-stacks \
    --stack-name CodepipelineDemoStack \
    --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
    --output table

echo ""
echo "🔗 Useful Links:"
echo "• CodePipeline Console: https://console.aws.amazon.com/codesuite/codepipeline/pipelines"
echo "• CloudFormation Console: https://console.aws.amazon.com/cloudformation/home"
echo ""
echo "⏱️  The pipeline will start automatically. Check the CodePipeline console to monitor progress."
echo ""
echo "🧹 To clean up resources later, run: cdk destroy"
