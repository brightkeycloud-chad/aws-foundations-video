#!/bin/bash

# Setup script for CodeBuild and CodeArtifact Integration Demo
# This script creates the project structure and copies all necessary files

set -e  # Exit on any error

echo "🚀 Setting up CodeBuild and CodeArtifact Integration Demo..."

# Create project directory structure
echo "📁 Creating project structure..."
mkdir -p codeartifact-demo

# Copy Python source files
echo "📄 Copying Python source files..."
cp app.py codeartifact-demo/
cp test_app.py codeartifact-demo/
cp requirements.txt codeartifact-demo/
cp buildspec.yml codeartifact-demo/

# Change to project directory
cd codeartifact-demo

echo "✅ Project structure created successfully!"
echo ""
echo "Project contents:"
find . -type f -name "*.py" -o -name "*.txt" -o -name "*.yml" | sort

echo ""
echo "📂 Project is ready in: $(pwd)"
echo ""
echo "📋 Next steps:"
echo "   1. Create CodeArtifact domain and repository (MANUAL)"
echo "   2. Run create-s3-buckets.sh to create AWS resources"
echo ""
echo "💡 Use show-buildspec.sh to review the build specification"
