#!/bin/bash

set -e

echo "🧹 Starting cleanup process..."

# Check if terraform-outputs.json exists
if [ ! -f terraform-outputs.json ]; then
    echo "⚠️  terraform-outputs.json not found. Attempting cleanup anyway..."
fi

# Clean up S3 bucket contents if it exists
if [ -f terraform-outputs.json ]; then
    S3_BUCKET=$(jq -r '.s3_bucket_name.value' terraform-outputs.json)
    echo "🗑️  Emptying S3 bucket: $S3_BUCKET"
    aws s3 rm s3://$S3_BUCKET --recursive || echo "⚠️  Could not empty S3 bucket"
fi

# Destroy Terraform infrastructure
echo "💥 Destroying Terraform infrastructure..."
cd terraform
terraform destroy -auto-approve -input=false || echo "⚠️  Some resources may not have been destroyed"
cd ..

# Clean up local files
echo "🧽 Cleaning up local files..."
rm -f terraform-outputs.json
rm -f response.json
rm -f lambda-v2.zip
rm -f terraform/lambda-v1.zip

echo "✅ Cleanup completed!"
echo "🎉 Demo environment has been cleaned up."
