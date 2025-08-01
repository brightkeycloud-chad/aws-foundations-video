#!/bin/bash

# AWS Lambda Demonstration Cleanup Script
# Cleans up all resources created by the Lambda automation demonstrations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "unknown")

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Cleanup script for AWS Lambda demonstration resources"
    echo
    echo "Options:"
    echo "  -r, --region REGION    AWS region (default: us-east-1)"
    echo "  -a, --all             Clean up all demo resources (default)"
    echo "  -f, --functions       Clean up Lambda functions only"
    echo "  -i, --iam             Clean up IAM roles only"
    echo "  -l, --local           Clean up local files only"
    echo "  -d, --dry-run         Show what would be deleted without actually deleting"
    echo "  -h, --help            Show this help"
    echo
    echo "Examples:"
    echo "  $0                    # Clean up all resources in us-east-1"
    echo "  $0 --region us-west-2 # Clean up all resources in us-west-2"
    echo "  $0 --functions        # Clean up only Lambda functions"
    echo "  $0 --dry-run          # Show what would be cleaned up"
    exit 1
}

# Parse command line arguments
CLEANUP_ALL=true
CLEANUP_FUNCTIONS=false
CLEANUP_IAM=false
CLEANUP_LOCAL=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -a|--all)
            CLEANUP_ALL=true
            shift
            ;;
        -f|--functions)
            CLEANUP_ALL=false
            CLEANUP_FUNCTIONS=true
            shift
            ;;
        -i|--iam)
            CLEANUP_ALL=false
            CLEANUP_IAM=true
            shift
            ;;
        -l|--local)
            CLEANUP_ALL=false
            CLEANUP_LOCAL=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check AWS credentials
check_aws_credentials() {
    log "Checking AWS credentials..."
    if ! aws sts get-caller-identity --region "$REGION" > /dev/null 2>&1; then
        error "AWS CLI not configured or invalid credentials for region $REGION"
        exit 1
    fi
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region "$REGION")
    info "Connected to account: $ACCOUNT_ID in region: $REGION"
}

# Find and clean up Lambda functions
cleanup_lambda_functions() {
    log "Searching for demo Lambda functions..."
    
    # Find functions with demo prefixes
    DEMO_FUNCTIONS=$(aws lambda list-functions \
        --region "$REGION" \
        --query 'Functions[?contains(FunctionName, `demo-lambda-function`) || contains(FunctionName, `cli-demo-function`)].FunctionName' \
        --output text 2>/dev/null || echo "")
    
    if [[ -z "$DEMO_FUNCTIONS" ]]; then
        info "No demo Lambda functions found"
        return 0
    fi
    
    info "Found Lambda functions to clean up:"
    for function in $DEMO_FUNCTIONS; do
        echo "  - $function"
    done
    
    if [[ "$DRY_RUN" == "true" ]]; then
        warning "DRY RUN: Would delete ${#DEMO_FUNCTIONS[@]} Lambda functions"
        return 0
    fi
    
    # Delete functions
    for function in $DEMO_FUNCTIONS; do
        log "Deleting Lambda function: $function"
        if aws lambda delete-function --function-name "$function" --region "$REGION" 2>/dev/null; then
            info "✓ Deleted function: $function"
        else
            warning "Could not delete function: $function (may not exist)"
        fi
    done
}

# Find and clean up IAM roles
cleanup_iam_roles() {
    log "Searching for demo IAM roles..."
    
    # Find roles with demo prefixes
    DEMO_ROLES=$(aws iam list-roles \
        --query 'Roles[?contains(RoleName, `demo-lambda-role`) || contains(RoleName, `cli-demo-role`)].RoleName' \
        --output text 2>/dev/null || echo "")
    
    if [[ -z "$DEMO_ROLES" ]]; then
        info "No demo IAM roles found"
        return 0
    fi
    
    info "Found IAM roles to clean up:"
    for role in $DEMO_ROLES; do
        echo "  - $role"
    done
    
    if [[ "$DRY_RUN" == "true" ]]; then
        warning "DRY RUN: Would delete IAM roles and detach policies"
        return 0
    fi
    
    # Clean up roles
    for role in $DEMO_ROLES; do
        log "Cleaning up IAM role: $role"
        
        # Detach managed policies
        ATTACHED_POLICIES=$(aws iam list-attached-role-policies \
            --role-name "$role" \
            --query 'AttachedPolicies[].PolicyArn' \
            --output text 2>/dev/null || echo "")
        
        for policy_arn in $ATTACHED_POLICIES; do
            if [[ -n "$policy_arn" ]]; then
                log "  Detaching policy: $policy_arn"
                aws iam detach-role-policy --role-name "$role" --policy-arn "$policy_arn" 2>/dev/null || true
            fi
        done
        
        # Delete inline policies
        INLINE_POLICIES=$(aws iam list-role-policies \
            --role-name "$role" \
            --query 'PolicyNames' \
            --output text 2>/dev/null || echo "")
        
        for policy_name in $INLINE_POLICIES; do
            if [[ -n "$policy_name" ]]; then
                log "  Deleting inline policy: $policy_name"
                aws iam delete-role-policy --role-name "$role" --policy-name "$policy_name" 2>/dev/null || true
            fi
        done
        
        # Delete role
        if aws iam delete-role --role-name "$role" 2>/dev/null; then
            info "✓ Deleted role: $role"
        else
            warning "Could not delete role: $role (may not exist)"
        fi
    done
}

# Clean up local files
cleanup_local_files() {
    log "Cleaning up local files..."
    
    LOCAL_FILES=(
        "simple_lambda.py"
        "function.zip"
        "response.json"
        "demo-lambda-function-*.zip"
    )
    
    FOUND_FILES=()
    for pattern in "${LOCAL_FILES[@]}"; do
        # Use find to handle glob patterns safely
        while IFS= read -r -d '' file; do
            FOUND_FILES+=("$file")
        done < <(find . -maxdepth 1 -name "$pattern" -print0 2>/dev/null)
    done
    
    if [[ ${#FOUND_FILES[@]} -eq 0 ]]; then
        info "No local files to clean up"
        return 0
    fi
    
    info "Found local files to clean up:"
    for file in "${FOUND_FILES[@]}"; do
        echo "  - $file"
    done
    
    if [[ "$DRY_RUN" == "true" ]]; then
        warning "DRY RUN: Would delete ${#FOUND_FILES[@]} local files"
        return 0
    fi
    
    # Delete files
    for file in "${FOUND_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            log "Deleting file: $file"
            rm -f "$file"
            info "✓ Deleted: $file"
        fi
    done
}

# Clean up CloudWatch log groups
cleanup_log_groups() {
    log "Searching for demo CloudWatch log groups..."
    
    # Find log groups for demo Lambda functions
    LOG_GROUPS=$(aws logs describe-log-groups \
        --region "$REGION" \
        --log-group-name-prefix "/aws/lambda/demo-lambda-function" \
        --query 'logGroups[].logGroupName' \
        --output text 2>/dev/null || echo "")
    
    CLI_LOG_GROUPS=$(aws logs describe-log-groups \
        --region "$REGION" \
        --log-group-name-prefix "/aws/lambda/cli-demo-function" \
        --query 'logGroups[].logGroupName' \
        --output text 2>/dev/null || echo "")
    
    ALL_LOG_GROUPS="$LOG_GROUPS $CLI_LOG_GROUPS"
    
    if [[ -z "$ALL_LOG_GROUPS" || "$ALL_LOG_GROUPS" == " " ]]; then
        info "No demo CloudWatch log groups found"
        return 0
    fi
    
    info "Found CloudWatch log groups to clean up:"
    for log_group in $ALL_LOG_GROUPS; do
        if [[ -n "$log_group" ]]; then
            echo "  - $log_group"
        fi
    done
    
    if [[ "$DRY_RUN" == "true" ]]; then
        warning "DRY RUN: Would delete CloudWatch log groups"
        return 0
    fi
    
    # Delete log groups
    for log_group in $ALL_LOG_GROUPS; do
        if [[ -n "$log_group" ]]; then
            log "Deleting log group: $log_group"
            if aws logs delete-log-group --log-group-name "$log_group" --region "$REGION" 2>/dev/null; then
                info "✓ Deleted log group: $log_group"
            else
                warning "Could not delete log group: $log_group (may not exist)"
            fi
        fi
    done
}

# Main cleanup function
main() {
    echo -e "${BLUE}=== AWS Lambda Demonstration Cleanup ===${NC}"
    echo "Region: $REGION"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}DRY RUN MODE - No resources will be deleted${NC}"
    fi
    echo
    
    # Check AWS credentials
    check_aws_credentials
    
    # Perform cleanup based on options
    if [[ "$CLEANUP_ALL" == "true" || "$CLEANUP_FUNCTIONS" == "true" ]]; then
        cleanup_lambda_functions
        cleanup_log_groups
    fi
    
    if [[ "$CLEANUP_ALL" == "true" || "$CLEANUP_IAM" == "true" ]]; then
        cleanup_iam_roles
    fi
    
    if [[ "$CLEANUP_ALL" == "true" || "$CLEANUP_LOCAL" == "true" ]]; then
        cleanup_local_files
    fi
    
    echo
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN completed - no resources were actually deleted"
    else
        info "Cleanup completed successfully!"
    fi
    
    # Show remaining resources
    echo
    log "Checking for any remaining demo resources..."
    
    REMAINING_FUNCTIONS=$(aws lambda list-functions \
        --region "$REGION" \
        --query 'Functions[?contains(FunctionName, `demo`) || contains(FunctionName, `cli-demo`)].FunctionName' \
        --output text 2>/dev/null || echo "")
    
    REMAINING_ROLES=$(aws iam list-roles \
        --query 'Roles[?contains(RoleName, `demo`) || contains(RoleName, `cli-demo`)].RoleName' \
        --output text 2>/dev/null || echo "")
    
    if [[ -n "$REMAINING_FUNCTIONS" ]]; then
        warning "Remaining Lambda functions: $REMAINING_FUNCTIONS"
    fi
    
    if [[ -n "$REMAINING_ROLES" ]]; then
        warning "Remaining IAM roles: $REMAINING_ROLES"
    fi
    
    if [[ -z "$REMAINING_FUNCTIONS" && -z "$REMAINING_ROLES" ]]; then
        info "✓ No remaining demo resources found"
    fi
}

# Confirmation prompt
if [[ "$DRY_RUN" != "true" ]]; then
    echo -e "${YELLOW}This will delete AWS Lambda demo resources in region: $REGION${NC}"
    echo "This includes:"
    echo "  - Lambda functions with 'demo' or 'cli-demo' in the name"
    echo "  - Associated IAM roles and policies"
    echo "  - CloudWatch log groups"
    echo "  - Local temporary files"
    echo
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled"
        exit 0
    fi
fi

# Error handling
trap 'error "Cleanup script failed at line $LINENO"' ERR

# Run main function
main "$@"
