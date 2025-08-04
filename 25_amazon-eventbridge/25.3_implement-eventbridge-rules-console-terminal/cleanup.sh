#!/bin/bash

# AWS Health Event Monitor Cleanup Script
# This script removes all resources created by the health monitoring demo

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FUNCTION_NAME="HealthEventProcessor"
SNS_TOPIC_NAME="aws-health-alerts"
RULE_NAME="HealthEventRule"
ROLE_NAME="${FUNCTION_NAME}Role"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get AWS account ID and region
get_aws_info() {
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    AWS_REGION=$(aws configure get region)
    
    if [ -z "$AWS_REGION" ]; then
        AWS_REGION="us-east-1"
    fi
}

# Function to remove EventBridge rule and targets
cleanup_eventbridge() {
    print_status "Cleaning up EventBridge rule: $RULE_NAME"
    
    # Remove targets first
    if aws events list-targets-by-rule --rule "$RULE_NAME" --query 'Targets[0].Id' --output text 2>/dev/null | grep -q "1"; then
        print_status "Removing targets from rule..."
        aws events remove-targets \
            --rule "$RULE_NAME" \
            --ids "1" 2>/dev/null || print_warning "Failed to remove targets"
    fi
    
    # Delete the rule
    if aws events describe-rule --name "$RULE_NAME" > /dev/null 2>&1; then
        aws events delete-rule --name "$RULE_NAME" 2>/dev/null
        print_success "EventBridge rule deleted: $RULE_NAME"
    else
        print_warning "EventBridge rule not found: $RULE_NAME"
    fi
}

# Function to remove Lambda function and permissions
cleanup_lambda() {
    print_status "Cleaning up Lambda function: $FUNCTION_NAME"
    
    # Remove Lambda permission for EventBridge
    aws lambda remove-permission \
        --function-name "$FUNCTION_NAME" \
        --statement-id "eventbridge-health-rule" 2>/dev/null || print_warning "Lambda permission not found"
    
    # Delete Lambda function
    if aws lambda get-function --function-name "$FUNCTION_NAME" > /dev/null 2>&1; then
        aws lambda delete-function --function-name "$FUNCTION_NAME" 2>/dev/null
        print_success "Lambda function deleted: $FUNCTION_NAME"
    else
        print_warning "Lambda function not found: $FUNCTION_NAME"
    fi
}

# Function to remove IAM role and policies
cleanup_iam() {
    print_status "Cleaning up IAM role: $ROLE_NAME"
    
    if aws iam get-role --role-name "$ROLE_NAME" > /dev/null 2>&1; then
        # Remove inline policies
        print_status "Removing inline policies..."
        aws iam delete-role-policy \
            --role-name "$ROLE_NAME" \
            --policy-name "SNSPublishPolicy" 2>/dev/null || print_warning "SNS policy not found"
        
        # Detach managed policies
        print_status "Detaching managed policies..."
        aws iam detach-role-policy \
            --role-name "$ROLE_NAME" \
            --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 2>/dev/null || print_warning "Basic execution policy not attached"
        
        # Delete the role
        aws iam delete-role --role-name "$ROLE_NAME" 2>/dev/null
        print_success "IAM role deleted: $ROLE_NAME"
    else
        print_warning "IAM role not found: $ROLE_NAME"
    fi
}

# Function to remove SNS topic and subscriptions
cleanup_sns() {
    print_status "Cleaning up SNS topic: $SNS_TOPIC_NAME"
    
    # Get topic ARN
    SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, '$SNS_TOPIC_NAME')].TopicArn" --output text 2>/dev/null)
    
    if [ -n "$SNS_TOPIC_ARN" ] && [ "$SNS_TOPIC_ARN" != "None" ]; then
        # List and delete all subscriptions
        print_status "Removing SNS subscriptions..."
        SUBSCRIPTIONS=$(aws sns list-subscriptions-by-topic \
            --topic-arn "$SNS_TOPIC_ARN" \
            --query 'Subscriptions[].SubscriptionArn' \
            --output text 2>/dev/null)
        
        if [ -n "$SUBSCRIPTIONS" ] && [ "$SUBSCRIPTIONS" != "None" ]; then
            for subscription in $SUBSCRIPTIONS; do
                if [ "$subscription" != "PendingConfirmation" ]; then
                    aws sns unsubscribe --subscription-arn "$subscription" 2>/dev/null || print_warning "Failed to unsubscribe: $subscription"
                fi
            done
        fi
        
        # Delete the topic
        aws sns delete-topic --topic-arn "$SNS_TOPIC_ARN" 2>/dev/null
        print_success "SNS topic deleted: $SNS_TOPIC_NAME"
    else
        print_warning "SNS topic not found: $SNS_TOPIC_NAME"
    fi
}

# Function to clean up CloudWatch logs
cleanup_logs() {
    print_status "Cleaning up CloudWatch logs..."
    
    LOG_GROUP="/aws/lambda/$FUNCTION_NAME"
    
    if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "$LOG_GROUP"; then
        aws logs delete-log-group --log-group-name "$LOG_GROUP" 2>/dev/null
        print_success "CloudWatch log group deleted: $LOG_GROUP"
    else
        print_warning "CloudWatch log group not found: $LOG_GROUP"
    fi
}

# Function to display cleanup summary
display_summary() {
    echo
    print_success "=== Cleanup Complete ==="
    echo
    print_status "The following resources have been removed:"
    echo "• EventBridge Rule: $RULE_NAME"
    echo "• Lambda Function: $FUNCTION_NAME"
    echo "• IAM Role: $ROLE_NAME"
    echo "• SNS Topic: $SNS_TOPIC_NAME"
    echo "• CloudWatch Log Group: /aws/lambda/$FUNCTION_NAME"
    echo
    print_warning "Note: Email subscriptions may take a few minutes to be fully removed."
    print_status "All demo resources have been successfully cleaned up!"
}

# Function to confirm cleanup
confirm_cleanup() {
    echo "🧹 AWS Health Event Monitor Cleanup"
    echo "===================================="
    echo
    print_warning "This will delete ALL resources created by the health monitoring demo:"
    echo "• EventBridge Rule: $RULE_NAME"
    echo "• Lambda Function: $FUNCTION_NAME"
    echo "• IAM Role: $ROLE_NAME"
    echo "• SNS Topic: $SNS_TOPIC_NAME (and all subscriptions)"
    echo "• CloudWatch Log Group: /aws/lambda/$FUNCTION_NAME"
    echo
    
    read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleanup cancelled."
        exit 0
    fi
}

# Main execution
main() {
    get_aws_info
    confirm_cleanup
    
    echo
    print_status "Starting cleanup process..."
    echo
    
    # Clean up in reverse order of creation
    cleanup_eventbridge
    cleanup_lambda
    cleanup_iam
    cleanup_sns
    cleanup_logs
    
    display_summary
}

# Run main function
main "$@"
