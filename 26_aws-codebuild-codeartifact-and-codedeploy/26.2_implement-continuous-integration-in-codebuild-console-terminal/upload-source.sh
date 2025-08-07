#!/bin/bash

# Script to upload source code to S3 for CodeBuild
# This script packages the project and uploads it to the input bucket

set -e  # Exit on any error

echo "📦 Uploading source code to S3..."

# Check if bucket names file exists
if [ ! -f "bucket-names.txt" ]; then
    echo "❌ Error: bucket-names.txt not found!"
    echo "   Please run create-s3-buckets.sh first"
    exit 1
fi

# Load bucket names
source bucket-names.txt

echo "📁 Using input bucket: ${INPUT_BUCKET}"

# Change to project directory
if [ ! -d "codebuild-ci-demo" ]; then
    echo "❌ Error: codebuild-ci-demo directory not found!"
    echo "   Please run setup-project.sh first"
    exit 1
fi

cd codebuild-ci-demo

# Create zip file excluding git and other unnecessary files
echo "🗜️  Creating source code archive..."
zip -r ../codebuild-demo-source.zip . -x "*.git*" "*.DS_Store" "target/*"

# Go back to parent directory
cd ..

# Upload to S3
echo "☁️  Uploading to S3..."
aws s3 cp codebuild-demo-source.zip s3://${INPUT_BUCKET}/

# Verify upload
echo "✅ Verifying upload..."
aws s3 ls s3://${INPUT_BUCKET}/codebuild-demo-source.zip

echo ""
echo "✅ Source code uploaded successfully!"
echo "📄 Archive: codebuild-demo-source.zip"
echo "🪣 Location: s3://${INPUT_BUCKET}/codebuild-demo-source.zip"
echo ""
echo "🔄 Next step: Create CodeBuild project in AWS Console using:"
echo "   Source bucket: ${INPUT_BUCKET}"
echo "   Output bucket: ${OUTPUT_BUCKET}"
