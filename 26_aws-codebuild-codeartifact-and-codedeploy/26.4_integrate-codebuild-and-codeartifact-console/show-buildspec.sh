#!/bin/bash

# Helper script to display buildspec.yml contents for CodeArtifact demo
# Useful for reference during CodeBuild project creation

set -e  # Exit on any error

echo "📄 BuildSpec File Contents - CodeArtifact Integration"
echo "====================================================="
echo ""

if [ -f "buildspec.yml" ]; then
    echo "🔍 Contents of buildspec.yml:"
    echo ""
    cat buildspec.yml
    echo ""
    echo "📋 BuildSpec Explanation:"
    echo "========================"
    echo ""
    echo "🔧 PHASES:"
    echo "   • install: Sets up Python 3.9 runtime environment"
    echo "   • pre_build: Logs into CodeArtifact and installs dependencies"
    echo "   • build: Runs pytest unit tests"
    echo "   • post_build: Creates deployment package with dependencies"
    echo ""
    echo "🔐 CODEARTIFACT INTEGRATION:"
    echo "   • Uses 'aws codeartifact login' to configure pip"
    echo "   • Authenticates with demo-domain/demo-python-repo"
    echo "   • Requires AWS_ACCOUNT_ID environment variable"
    echo ""
    echo "📦 ARTIFACTS:"
    echo "   • deployment-package.zip: Lambda deployment package"
    echo "   • app.py: Source code"
    echo "   • requirements.txt: Dependencies list"
    echo ""
    echo "🐍 PYTHON DEPENDENCIES:"
    echo "   • requests: HTTP client library"
    echo "   • boto3: AWS SDK for Python"
    echo "   • pytest: Testing framework"
    echo ""
    echo "💡 IMPORTANT FOR CONSOLE SETUP:"
    echo "   • Select 'Use a buildspec file' in CodeBuild console"
    echo "   • Leave 'Buildspec name' blank (uses buildspec.yml by default)"
    echo "   • Set AWS_ACCOUNT_ID environment variable"
    echo "   • Ensure CodeBuild role has CodeArtifact permissions"
elif [ -f "codeartifact-demo/buildspec.yml" ]; then
    echo "🔍 Contents of codeartifact-demo/buildspec.yml:"
    echo ""
    cat codeartifact-demo/buildspec.yml
    echo ""
    echo "📋 This buildspec.yml file is included in your source code zip file."
else
    echo "❌ buildspec.yml not found!"
    echo "   Please run setup-project.sh first to create the buildspec file."
    exit 1
fi

echo ""
echo "🔄 This script is for reference only. No changes made."
