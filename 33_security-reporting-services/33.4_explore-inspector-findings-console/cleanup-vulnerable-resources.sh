#!/bin/bash

# AWS Inspector Demo - Vulnerable Resources Cleanup Script
# This script removes all resources created for the Inspector demo

set -e

echo "🧹 Cleaning up vulnerable resources from Inspector demo..."

# Configuration
REGION=${AWS_DEFAULT_REGION:-us-east-1}

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
    echo "✅ AWS CLI configured successfully"
}

# Function to terminate EC2 instances
cleanup_ec2_instances() {
    echo "🔄 Terminating EC2 instances..."
    
    # Find instances by tags
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Purpose,Values=Inspector Demo" "Name=instance-state-name,Values=running,stopped,stopping,pending" \
        --query 'Reservations[].Instances[].InstanceId' --output text)
    
    if [ ! -z "$INSTANCE_IDS" ] && [ "$INSTANCE_IDS" != "None" ]; then
        echo "  Found instances: $INSTANCE_IDS"
        aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
        echo "  ✅ Instances terminated: $INSTANCE_IDS"
        
        # Wait for instances to terminate
        echo "  ⏳ Waiting for instances to terminate..."
        aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
        echo "  ✅ All instances terminated"
    else
        echo "  ℹ️  No EC2 instances found to terminate"
    fi
}

# Function to delete security groups
cleanup_security_groups() {
    echo "🔄 Deleting security groups..."
    
    # Find security groups by name
    SG_IDS=$(aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=inspector-demo-vulnerable-sg" \
        --query 'SecurityGroups[].GroupId' --output text)
    
    if [ ! -z "$SG_IDS" ] && [ "$SG_IDS" != "None" ]; then
        for SG_ID in $SG_IDS; do
            echo "  Deleting security group: $SG_ID"
            aws ec2 delete-security-group --group-id "$SG_ID"
            echo "  ✅ Security group deleted: $SG_ID"
        done
    else
        echo "  ℹ️  No security groups found to delete"
    fi
}

# Function to delete IAM roles and policies
cleanup_iam_roles() {
    echo "🔄 Cleaning up IAM roles..."
    
    # EC2 role cleanup
    EC2_ROLE_NAME="inspector-demo-ec2-role"
    if aws iam get-role --role-name "$EC2_ROLE_NAME" &> /dev/null; then
        echo "  Cleaning up EC2 IAM role: $EC2_ROLE_NAME"
        
        # Remove role from instance profile
        aws iam remove-role-from-instance-profile \
            --instance-profile-name "$EC2_ROLE_NAME" \
            --role-name "$EC2_ROLE_NAME" 2>/dev/null || true
        
        # Delete instance profile
        aws iam delete-instance-profile \
            --instance-profile-name "$EC2_ROLE_NAME" 2>/dev/null || true
        
        # Detach policies
        aws iam detach-role-policy \
            --role-name "$EC2_ROLE_NAME" \
            --policy-arn "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" 2>/dev/null || true
        
        # Delete role
        aws iam delete-role --role-name "$EC2_ROLE_NAME"
        echo "  ✅ EC2 IAM role deleted: $EC2_ROLE_NAME"
    else
        echo "  ℹ️  EC2 IAM role not found: $EC2_ROLE_NAME"
    fi
    
    # Lambda role cleanup
    LAMBDA_ROLE_NAME="inspector-demo-lambda-role"
    if aws iam get-role --role-name "$LAMBDA_ROLE_NAME" &> /dev/null; then
        echo "  Cleaning up Lambda IAM role: $LAMBDA_ROLE_NAME"
        
        # Detach policies
        aws iam detach-role-policy \
            --role-name "$LAMBDA_ROLE_NAME" \
            --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 2>/dev/null || true
        
        # Delete role
        aws iam delete-role --role-name "$LAMBDA_ROLE_NAME"
        echo "  ✅ Lambda IAM role deleted: $LAMBDA_ROLE_NAME"
    else
        echo "  ℹ️  Lambda IAM role not found: $LAMBDA_ROLE_NAME"
    fi
}

# Function to delete Lambda function
cleanup_lambda_function() {
    echo "🔄 Deleting Lambda function..."
    
    FUNCTION_NAME="inspector-demo-vulnerable-function"
    if aws lambda get-function --function-name "$FUNCTION_NAME" &> /dev/null; then
        aws lambda delete-function --function-name "$FUNCTION_NAME"
        echo "  ✅ Lambda function deleted: $FUNCTION_NAME"
    else
        echo "  ℹ️  Lambda function not found: $FUNCTION_NAME"
    fi
}

# Function to delete ECR repository
cleanup_ecr_repository() {
    echo "🔄 Deleting ECR repository..."
    
    REPO_NAME="inspector-demo-vulnerable"
    if aws ecr describe-repositories --repository-names "$REPO_NAME" &> /dev/null; then
        # Delete all images first
        aws ecr batch-delete-image \
            --repository-name "$REPO_NAME" \
            --image-ids imageTag=vulnerable 2>/dev/null || true
        
        # Delete repository
        aws ecr delete-repository --repository-name "$REPO_NAME" --force
        echo "  ✅ ECR repository deleted: $REPO_NAME"
    else
        echo "  ℹ️  ECR repository not found: $REPO_NAME"
    fi
}

# Function to clean up temporary files
cleanup_temp_files() {
    echo "🔄 Cleaning up temporary files..."
    
    TEMP_FILES=(
        "/tmp/inspector-demo-sg-id"
        "/tmp/inspector-demo-role-name"
        "/tmp/inspector-demo-al2-ami"
        "/tmp/inspector-demo-ubuntu-ami"
        "/tmp/inspector-demo-al2-instance"
        "/tmp/inspector-demo-ubuntu-instance"
        "/tmp/inspector-demo-ecr-uri"
        "/tmp/inspector-demo-lambda-arn"
        "/tmp/ec2-trust-policy.json"
        "/tmp/lambda-trust-policy.json"
        "/tmp/user-data-al2.sh"
        "/tmp/user-data-ubuntu.sh"
        "/tmp/lambda_function.py"
        "/tmp/requirements.txt"
        "/tmp/vulnerable-lambda.zip"
        "/tmp/lambda-package"
        "/tmp/Dockerfile"
    )
    
    for file in "${TEMP_FILES[@]}"; do
        if [ -f "$file" ] || [ -d "$file" ]; then
            rm -rf "$file"
            echo "  ✅ Removed: $file"
        fi
    done
}

# Function to check for remaining resources
check_remaining_resources() {
    echo "🔄 Checking for any remaining resources..."
    
    # Check for EC2 instances
    REMAINING_INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=tag:Purpose,Values=Inspector Demo" "Name=instance-state-name,Values=running,stopped,stopping,pending" \
        --query 'Reservations[].Instances[].InstanceId' --output text)
    
    if [ ! -z "$REMAINING_INSTANCES" ] && [ "$REMAINING_INSTANCES" != "None" ]; then
        echo "  ⚠️  Remaining EC2 instances: $REMAINING_INSTANCES"
    fi
    
    # Check for security groups
    REMAINING_SGS=$(aws ec2 describe-security-groups \
        --filters "Name=tag:Purpose,Values=Inspector Demo" \
        --query 'SecurityGroups[].GroupId' --output text 2>/dev/null || echo "")
    
    if [ ! -z "$REMAINING_SGS" ] && [ "$REMAINING_SGS" != "None" ]; then
        echo "  ⚠️  Remaining security groups: $REMAINING_SGS"
    fi
    
    # Check for Lambda functions
    REMAINING_LAMBDAS=$(aws lambda list-functions \
        --query 'Functions[?contains(Tags.Purpose, `Inspector Demo`)].FunctionName' --output text 2>/dev/null || echo "")
    
    if [ ! -z "$REMAINING_LAMBDAS" ] && [ "$REMAINING_LAMBDAS" != "None" ]; then
        echo "  ⚠️  Remaining Lambda functions: $REMAINING_LAMBDAS"
    fi
    
    echo "  ✅ Resource check completed"
}

# Function to display cleanup summary
display_cleanup_summary() {
    echo ""
    echo "🎉 Cleanup completed!"
    echo "===================="
    echo ""
    echo "📋 Resources cleaned up:"
    echo "   • EC2 instances (Amazon Linux 2 and Ubuntu)"
    echo "   • Security groups"
    echo "   • IAM roles and instance profiles"
    echo "   • Lambda function"
    echo "   • ECR repository and images"
    echo "   • Temporary files"
    echo ""
    echo "💰 Cost Impact: All billable resources have been terminated"
    echo "🔒 Security: All vulnerable resources have been removed"
    echo ""
    echo "ℹ️  Note: Inspector findings may remain visible for up to 90 days"
    echo "   This is normal and expected behavior for the service"
}

# Main execution
main() {
    echo "🧹 AWS Inspector Demo - Vulnerable Resources Cleanup"
    echo "==================================================="
    
    check_aws_cli
    
    echo ""
    echo "⚠️  This will delete ALL resources created for the Inspector demo!"
    echo "   Including EC2 instances, Lambda functions, ECR repositories, etc."
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cleanup cancelled by user"
        exit 0
    fi
    
    echo ""
    echo "🚀 Starting cleanup process..."
    
    # Order matters - terminate instances first, then clean up dependencies
    cleanup_lambda_function
    
    echo ""
    cleanup_ec2_instances
    
    echo ""
    cleanup_security_groups
    
    echo ""
    cleanup_iam_roles
    
    echo ""
    cleanup_ecr_repository
    
    echo ""
    cleanup_temp_files
    
    echo ""
    check_remaining_resources
    
    display_cleanup_summary
}

# Run main function
main
