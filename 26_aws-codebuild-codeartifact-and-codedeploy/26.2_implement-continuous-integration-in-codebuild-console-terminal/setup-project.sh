#!/bin/bash

# Setup script for CodeBuild CI Demo
# This script creates the project structure and copies all necessary files

set -e  # Exit on any error

echo "🚀 Setting up CodeBuild CI Demo project..."

# Create project directory structure
echo "📁 Creating project structure..."
mkdir -p codebuild-ci-demo/src/main/java
mkdir -p codebuild-ci-demo/src/test/java

# Copy Java source files
echo "📄 Copying Java source files..."
cp MessageUtil.java codebuild-ci-demo/src/main/java/
cp TestMessageUtil.java codebuild-ci-demo/src/test/java/
cp pom.xml codebuild-ci-demo/
cp buildspec.yml codebuild-ci-demo/

# Change to project directory
cd codebuild-ci-demo

echo "✅ Project structure created successfully!"
echo ""
echo "Project contents:"
find . -type f -name "*.java" -o -name "*.xml" -o -name "*.yml" | sort

echo ""
echo "📂 Project is ready in: $(pwd)"
echo "🔄 Next step: Run create-s3-buckets.sh to create AWS resources"
