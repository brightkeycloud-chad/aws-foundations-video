#!/bin/bash

# Cleanup Script for Demo 11.5 - Docker Container Lambda Function
# This script removes all AWS resources created during the demonstration

set -e

# Configuration (should match deploy-container.sh)
FUNCTION_NAME="AnalyticsProcessorFunction"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "unknown")
ECR_REPO_NAME="lambda-analytics-processor"
ROLE_NAME="${FUNCTION_NAME}Role"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Starting AWS resource cleanup for Demo 11.5...${NC}"
echo ""

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        echo -e "${RED}❌ AWS CLI not configured or no permissions${NC}"
        echo "Please ensure AWS CLI is configured with appropriate permissions"
        exit 1
    fi
    echo -e "${GREEN}✅ AWS CLI configured${NC}"
    echo "   Account: $ACCOUNT_ID"
    echo "   Region: $REGION"
    echo ""
}

# Function to delete Lambda function
cleanup_lambda_function() {
    echo -e "${YELLOW}🔍 Checking Lambda function: $FUNCTION_NAME${NC}"
    
    if aws lambda get-function --function-name $FUNCTION_NAME --region $REGION > /dev/null 2>&1; then
        echo -e "${YELLOW}🗑️  Deleting Lambda function: $FUNCTION_NAME${NC}"
        aws lambda delete-function \
            --function-name $FUNCTION_NAME \
            --region $REGION
        echo -e "${GREEN}✅ Lambda function deleted${NC}"
    else
        echo -e "${BLUE}ℹ️  Lambda function not found (already deleted or never created)${NC}"
    fi
    echo ""
}

# Function to delete ECR repository
cleanup_ecr_repository() {
    echo -e "${YELLOW}🔍 Checking ECR repository: $ECR_REPO_NAME${NC}"
    
    if aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $REGION > /dev/null 2>&1; then
        echo -e "${YELLOW}🗑️  Deleting ECR repository: $ECR_REPO_NAME${NC}"
        
        # First, delete all images in the repository
        echo "   Deleting all images in repository..."
        aws ecr batch-delete-image \
            --repository-name $ECR_REPO_NAME \
            --region $REGION \
            --image-ids "$(aws ecr list-images --repository-name $ECR_REPO_NAME --region $REGION --query 'imageIds[*]' --output json)" \
            > /dev/null 2>&1 || echo "   No images to delete"
        
        # Then delete the repository
        aws ecr delete-repository \
            --repository-name $ECR_REPO_NAME \
            --region $REGION \
            --force
        echo -e "${GREEN}✅ ECR repository deleted${NC}"
    else
        echo -e "${BLUE}ℹ️  ECR repository not found (already deleted or never created)${NC}"
    fi
    echo ""
}

# Function to delete IAM role and policies
cleanup_iam_role() {
    echo -e "${YELLOW}🔍 Checking IAM role: $ROLE_NAME${NC}"
    
    if aws iam get-role --role-name $ROLE_NAME > /dev/null 2>&1; then
        echo -e "${YELLOW}🗑️  Cleaning up IAM role: $ROLE_NAME${NC}"
        
        # Detach managed policies
        echo "   Detaching managed policies..."
        aws iam detach-role-policy \
            --role-name $ROLE_NAME \
            --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
            > /dev/null 2>&1 || echo "   AWSLambdaBasicExecutionRole not attached"
        
        aws iam detach-role-policy \
            --role-name $ROLE_NAME \
            --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
            > /dev/null 2>&1 || echo "   AmazonS3FullAccess not attached"
        
        # List and delete inline policies
        echo "   Checking for inline policies..."
        INLINE_POLICIES=$(aws iam list-role-policies --role-name $ROLE_NAME --query 'PolicyNames' --output text 2>/dev/null || echo "")
        if [[ -n "$INLINE_POLICIES" && "$INLINE_POLICIES" != "None" ]]; then
            for policy in $INLINE_POLICIES; do
                echo "   Deleting inline policy: $policy"
                aws iam delete-role-policy --role-name $ROLE_NAME --policy-name $policy
            done
        fi
        
        # Delete the role
        aws iam delete-role --role-name $ROLE_NAME
        echo -e "${GREEN}✅ IAM role deleted${NC}"
    else
        echo -e "${BLUE}ℹ️  IAM role not found (already deleted or never created)${NC}"
    fi
    echo ""
}

# Function to clean up S3 buckets (optional - asks user)
cleanup_s3_buckets() {
    echo -e "${YELLOW}🔍 Checking for S3 buckets used in demonstrations...${NC}"
    
    # Common bucket patterns used in demos
    BUCKET_PATTERNS=("analytics-demo-bucket" "lambda-demo-bucket" "your-analytics-demo-bucket")
    FOUND_BUCKETS=()
    
    for pattern in "${BUCKET_PATTERNS[@]}"; do
        # List buckets matching pattern
        MATCHING_BUCKETS=$(aws s3api list-buckets --query "Buckets[?contains(Name, '$pattern')].Name" --output text 2>/dev/null || echo "")
        if [[ -n "$MATCHING_BUCKETS" && "$MATCHING_BUCKETS" != "None" ]]; then
            for bucket in $MATCHING_BUCKETS; do
                FOUND_BUCKETS+=("$bucket")
            done
        fi
    done
    
    if [[ ${#FOUND_BUCKETS[@]} -gt 0 ]]; then
        echo -e "${YELLOW}📦 Found potential demo S3 buckets:${NC}"
        for bucket in "${FOUND_BUCKETS[@]}"; do
            echo "   - $bucket"
        done
        echo ""
        
        read -p "Do you want to delete these S3 buckets and all their contents? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for bucket in "${FOUND_BUCKETS[@]}"; do
                echo -e "${YELLOW}🗑️  Deleting S3 bucket: $bucket${NC}"
                
                # Delete all objects and versions
                echo "   Emptying bucket contents..."
                aws s3 rm s3://$bucket --recursive > /dev/null 2>&1 || echo "   Bucket already empty"
                
                # Delete the bucket
                aws s3 rb s3://$bucket > /dev/null 2>&1 && echo -e "${GREEN}   ✅ Bucket deleted${NC}" || echo -e "${RED}   ❌ Failed to delete bucket${NC}"
            done
        else
            echo -e "${BLUE}ℹ️  Skipping S3 bucket deletion${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️  No demo S3 buckets found${NC}"
    fi
    echo ""
}

# Function to clean up CloudWatch logs
cleanup_cloudwatch_logs() {
    echo -e "${YELLOW}🔍 Checking CloudWatch log groups...${NC}"
    
    LOG_GROUP_NAME="/aws/lambda/$FUNCTION_NAME"
    
    if aws logs describe-log-groups --log-group-name-prefix $LOG_GROUP_NAME --region $REGION | grep -q $LOG_GROUP_NAME; then
        echo -e "${YELLOW}🗑️  Deleting CloudWatch log group: $LOG_GROUP_NAME${NC}"
        aws logs delete-log-group \
            --log-group-name $LOG_GROUP_NAME \
            --region $REGION
        echo -e "${GREEN}✅ CloudWatch log group deleted${NC}"
    else
        echo -e "${BLUE}ℹ️  CloudWatch log group not found${NC}"
    fi
    echo ""
}

# Function to clean up local Docker resources
cleanup_local_docker() {
    echo -e "${YELLOW}🔍 Checking local Docker resources...${NC}"
    
    # Remove local Docker images
    if docker images | grep -q "lambda-analytics-processor"; then
        echo -e "${YELLOW}🗑️  Removing local Docker images...${NC}"
        docker rmi lambda-analytics-processor:latest > /dev/null 2>&1 || echo "   Image already removed"
        echo -e "${GREEN}✅ Local Docker images cleaned${NC}"
    else
        echo -e "${BLUE}ℹ️  No local Docker images found${NC}"
    fi
    
    # Clean up any stopped containers
    STOPPED_CONTAINERS=$(docker ps -a --filter "ancestor=lambda-analytics-processor" --format "{{.ID}}" 2>/dev/null || echo "")
    if [[ -n "$STOPPED_CONTAINERS" ]]; then
        echo -e "${YELLOW}🗑️  Removing stopped containers...${NC}"
        echo "$STOPPED_CONTAINERS" | xargs docker rm > /dev/null 2>&1 || echo "   No containers to remove"
        echo -e "${GREEN}✅ Stopped containers cleaned${NC}"
    fi
    
    # Clean up local build files
    if [[ -f "deployment-package.zip" ]]; then
        echo -e "${YELLOW}🗑️  Removing local build files...${NC}"
        rm -f deployment-package.zip
        rm -f response*.json
        rm -f trust-policy.json
        echo -e "${GREEN}✅ Local build files cleaned${NC}"
    fi
    echo ""
}

# Main cleanup process
main() {
    echo -e "${BLUE}📋 Demo 11.5 Cleanup Configuration:${NC}"
    echo "   Function Name: $FUNCTION_NAME"
    echo "   ECR Repository: $ECR_REPO_NAME"
    echo "   IAM Role: $ROLE_NAME"
    echo "   Region: $REGION"
    echo ""
    
    read -p "Do you want to proceed with cleanup? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏹️  Cleanup cancelled${NC}"
        exit 0
    fi
    
    echo ""
    
    # Check AWS CLI
    check_aws_cli
    
    # Cleanup AWS resources
    cleanup_lambda_function
    cleanup_ecr_repository
    cleanup_iam_role
    cleanup_cloudwatch_logs
    cleanup_s3_buckets
    
    # Cleanup local resources
    cleanup_local_docker
    
    echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}📊 Summary:${NC}"
    echo "   ✅ Lambda function removed"
    echo "   ✅ ECR repository removed"
    echo "   ✅ IAM role and policies removed"
    echo "   ✅ CloudWatch logs removed"
    echo "   ✅ Local Docker resources cleaned"
    echo "   ✅ Local build files cleaned"
    echo ""
    echo -e "${BLUE}💡 Note: S3 buckets were handled based on your selection${NC}"
}

# Error handling
trap 'echo -e "${RED}❌ Cleanup script interrupted${NC}"; exit 1' INT TERM

# Run main function
main
