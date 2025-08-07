#!/bin/bash

# Script to monitor CodeBuild project status for CodeArtifact demo
# This script helps track build progress from the command line

set -e  # Exit on any error

PROJECT_NAME="codeartifact-integration-demo"

echo "👀 Monitoring CodeBuild project: ${PROJECT_NAME}"
echo ""

# Function to get latest build
get_latest_build() {
    # First check if we have a current build ID from start-build.sh
    if [ -f "current-build.txt" ]; then
        source current-build.txt
        if [ -n "$BUILD_ID" ]; then
            echo "$BUILD_ID"
            return
        fi
    fi
    
    # Fall back to getting the latest build from the project
    aws codebuild list-builds-for-project --project-name ${PROJECT_NAME} \
        --query 'ids[0]' --output text 2>/dev/null || echo "NONE"
}

# Function to get build status
get_build_status() {
    local build_id=$1
    if [ "$build_id" != "NONE" ] && [ "$build_id" != "None" ]; then
        aws codebuild batch-get-builds --ids ${build_id} \
            --query 'builds[0].buildStatus' --output text 2>/dev/null || echo "UNKNOWN"
    else
        echo "NO_BUILD"
    fi
}

# Function to get build details
show_build_details() {
    local build_id=$1
    if [ "$build_id" != "NONE" ] && [ "$build_id" != "None" ]; then
        echo "📊 Build Details:"
        aws codebuild batch-get-builds --ids ${build_id} \
            --query 'builds[0].{Status:buildStatus,Phase:currentPhase,StartTime:startTime,EndTime:endTime}' \
            --output table 2>/dev/null || echo "   Unable to fetch build details"
    fi
}

# Check if project exists
echo "🔍 Checking if project exists..."
if ! aws codebuild batch-get-projects --names ${PROJECT_NAME} --query 'projects[0].name' --output text >/dev/null 2>&1; then
    echo "❌ CodeBuild project '${PROJECT_NAME}' not found!"
    echo "   Please create the project in AWS Console first"
    echo "   Expected project name: ${PROJECT_NAME}"
    exit 1
fi

echo "✅ Project found!"
echo ""

# Get latest build
LATEST_BUILD=$(get_latest_build)

if [ "$LATEST_BUILD" = "NONE" ] || [ "$LATEST_BUILD" = "None" ]; then
    echo "📋 No builds found for project ${PROJECT_NAME}"
    echo "   Start a build from the AWS Console to monitor it here"
    exit 0
fi

echo "🔨 Latest build ID: ${LATEST_BUILD}"
echo ""

# Monitor build status
echo "⏱️  Monitoring build status (press Ctrl+C to stop)..."
echo "🔍 Watch for CodeArtifact login messages in the build logs"
echo ""

while true; do
    STATUS=$(get_build_status ${LATEST_BUILD})
    TIMESTAMP=$(date '+%H:%M:%S')
    
    case $STATUS in
        "IN_PROGRESS")
            echo "[$TIMESTAMP] 🔄 Build in progress..."
            echo "                💡 Check console logs for CodeArtifact authentication"
            ;;
        "SUCCEEDED")
            echo "[$TIMESTAMP] ✅ Build succeeded!"
            echo "                🎉 CodeArtifact integration worked!"
            show_build_details ${LATEST_BUILD}
            break
            ;;
        "FAILED")
            echo "[$TIMESTAMP] ❌ Build failed!"
            echo "                🔍 Check logs for CodeArtifact authentication issues"
            show_build_details ${LATEST_BUILD}
            break
            ;;
        "FAULT")
            echo "[$TIMESTAMP] ⚠️  Build fault!"
            show_build_details ${LATEST_BUILD}
            break
            ;;
        "STOPPED")
            echo "[$TIMESTAMP] ⏹️  Build stopped!"
            show_build_details ${LATEST_BUILD}
            break
            ;;
        "TIMED_OUT")
            echo "[$TIMESTAMP] ⏰ Build timed out!"
            show_build_details ${LATEST_BUILD}
            break
            ;;
        *)
            echo "[$TIMESTAMP] ❓ Unknown status: $STATUS"
            ;;
    esac
    
    sleep 10
done

echo ""
echo "🔄 To check build artifacts, run: verify-artifacts.sh"
