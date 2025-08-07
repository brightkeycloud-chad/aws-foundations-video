#!/bin/bash

# Script to create S3 buckets for CodeBuild demo
# This script creates unique bucket names and stores them for later use

set -e  # Exit on any error

echo "🪣 Creating S3 buckets for CodeBuild demo..."

# Generate unique bucket names with timestamp
TIMESTAMP=$(date +%Y%m%d%H%M%S)
INPUT_BUCKET="codebuild-demo-input-${TIMESTAMP}"
OUTPUT_BUCKET="codebuild-demo-output-${TIMESTAMP}"

echo "📝 Bucket names:"
echo "   Input bucket:  ${INPUT_BUCKET}"
echo "   Output bucket: ${OUTPUT_BUCKET}"

# Create buckets
echo "🔨 Creating input bucket..."
aws s3 mb s3://${INPUT_BUCKET}

echo "🔨 Creating output bucket..."
aws s3 mb s3://${OUTPUT_BUCKET}

# Save bucket names to file for other scripts to use
echo "💾 Saving bucket names to bucket-names.txt..."
cat > bucket-names.txt << EOF
INPUT_BUCKET=${INPUT_BUCKET}
OUTPUT_BUCKET=${OUTPUT_BUCKET}
EOF

echo "✅ S3 buckets created successfully!"
echo ""
echo "📄 Bucket names saved to: bucket-names.txt"
echo "🔄 Next step: Run upload-source.sh to upload project files"
