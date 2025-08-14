#!/bin/bash

# Terraform Cleanup Script for Inspector Demo
# This script safely destroys all Terraform-managed resources

set -e

echo "🧹 Cleaning up Terraform-managed vulnerable resources..."

# Check if we're in the terraform directory
if [ ! -f "main.tf" ]; then
    echo "❌ This script must be run from the terraform directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected files: main.tf, variables.tf, outputs.tf"
    exit 1
fi

# Function to check if Terraform is installed
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        echo "❌ Terraform is not installed or not in PATH"
        echo "   Please install Terraform: https://www.terraform.io/downloads"
        exit 1
    fi
    echo "✅ Terraform found: $(terraform version -json | jq -r '.terraform_version')"
}

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
    echo "✅ AWS CLI configured successfully"
}

# Function to show current Terraform state
show_current_state() {
    echo "🔄 Checking current Terraform state..."
    
    if [ ! -f "terraform.tfstate" ]; then
        echo "  ℹ️  No terraform.tfstate file found"
        echo "  ℹ️  Either resources were never created or state file is missing"
        return 0
    fi
    
    # Initialize if needed
    if [ ! -d ".terraform" ]; then
        echo "  🔄 Initializing Terraform..."
        terraform init
    fi
    
    # Show current resources
    echo "  📋 Current resources in state:"
    terraform state list 2>/dev/null || echo "  ℹ️  No resources in state"
}

# Function to plan destruction
plan_destruction() {
    echo "🔄 Planning resource destruction..."
    
    if [ ! -f "terraform.tfstate" ]; then
        echo "  ℹ️  No state file found - nothing to destroy"
        return 0
    fi
    
    # Create destruction plan
    terraform plan -destroy -out=destroy.tfplan
    
    echo ""
    echo "📋 Resources to be destroyed:"
    terraform show -json destroy.tfplan | jq -r '.resource_changes[] | select(.change.actions[] == "delete") | .address'
}

# Function to execute destruction
execute_destruction() {
    echo "🔄 Executing resource destruction..."
    
    if [ ! -f "destroy.tfplan" ]; then
        echo "  ℹ️  No destruction plan found - running direct destroy"
        terraform destroy -auto-approve
    else
        terraform apply destroy.tfplan
        rm -f destroy.tfplan
    fi
    
    echo "  ✅ All Terraform resources destroyed"
}

# Function to clean up Terraform files
cleanup_terraform_files() {
    echo "🔄 Cleaning up Terraform files..."
    
    # Remove state files
    if [ -f "terraform.tfstate" ]; then
        echo "  🗑️  Removing terraform.tfstate"
        rm -f terraform.tfstate
    fi
    
    if [ -f "terraform.tfstate.backup" ]; then
        echo "  🗑️  Removing terraform.tfstate.backup"
        rm -f terraform.tfstate.backup
    fi
    
    # Remove plan files
    if [ -f "destroy.tfplan" ]; then
        echo "  🗑️  Removing destroy.tfplan"
        rm -f destroy.tfplan
    fi
    
    # Remove .terraform directory
    if [ -d ".terraform" ]; then
        echo "  🗑️  Removing .terraform directory"
        rm -rf .terraform
    fi
    
    # Remove .terraform.lock.hcl
    if [ -f ".terraform.lock.hcl" ]; then
        echo "  🗑️  Removing .terraform.lock.hcl"
        rm -f .terraform.lock.hcl
    fi
    
    # Remove generated zip files
    if [ -f "vulnerable_lambda.zip" ]; then
        echo "  🗑️  Removing vulnerable_lambda.zip"
        rm -f vulnerable_lambda.zip
    fi
    
    echo "  ✅ Terraform files cleaned up"
}

# Function to verify cleanup
verify_cleanup() {
    echo "🔄 Verifying cleanup..."
    
    # Check for any remaining resources with our tags
    echo "  🔍 Checking for remaining EC2 instances..."
    REMAINING_INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=tag:Purpose,Values=Inspector Demo" "Name=instance-state-name,Values=running,stopped,stopping,pending" \
        --query 'Reservations[].Instances[].InstanceId' --output text 2>/dev/null || echo "")
    
    if [ ! -z "$REMAINING_INSTANCES" ] && [ "$REMAINING_INSTANCES" != "None" ]; then
        echo "  ⚠️  Found remaining EC2 instances: $REMAINING_INSTANCES"
        echo "     These may still be terminating..."
    else
        echo "  ✅ No remaining EC2 instances found"
    fi
    
    echo "  🔍 Checking for remaining Lambda functions..."
    REMAINING_LAMBDAS=$(aws lambda list-functions \
        --query 'Functions[?FunctionName==`inspector-demo-vulnerable-function`].FunctionName' --output text 2>/dev/null || echo "")
    
    if [ ! -z "$REMAINING_LAMBDAS" ] && [ "$REMAINING_LAMBDAS" != "None" ]; then
        echo "  ⚠️  Found remaining Lambda functions: $REMAINING_LAMBDAS"
    else
        echo "  ✅ No remaining Lambda functions found"
    fi
    
    echo "  🔍 Checking for remaining ECR repositories..."
    REMAINING_REPOS=$(aws ecr describe-repositories \
        --repository-names "inspector-demo-vulnerable" \
        --query 'repositories[].repositoryName' --output text 2>/dev/null || echo "")
    
    if [ ! -z "$REMAINING_REPOS" ] && [ "$REMAINING_REPOS" != "None" ]; then
        echo "  ⚠️  Found remaining ECR repositories: $REMAINING_REPOS"
    else
        echo "  ✅ No remaining ECR repositories found"
    fi
}

# Function to display cleanup summary
display_cleanup_summary() {
    echo ""
    echo "🎉 Terraform cleanup completed!"
    echo "=============================="
    echo ""
    echo "📋 Cleanup actions performed:"
    echo "   • Destroyed all Terraform-managed resources"
    echo "   • Removed Terraform state files"
    echo "   • Cleaned up temporary files"
    echo "   • Verified resource removal"
    echo ""
    echo "💰 Cost Impact: All billable resources have been terminated"
    echo "🔒 Security: All vulnerable resources have been removed"
    echo ""
    echo "ℹ️  Notes:"
    echo "   • Inspector findings may remain visible for up to 90 days"
    echo "   • This is normal behavior for the Inspector service"
    echo "   • You can now safely re-run terraform apply if needed"
}

# Main execution
main() {
    echo "🧹 Terraform Inspector Demo Cleanup"
    echo "==================================="
    
    check_terraform
    check_aws_cli
    
    echo ""
    show_current_state
    
    echo ""
    echo "⚠️  This will destroy ALL Terraform-managed resources!"
    echo "   Including EC2 instances, Lambda functions, ECR repositories, etc."
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cleanup cancelled by user"
        exit 0
    fi
    
    echo ""
    echo "🚀 Starting Terraform cleanup process..."
    
    plan_destruction
    
    echo ""
    execute_destruction
    
    echo ""
    cleanup_terraform_files
    
    echo ""
    verify_cleanup
    
    display_cleanup_summary
}

# Run main function
main
