#!/bin/bash

# Main demo runner script
# This script guides you through the entire CodeBuild CI demonstration

set -e  # Exit on any error

echo "🚀 CodeBuild CI Demonstration Runner"
echo "===================================="
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

echo "This script will guide you through the complete CodeBuild CI demonstration."
echo "The demo consists of several automated steps and some manual console work."
echo ""

# Step 1: Setup project
echo "📋 Step 1: Setting up project structure and files"
wait_for_user
run_script "setup-project.sh" "Creating project structure and copying files"

# Step 2: Create S3 buckets
echo "📋 Step 2: Creating S3 buckets for source and artifacts"
wait_for_user
run_script "create-s3-buckets.sh" "Creating S3 buckets with unique names"

# Step 3: Upload source code
echo "📋 Step 3: Uploading source code to S3"
wait_for_user
run_script "upload-source.sh" "Packaging and uploading source code"

# Step 4: Manual console work
echo "📋 Step 4: Create CodeBuild project (MANUAL STEP)"
echo ""
echo "🖥️  Now you need to create the CodeBuild project in the AWS Console:"
echo ""
echo "1. Open AWS Console → CodeBuild → Build projects → Create build project"
echo ""
echo "2. PROJECT CONFIGURATION:"
echo "   - Project name: codebuild-ci-demo"
echo "   - Description: CI demonstration project"
echo ""
echo "3. SOURCE CONFIGURATION:"

if [ -f "bucket-names.txt" ]; then
    source bucket-names.txt
    echo "   - Source provider: Amazon S3"
    echo "   - Bucket: ${INPUT_BUCKET}"
    echo "   - S3 object key: codebuild-demo-source.zip"
    echo "   - Source version: (leave blank)"
    echo ""
    echo "4. ENVIRONMENT CONFIGURATION:"
    echo "   - Environment image: Managed image"
    echo "   - Operating system: Amazon Linux 2"
    echo "   - Runtime(s): Standard"
    echo "   - Image: aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    echo "   - Environment type: Linux"
    echo "   - Service role: Create new service role"
    echo ""
    echo "5. BUILDSPEC CONFIGURATION:"
    echo "   ⚠️  IMPORTANT: Select 'Use a buildspec file'"
    echo "   - Build specifications: Use a buildspec file"
    echo "   - Buildspec name: (leave blank - uses buildspec.yml from source)"
    echo "   📝 The buildspec.yml file is already in your uploaded source code"
    echo ""
    echo "6. ARTIFACTS CONFIGURATION:"
    echo "   - Type: Amazon S3"
    echo "   - Bucket name: ${OUTPUT_BUCKET}"
    echo "   - Name: codebuild-demo-output.zip"
    echo "   - Artifacts packaging: Zip"
    echo ""
    echo "7. LOGS (Optional but recommended):"
    echo "   - CloudWatch Logs: Enabled"
    echo ""
    echo "8. Click 'Create build project'"
else
    echo "   ❌ Error: Could not load bucket names"
fi

echo ""
echo "📄 BUILDSPEC FILE CONTENTS (for reference):"
echo "   The buildspec.yml file in your source contains:"
echo "   - install: Sets up Java runtime (corretto8)"
echo "   - pre_build: Compiles the code (mvn clean compile)"
echo "   - build: Runs tests (mvn test)"
echo "   - post_build: Packages JAR (mvn package)"
echo "   - artifacts: Outputs messageUtil-1.0.jar"
echo ""
echo "🚀 After creating the project, START A BUILD to continue the demo"
echo ""
wait_for_user

# Step 5: Monitor build
echo "📋 Step 5: Monitoring build progress"
echo ""
echo "🔍 You can monitor the build in two ways:"
echo "   1. Watch the AWS Console - recommended for demo"
echo "   2. Use our monitoring script - optional"
echo ""
read -p "Do you want to run the monitoring script? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    run_script "monitor-build.sh" "Monitoring build progress from command line"
else
    echo "⏭️  Skipping automated monitoring - watch the console instead"
    echo "   When the build completes, continue to the next step"
    wait_for_user
fi

# Step 6: Verify artifacts
echo "📋 Step 6: Verifying build artifacts"
wait_for_user
run_script "verify-artifacts.sh" "Downloading and examining build artifacts"

# Step 7: Cleanup option
echo "📋 Step 7: Cleanup - optional"
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
fi

echo ""
echo "🎉 CodeBuild CI Demonstration Complete!"
echo ""
echo "📚 Key concepts demonstrated:"
echo "   ✅ Continuous Integration with CodeBuild"
echo "   ✅ BuildSpec file configuration"
echo "   ✅ S3 integration for source and artifacts"
echo "   ✅ Maven build process"
echo "   ✅ Automated testing"
echo "   ✅ Build monitoring and artifact management"
echo ""
echo "💡 Next steps: Explore CodeBuild features like:"
echo "   - Environment variables"
echo "   - Build caching"
echo "   - Integration with CodePipeline"
echo "   - Custom Docker images"
