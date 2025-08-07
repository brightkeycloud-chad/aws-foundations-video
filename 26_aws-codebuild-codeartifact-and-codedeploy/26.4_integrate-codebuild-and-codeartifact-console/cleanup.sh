#!/bin/bash

# Cleanup script for CodeArtifact Integration Demo
# This script removes all AWS resources and local files created during the demo

set -e  # Exit on any error

echo "🧹 Cleaning up CodeArtifact Integration Demo resources..."
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

PROJECT_NAME="codeartifact-integration-demo"

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

# Delete CodeBuild service role
ROLE_NAME="CodeBuildServiceRole-CodeArtifactDemo"
echo ""
echo "🔐 Cleaning up CodeBuild service role..."
if aws iam get-role --role-name ${ROLE_NAME} >/dev/null 2>&1; then
    echo "   Cleaning up policies for role: ${ROLE_NAME}"
    
    # List and delete all inline policies
    echo "   Deleting inline policies..."
    INLINE_POLICIES=$(aws iam list-role-policies --role-name ${ROLE_NAME} --query 'PolicyNames' --output text 2>/dev/null || echo "")
    if [ -n "$INLINE_POLICIES" ] && [ "$INLINE_POLICIES" != "None" ]; then
        for policy in $INLINE_POLICIES; do
            echo "     Deleting inline policy: $policy"
            aws iam delete-role-policy --role-name ${ROLE_NAME} --policy-name $policy 2>/dev/null || true
        done
    fi
    
    # List and detach all attached managed policies
    echo "   Detaching managed policies..."
    ATTACHED_POLICIES=$(aws iam list-attached-role-policies --role-name ${ROLE_NAME} --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null || echo "")
    if [ -n "$ATTACHED_POLICIES" ] && [ "$ATTACHED_POLICIES" != "None" ]; then
        for policy_arn in $ATTACHED_POLICIES; do
            echo "     Detaching managed policy: $policy_arn"
            aws iam detach-role-policy --role-name ${ROLE_NAME} --policy-arn $policy_arn 2>/dev/null || true
        done
    fi
    
    # Wait a moment for policy deletions to propagate
    echo "   Waiting for policy deletions to propagate..."
    sleep 5
    
    # Delete the role
    echo "   Deleting service role: ${ROLE_NAME}"
    aws iam delete-role --role-name ${ROLE_NAME}
    echo "✅ Service role deleted"
else
    echo "⚠️  Service role '${ROLE_NAME}' not found, skipping"
fi

# Note about CodeArtifact cleanup
echo ""
echo "📦 CodeArtifact Resources (MANUAL CLEANUP REQUIRED):"
echo "   ⚠️  The following resources need to be deleted manually:"
echo "   • CodeArtifact Repository: demo-python-repo"
echo "   • CodeArtifact Domain: demo-domain"
echo ""
echo "   To delete via console:"
echo "   1. Go to CodeArtifact → Repositories → demo-python-repo → Delete"
echo "   2. Go to CodeArtifact → Domains → demo-domain → Delete"
echo ""
echo "   To delete via CLI:"
echo "   aws codeartifact delete-repository --domain demo-domain --repository demo-python-repo"
echo "   aws codeartifact delete-domain --domain demo-domain"

# Clean up local files
echo ""
echo "📁 Cleaning up local files..."

# Remove generated files
rm -f bucket-names.txt
rm -f codeartifact-demo-source.zip
rm -f current-build.txt
rm -f *.zip
rm -f deployment-package.zip

# Remove extracted artifacts
if [ -d "extracted-artifacts" ]; then
    rm -rf extracted-artifacts
    echo "   Removed: extracted-artifacts/"
fi

# Remove project directory
if [ -d "codeartifact-demo" ]; then
    rm -rf codeartifact-demo
    echo "   Removed: codeartifact-demo/"
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
echo "   ⚠️  CodeArtifact resources (manual cleanup required)"
echo ""
echo "💡 You can now run setup-project.sh to start a new demo"
