#!/bin/bash

# Main demo runner script for CodeBuild and CodeArtifact Integration
# This script guides you through the entire demonstration

set -e  # Exit on any error

echo "🚀 CodeBuild and CodeArtifact Integration Demonstration"
echo "======================================================"
echo ""

# Function to wait for user input
wait_for_user() {
    read -p "Press Enter to continue..." -r
    echo ""
}

# Function to run script with error handling
run_script() {
    local script_name=$1
    local description=$2
    
    echo "🔄 $description"
    echo "   Running: $script_name"
    
    if [ -f "$script_name" ]; then
        chmod +x "$script_name"
        ./"$script_name"
    else
        echo "❌ Error: $script_name not found!"
        exit 1
    fi
    
    echo ""
}

echo "This script will guide you through the CodeBuild and CodeArtifact integration demo."
echo "The demo includes automated steps and manual CodeArtifact configuration."
echo ""

# Step 1: Setup project
echo "📋 Step 1: Setting up project structure and files"
wait_for_user
run_script "setup-project.sh" "Creating project structure and copying Python files"

# Step 2: CodeArtifact setup (MANUAL)
echo "📋 Step 2: CodeArtifact Setup (MANUAL STEPS)"
echo ""
echo "🏗️  Now you need to create CodeArtifact resources manually:"
echo ""
echo "💡 Run the helper script for detailed instructions:"
read -p "Do you want to see CodeArtifact setup instructions? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    run_script "show-codeartifact-setup.sh" "Displaying CodeArtifact setup instructions"
else
    echo "⏭️  Skipping setup instructions"
fi

echo "⚠️  IMPORTANT: Complete these manual steps before continuing:"
echo "   1. Create CodeArtifact domain: demo-domain"
echo "   2. Create CodeArtifact repository: demo-python-repo"
echo "   3. Configure IAM permissions for CodeBuild role"
echo ""
echo "✅ Confirm you have completed the CodeArtifact setup"
wait_for_user

# Step 3: Create S3 buckets
echo "📋 Step 3: Creating S3 buckets for source and artifacts"
wait_for_user
run_script "create-s3-buckets.sh" "Creating S3 buckets with unique names"

# Step 4: Upload source code
echo "📋 Step 4: Uploading source code to S3"
wait_for_user
run_script "upload-source.sh" "Packaging and uploading Python source code"

# Step 5: Create CodeBuild project (AUTOMATED)
echo "📋 Step 5: Creating CodeBuild project (AUTOMATED)"
wait_for_user
run_script "create-codebuild-project.sh" "Creating CodeBuild project with CodeArtifact integration"

# Step 6: Start build
echo "📋 Step 6: Starting CodeBuild build"
wait_for_user
run_script "start-build.sh" "Starting build to test CodeArtifact integration"

# Step 7: Monitor build
echo "📋 Step 7: Monitoring build progress"
echo ""
echo "🔍 You can monitor the build in two ways:"
echo "   1. Watch the AWS Console - recommended for demo"
echo "   2. Use our monitoring script - optional"
echo ""
read -p "Do you want to run the monitoring script? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    run_script "monitor-build.sh" "Monitoring build progress and CodeArtifact integration"
else
    echo "⏭️  Skipping automated monitoring - watch the console instead"
    echo "   🔍 Key things to watch for in the build logs:"
    echo "   • 'Logging in to CodeArtifact...'"
    echo "   • 'Successfully configured pip to use CodeArtifact'"
    echo "   • Package downloads from CodeArtifact URLs"
    echo "   • Test execution results"
    echo "   When the build completes, continue to the next step"
    wait_for_user
fi

# Step 8: Verify artifacts
echo "📋 Step 8: Verifying build artifacts and CodeArtifact integration"
wait_for_user
run_script "verify-artifacts.sh" "Downloading and examining build artifacts"

# Step 9: Cleanup option
echo "📋 Step 9: Cleanup (optional)"
echo ""
echo "🧹 The demo is complete! You can now:"
echo "   1. Keep the resources for further exploration"
echo "   2. Clean up all resources to avoid charges"
echo ""
read -p "Do you want to clean up all resources now? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    run_script "cleanup.sh" "Cleaning up all demo resources"
else
    echo "⚠️  Resources left intact. Run cleanup.sh later to remove them."
    echo "   📦 Remember to manually delete CodeArtifact resources:"
    echo "   • Repository: demo-python-repo"
    echo "   • Domain: demo-domain"
fi

echo ""
echo "🎉 CodeBuild and CodeArtifact Integration Demo Complete!"
echo ""
echo "📚 Key concepts demonstrated:"
echo "   ✅ Private package repository with CodeArtifact (MANUAL)"
echo "   ✅ Secure authentication from CodeBuild to CodeArtifact"
echo "   ✅ Automated CodeBuild project creation with proper IAM roles"
echo "   ✅ Python dependency management"
echo "   ✅ Automated testing with private packages"
echo "   ✅ Lambda deployment package creation"
echo "   ✅ Cost optimization through package caching"
echo ""
echo "💡 Next steps: Explore CodeArtifact features like:"
echo "   - Publishing custom packages"
echo "   - Cross-account repository sharing"
echo "   - Package retention policies"
echo "   - Integration with other build tools (Maven, npm)"
