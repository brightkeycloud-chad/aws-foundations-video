#!/bin/bash

# Helper script to display buildspec.yml contents
# Useful for reference during CodeBuild project creation

set -e  # Exit on any error

echo "📄 BuildSpec File Contents"
echo "=========================="
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
    echo "   • install: Sets up the Java runtime environment (corretto8)"
    echo "   • pre_build: Compiles the Java source code (mvn clean compile)"
    echo "   • build: Runs the unit tests (mvn test)"
    echo "   • post_build: Packages the application into a JAR file (mvn package)"
    echo ""
    echo "📦 ARTIFACTS:"
    echo "   • Outputs the compiled JAR file: target/messageUtil-1.0.jar"
    echo ""
    echo "⚙️  RUNTIME VERSIONS:"
    echo "   • Java: Amazon Corretto 8 (OpenJDK 8)"
    echo ""
    echo "🎯 BUILD PROCESS:"
    echo "   1. CodeBuild downloads source from S3"
    echo "   2. Reads this buildspec.yml file"
    echo "   3. Executes each phase in order"
    echo "   4. Uploads artifacts to output S3 bucket"
    echo ""
    echo "💡 IMPORTANT FOR CONSOLE SETUP:"
    echo "   • Select 'Use a buildspec file' in CodeBuild console"
    echo "   • Leave 'Buildspec name' blank (uses buildspec.yml by default)"
    echo "   • The file is already included in your source zip"
elif [ -f "codebuild-ci-demo/buildspec.yml" ]; then
    echo "🔍 Contents of codebuild-ci-demo/buildspec.yml:"
    echo ""
    cat codebuild-ci-demo/buildspec.yml
    echo ""
    echo "📋 This buildspec.yml file is included in your source code zip file."
else
    echo "❌ buildspec.yml not found!"
    echo "   Please run setup-project.sh first to create the buildspec file."
    exit 1
fi

echo ""
echo "🔄 This script is for reference only. No changes made."
