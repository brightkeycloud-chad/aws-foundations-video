#!/bin/bash

# AWS CodePipeline Demo Cleanup Script
# This script removes all files and resources created during the demonstration

set -e

echo "🧹 Starting AWS CodePipeline Demo Cleanup"
echo "========================================="

# Function to check if user wants to proceed
confirm_cleanup() {
    echo ""
    echo "⚠️  This will:"
    echo "   • Destroy the AWS CloudFormation stack (CodepipelineDemoStack)"
    echo "   • Remove the Python virtual environment (.venv/)"
    echo "   • Remove CDK output files (cdk.out/)"
    echo "   • Remove the generated source.zip file"
    echo ""
    read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cleanup cancelled"
        exit 1
    fi
}

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Cannot destroy AWS resources."
    echo "ℹ️  Will only clean up local files."
    LOCAL_ONLY=true
else
    LOCAL_ONLY=false
fi

# Check if CDK is available
if ! command -v cdk &> /dev/null; then
    echo "❌ AWS CDK is not installed. Cannot destroy CDK stack."
    echo "ℹ️  Will only clean up local files."
    LOCAL_ONLY=true
fi

# Show what will be cleaned up
confirm_cleanup

echo "🚀 Starting cleanup process..."

# 1. Destroy AWS resources (if CDK and AWS CLI are available)
if [ "$LOCAL_ONLY" = false ]; then
    echo "☁️  Destroying AWS CloudFormation stack..."
    
    # Check if the stack exists
    if aws cloudformation describe-stacks --stack-name CodepipelineDemoStack &> /dev/null; then
        echo "📤 Found CodepipelineDemoStack, destroying..."
        cdk destroy --force
        echo "✅ AWS resources destroyed"
    else
        echo "ℹ️  No CodepipelineDemoStack found, skipping AWS cleanup"
    fi
else
    echo "⚠️  Skipping AWS resource cleanup (CDK/AWS CLI not available)"
    echo "ℹ️  Please manually delete the CodepipelineDemoStack from AWS Console if it exists"
fi

# 2. Remove Python virtual environment
if [ -d ".venv" ]; then
    echo "🐍 Removing Python virtual environment..."
    rm -rf .venv
    echo "✅ Virtual environment removed"
else
    echo "ℹ️  No virtual environment found"
fi

# 3. Remove CDK output directory
if [ -d "cdk.out" ]; then
    echo "📁 Removing CDK output directory..."
    rm -rf cdk.out
    echo "✅ CDK output directory removed"
else
    echo "ℹ️  No CDK output directory found"
fi

# 4. Remove generated source.zip file
if [ -f "source.zip" ]; then
    echo "📦 Removing generated source.zip..."
    rm -f source.zip
    echo "✅ source.zip removed"
else
    echo "ℹ️  No source.zip file found"
fi

# 5. Remove any Python cache files
echo "🗑️  Removing Python cache files..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true
echo "✅ Python cache files removed"

# 6. Remove any CDK context files (optional - these can be kept for future use)
read -p "🤔 Remove CDK context file (cdk.context.json)? This will require re-lookup of AMIs, etc. (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "cdk.context.json" ]; then
        rm -f cdk.context.json
        echo "✅ CDK context file removed"
    else
        echo "ℹ️  No CDK context file found"
    fi
else
    echo "ℹ️  Keeping CDK context file"
fi

echo ""
echo "🎉 Cleanup completed successfully!"
echo "=================================="
echo ""
echo "📋 Summary of cleaned up items:"
echo "   • AWS CloudFormation stack (if existed)"
echo "   • Python virtual environment (.venv/)"
echo "   • CDK output files (cdk.out/)"
echo "   • Generated source.zip file"
echo "   • Python cache files (__pycache__, *.pyc)"
echo ""
echo "📁 Remaining files (preserved):"
echo "   • README.md - Documentation"
echo "   • DEMO_GUIDE.md - Demo instructions"
echo "   • app.py - CDK application entry point"
echo "   • cdk.json - CDK configuration"
echo "   • requirements.txt - Python dependencies"
echo "   • deploy.sh - Deployment script"
echo "   • cleanup.sh - This cleanup script"
echo "   • codepipeline_demo/ - CDK stack code"
echo "   • sample-source/ - Sample application source"
echo ""
echo "ℹ️  The demonstration can be run again by executing ./deploy.sh"
