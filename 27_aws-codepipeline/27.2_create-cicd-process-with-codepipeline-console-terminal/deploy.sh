#!/bin/bash

# AWS CodePipeline Demo Deployment Script
set -e

echo "🚀 Starting AWS CodePipeline Demo Deployment"
echo "============================================="

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

if ! command -v cdk &> /dev/null; then
    echo "❌ AWS CDK is not installed. Please install it with: npm install -g aws-cdk"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.6 or later."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Setup Python environment
echo "🐍 Setting up Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Get AWS details
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "us-east-1")

echo "🔧 Detected AWS Account: $AWS_ACCOUNT_ID"
echo "🌍 Detected AWS Region: $AWS_REGION"
echo "ℹ️  app.py will automatically use these values via STS"

# Bootstrap and deploy
echo "🏗️  Bootstrapping CDK environment..."
cdk bootstrap aws://$AWS_ACCOUNT_ID/$AWS_REGION

echo "🚀 Deploying CodePipeline stack..."
cdk deploy --require-approval never

# Get source bucket name from stack outputs
echo "📦 Creating sample source package..."
cd sample-source
zip -r ../source.zip .
cd ..

echo "🔍 Finding source bucket..."
SOURCE_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name CodepipelineDemoStack \
    --query 'Stacks[0].Outputs[?OutputKey==`SourceBucketName`].OutputValue' \
    --output text)

echo "📤 Enabling S3 versioning and uploading source code..."
aws s3api put-bucket-versioning \
    --bucket $SOURCE_BUCKET \
    --versioning-configuration Status=Enabled

aws s3 cp source.zip s3://$SOURCE_BUCKET/source.zip

echo "🚀 Starting pipeline execution..."
PIPELINE_NAME=$(aws cloudformation describe-stack-resources \
    --stack-name CodepipelineDemoStack \
    --query 'StackResources[?ResourceType==`AWS::CodePipeline::Pipeline`].PhysicalResourceId' \
    --output text)

aws codepipeline start-pipeline-execution --name $PIPELINE_NAME

# Get website URL from stack outputs
WEBSITE_URL=$(aws cloudformation describe-stacks \
    --stack-name CodepipelineDemoStack \
    --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
    --output text)

echo ""
echo "🎉 Deployment completed successfully!"
echo "============================================="
echo ""
echo "📊 Resources Created:"
echo "• Source Bucket: $SOURCE_BUCKET"
echo "• Pipeline: $PIPELINE_NAME"
echo "• Website URL: $WEBSITE_URL"
echo ""
echo "🔗 Useful Links:"
echo "• CodePipeline Console: https://console.aws.amazon.com/codesuite/codepipeline/pipelines"
echo "• CloudFormation Console: https://console.aws.amazon.com/cloudformation/home"
echo ""
echo "⏱️  Pipeline is running! Once complete, view your application at:"
echo "🌐 $WEBSITE_URL"
