#!/bin/bash

# Cleanup script for CodeBuild CI Demo
# This script removes all AWS resources and local files created during the demo

set -e  # Exit on any error

echo "🧹 Cleaning up CodeBuild CI Demo resources..."
echo ""

# Function to confirm deletion
confirm_deletion() {
    read -p "⚠️  Are you sure you want to delete all demo resources? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cleanup cancelled"
        exit 1
    fi
}

# Confirm with user
confirm_deletion

PROJECT_NAME="codebuild-ci-demo"

# Check if bucket names file exists
if [ -f "bucket-names.txt" ]; then
    echo "🪣 Cleaning up S3 buckets..."
    source bucket-names.txt
    
    # Delete S3 bucket contents and buckets
    echo "   Emptying input bucket: ${INPUT_BUCKET}"
    aws s3 rm s3://${INPUT_BUCKET} --recursive 2>/dev/null || echo "   Input bucket already empty or doesn't exist"
    
    echo "   Emptying output bucket: ${OUTPUT_BUCKET}"
    aws s3 rm s3://${OUTPUT_BUCKET} --recursive 2>/dev/null || echo "   Output bucket already empty or doesn't exist"
    
    echo "   Deleting input bucket: ${INPUT_BUCKET}"
    aws s3 rb s3://${INPUT_BUCKET} 2>/dev/null || echo "   Input bucket already deleted or doesn't exist"
    
    echo "   Deleting output bucket: ${OUTPUT_BUCKET}"
    aws s3 rb s3://${OUTPUT_BUCKET} 2>/dev/null || echo "   Output bucket already deleted or doesn't exist"
    
    echo "✅ S3 buckets cleaned up"
else
    echo "⚠️  No bucket-names.txt found, skipping S3 cleanup"
fi

# Delete CodeBuild project
echo ""
echo "🔨 Cleaning up CodeBuild project..."
if aws codebuild batch-get-projects --names ${PROJECT_NAME} --query 'projects[0].name' --output text >/dev/null 2>&1; then
    echo "   Deleting CodeBuild project: ${PROJECT_NAME}"
    aws codebuild delete-project --name ${PROJECT_NAME}
    echo "✅ CodeBuild project deleted"
else
    echo "⚠️  CodeBuild project '${PROJECT_NAME}' not found, skipping"
fi

# Clean up local files
echo ""
echo "📁 Cleaning up local files..."

# Remove generated files
rm -f bucket-names.txt
rm -f codebuild-demo-source.zip
rm -f *.jar
rm -f *.zip

# Remove extracted artifacts
if [ -d "extracted-artifacts" ]; then
    rm -rf extracted-artifacts
    echo "   Removed: extracted-artifacts/"
fi

# Remove project directory
if [ -d "codebuild-ci-demo" ]; then
    rm -rf codebuild-ci-demo
    echo "   Removed: codebuild-ci-demo/"
fi

echo "✅ Local files cleaned up"

echo ""
echo "🎉 Cleanup completed successfully!"
echo ""
echo "📋 Summary of cleaned up resources:"
echo "   ✅ S3 buckets (input and output)"
echo "   ✅ CodeBuild project"
echo "   ✅ Local project files"
echo "   ✅ Downloaded artifacts"
echo ""
echo "💡 You can now run setup-project.sh to start a new demo"
