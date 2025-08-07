#!/bin/bash

# Script to upload source code to S3 for CodeArtifact demo
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
if [ ! -d "codeartifact-demo" ]; then
    echo "❌ Error: codeartifact-demo directory not found!"
    echo "   Please run setup-project.sh first"
    exit 1
fi

cd codeartifact-demo

# Create zip file excluding git and other unnecessary files
echo "🗜️  Creating source code archive..."
zip -r ../codeartifact-demo-source.zip . -x "*.git*" "*.DS_Store" "__pycache__/*" "*.pyc"

# Go back to parent directory
cd ..

# Upload to S3
echo "☁️  Uploading to S3..."
aws s3 cp codeartifact-demo-source.zip s3://${INPUT_BUCKET}/

# Verify upload
echo "✅ Verifying upload..."
aws s3 ls s3://${INPUT_BUCKET}/codeartifact-demo-source.zip

echo ""
echo "✅ Source code uploaded successfully!"
echo "📄 Archive: codeartifact-demo-source.zip"
echo "🪣 Location: s3://${INPUT_BUCKET}/codeartifact-demo-source.zip"
echo ""
echo "📋 Next steps:"
echo "   1. Ensure CodeArtifact domain and repository are created"
echo "   2. Verify IAM permissions are configured"
echo "   3. Create CodeBuild project in AWS Console"
echo ""
echo "💡 Use show-codeartifact-setup.sh for CodeArtifact configuration guidance"
