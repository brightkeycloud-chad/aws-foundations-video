#!/bin/bash

# Script to start a CodeBuild build for the CodeArtifact integration demo
# This script triggers the build and provides the build ID for monitoring

set -e  # Exit on any error

PROJECT_NAME="codeartifact-integration-demo"

echo "🚀 Starting CodeBuild build for CodeArtifact integration demo..."

# Check if project exists
if ! aws codebuild batch-get-projects --names ${PROJECT_NAME} --query 'projects[0].name' --output text >/dev/null 2>&1; then
    echo "❌ CodeBuild project '${PROJECT_NAME}' not found!"
    echo "   Please run create-codebuild-project.sh first"
    exit 1
fi

echo "✅ Project found: ${PROJECT_NAME}"

# Start the build
echo "🔨 Starting build..."
BUILD_ID=$(aws codebuild start-build --project-name ${PROJECT_NAME} --query 'build.id' --output text)

if [ -z "$BUILD_ID" ]; then
    echo "❌ Failed to start build"
    exit 1
fi

echo "✅ Build started successfully!"
echo ""
echo "📋 Build Information:"
echo "   Project: ${PROJECT_NAME}"
echo "   Build ID: ${BUILD_ID}"
echo ""
echo "🔍 You can monitor the build in several ways:"
echo ""
echo "1. 📊 AWS Console:"
echo "   https://console.aws.amazon.com/codesuite/codebuild/projects/${PROJECT_NAME}/build/${BUILD_ID}"
echo ""
echo "2. 🖥️  Command Line Monitoring:"
echo "   ./monitor-build.sh"
echo ""
echo "3. 📋 Manual Status Check:"
echo "   aws codebuild batch-get-builds --ids ${BUILD_ID}"
echo ""
echo "🎯 Key things to watch for in the build logs:"
echo "   • 'Logging in to CodeArtifact...'"
echo "   • 'Successfully configured pip to use CodeArtifact'"
echo "   • Package downloads from CodeArtifact URLs"
echo "   • 'Running tests...'"
echo "   • 'Creating deployment package...'"
echo ""
echo "⏱️  Expected build time: 2-3 minutes"

# Save build ID for other scripts
echo "BUILD_ID=${BUILD_ID}" > current-build.txt
echo ""
echo "💾 Build ID saved to current-build.txt for reference"
