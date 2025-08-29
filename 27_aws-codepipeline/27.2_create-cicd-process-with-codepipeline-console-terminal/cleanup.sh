#!/bin/bash

# AWS CodePipeline Demo Cleanup Script
set -e

echo "🧹 Starting AWS CodePipeline Demo Cleanup"
echo "========================================="

# Destroy AWS resources using CloudFormation directly (more reliable than CDK)
echo "☁️  Destroying AWS CloudFormation stack..."
if aws cloudformation describe-stacks --stack-name CodepipelineDemoStack &> /dev/null 2>&1; then
    echo "📤 Found CodepipelineDemoStack, destroying..."
    aws cloudformation delete-stack --stack-name CodepipelineDemoStack
    echo "⏳ Waiting for stack deletion to complete..."
    aws cloudformation wait stack-delete-complete --stack-name CodepipelineDemoStack
    echo "✅ AWS resources destroyed"
else
    echo "ℹ️  No stack found to destroy"
fi

# Remove local files
echo "🗑️  Cleaning up local files..."
rm -rf .venv cdk.out source.zip
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true

echo "✅ Cleanup completed! Ready for fresh deployment."
