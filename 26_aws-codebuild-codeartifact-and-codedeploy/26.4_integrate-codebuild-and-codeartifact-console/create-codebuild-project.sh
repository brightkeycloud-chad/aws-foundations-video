#!/bin/bash

# Script to create CodeBuild project for CodeArtifact integration demo
# This script automates the CodeBuild project creation with proper configuration

set -e  # Exit on any error

echo "🔨 Creating CodeBuild project for CodeArtifact integration..."

PROJECT_NAME="codeartifact-integration-demo"

# Check if bucket names file exists
if [ ! -f "bucket-names.txt" ]; then
    echo "❌ Error: bucket-names.txt not found!"
    echo "   Please run create-s3-buckets.sh first"
    exit 1
fi

# Load bucket names
source bucket-names.txt

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "❌ Error: Could not determine AWS Account ID"
    echo "   Please ensure AWS CLI is configured properly"
    exit 1
fi

echo "📋 Project Configuration:"
echo "   Project name: ${PROJECT_NAME}"
echo "   Input bucket: ${INPUT_BUCKET}"
echo "   Output bucket: ${OUTPUT_BUCKET}"
echo "   AWS Account ID: ${AWS_ACCOUNT_ID}"
echo ""

# Check if project already exists
if aws codebuild batch-get-projects --names ${PROJECT_NAME} --query 'projects[0].name' --output text >/dev/null 2>&1; then
    echo "⚠️  CodeBuild project '${PROJECT_NAME}' already exists!"
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Deleting existing project..."
        aws codebuild delete-project --name ${PROJECT_NAME}
        echo "   Waiting for deletion to complete..."
        sleep 5
    else
        echo "❌ Cancelled. Please delete the existing project manually or use a different name."
        exit 1
    fi
fi

# Create service role for CodeBuild if it doesn't exist
ROLE_NAME="CodeBuildServiceRole-CodeArtifactDemo"
echo "🔐 Checking/creating CodeBuild service role..."

if ! aws iam get-role --role-name ${ROLE_NAME} >/dev/null 2>&1; then
    echo "   Creating service role: ${ROLE_NAME}"
    
    # Create trust policy
    cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    # Create the role
    aws iam create-role \
        --role-name ${ROLE_NAME} \
        --assume-role-policy-document file://trust-policy.json \
        --description "Service role for CodeBuild project with CodeArtifact integration"

    # Create and attach the comprehensive policy
    cat > codebuild-policy.json << EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"codeartifact:GetAuthorizationToken",
				"codeartifact:GetRepositoryEndpoint",
				"codeartifact:ReadFromRepository",
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents",
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": "sts:GetServiceBearerToken",
			"Resource": "*",
			"Condition": {
				"StringEquals": {
					"sts:AWSServiceName": "codeartifact.amazonaws.com"
				}
			}
		}
	]
}
EOF

    aws iam put-role-policy \
        --role-name ${ROLE_NAME} \
        --policy-name CodeBuildCodeArtifactPolicy \
        --policy-document file://codebuild-policy.json

    # Clean up temporary files
    rm -f trust-policy.json codebuild-policy.json

    echo "   ✅ Service role created successfully"
    
    # Wait for role to be available
    echo "   ⏳ Waiting for role to be available..."
    sleep 10
else
    echo "   ✅ Service role already exists: ${ROLE_NAME}"
fi

# Get role ARN
ROLE_ARN=$(aws iam get-role --role-name ${ROLE_NAME} --query 'Role.Arn' --output text)

# Create CodeBuild project
echo "🏗️  Creating CodeBuild project..."

cat > codebuild-project.json << EOF
{
    "name": "${PROJECT_NAME}",
    "description": "CodeArtifact integration demonstration project",
    "source": {
        "type": "S3",
        "location": "${INPUT_BUCKET}/codeartifact-demo-source.zip"
    },
    "artifacts": {
        "type": "S3",
        "location": "${OUTPUT_BUCKET}",
        "name": "codeartifact-demo-output.zip",
        "packaging": "ZIP"
    },
    "environment": {
        "type": "LINUX_CONTAINER",
        "image": "aws/codebuild/amazonlinux2-x86_64-standard:3.0",
        "computeType": "BUILD_GENERAL1_SMALL",
        "environmentVariables": [
            {
                "name": "AWS_ACCOUNT_ID",
                "value": "${AWS_ACCOUNT_ID}",
                "type": "PLAINTEXT"
            }
        ]
    },
    "serviceRole": "${ROLE_ARN}",
    "timeoutInMinutes": 60,
    "queuedTimeoutInMinutes": 480,
    "tags": [
        {
            "key": "Purpose",
            "value": "CodeArtifact-Demo"
        },
        {
            "key": "Environment",
            "value": "Demo"
        }
    ]
}
EOF

# Create the project
aws codebuild create-project --cli-input-json file://codebuild-project.json

# Clean up temporary file
rm -f codebuild-project.json

echo "✅ CodeBuild project created successfully!"
echo ""
echo "📋 Project Details:"
echo "   Name: ${PROJECT_NAME}"
echo "   Service Role: ${ROLE_NAME}"
echo "   Source: s3://${INPUT_BUCKET}/codeartifact-demo-source.zip"
echo "   Artifacts: s3://${OUTPUT_BUCKET}/"
echo "   Environment Variable: AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}"
echo ""
echo "🎯 The project is configured with:"
echo "   ✅ CodeArtifact permissions"
echo "   ✅ S3 access to input/output buckets"
echo "   ✅ CloudWatch Logs access"
echo "   ✅ Environment variables for account ID"
echo ""
echo "🔄 Next step: Start a build to test CodeArtifact integration"
