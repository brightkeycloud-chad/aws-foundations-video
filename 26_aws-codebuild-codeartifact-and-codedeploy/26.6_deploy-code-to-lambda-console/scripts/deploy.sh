#!/bin/bash

set -e

echo "🚀 Starting AWS CodeDeploy Lambda Demo Setup..."

# Check prerequisites
echo "📋 Checking prerequisites..."
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed."; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI is required but not installed."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "❌ jq is required but not installed."; exit 1; }

# Check AWS credentials
aws sts get-caller-identity >/dev/null 2>&1 || { echo "❌ AWS credentials not configured."; exit 1; }

echo "✅ Prerequisites check passed!"

# Deploy infrastructure with Terraform
echo "🏗️  Deploying infrastructure with Terraform..."
cd terraform

terraform init -input=false
terraform plan -input=false
terraform apply -auto-approve -input=false

echo "📝 Saving Terraform outputs..."
terraform output -json > ../terraform-outputs.json

cd ..

echo "✅ Initial deployment completed!"
echo "🎯 Lambda function deployed: $(jq -r '.lambda_function_name.value' terraform-outputs.json)"
echo "📦 CodeDeploy application: $(jq -r '.codedeploy_app_name.value' terraform-outputs.json)"

echo ""
echo "🧪 Test the initial function with:"
echo "aws lambda invoke --function-name codedeploy-lambda-demo response.json && cat response.json"
