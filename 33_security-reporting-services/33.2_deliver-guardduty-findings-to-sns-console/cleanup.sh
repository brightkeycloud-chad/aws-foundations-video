#!/bin/bash

# AWS GuardDuty SNS Integration Demo Cleanup Script
# This script removes all resources created during the demo

set -e

echo "🧹 Starting cleanup of GuardDuty SNS integration demo resources..."

# Get the default region
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    echo "❌ No default region configured. Please set your AWS region."
    exit 1
fi

echo "🌍 Using region: $REGION"

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
    echo "✅ AWS CLI configured successfully"
}

# Function to delete EventBridge rule
delete_eventbridge_rule() {
    echo "🔄 Deleting EventBridge rules..."
    
    # List of possible rule names
    RULE_NAMES=("guardduty-findings-to-sns" "guardduty-high-critical-findings")
    
    for RULE_NAME in "${RULE_NAMES[@]}"; do
        # Remove targets first
        if aws events list-targets-by-rule --rule "$RULE_NAME" &> /dev/null; then
            echo "  Removing targets from rule: $RULE_NAME"
            TARGET_IDS=$(aws events list-targets-by-rule --rule "$RULE_NAME" --query 'Targets[].Id' --output text)
            if [ ! -z "$TARGET_IDS" ]; then
                aws events remove-targets --rule "$RULE_NAME" --ids $TARGET_IDS
                echo "  ✅ Targets removed from $RULE_NAME"
            fi
        fi
        
        # Delete the rule
        if aws events describe-rule --name "$RULE_NAME" &> /dev/null; then
            aws events delete-rule --name "$RULE_NAME"
            echo "  ✅ EventBridge rule deleted: $RULE_NAME"
        else
            echo "  ℹ️  EventBridge rule not found: $RULE_NAME"
        fi
    done
}

# Function to delete SNS topic and subscription
delete_sns_resources() {
    echo "🔄 Deleting SNS resources..."
    
    # List of possible topic names
    TOPIC_PATTERNS=("guardduty-findings-alerts" "guardduty-high-critical-alerts")
    
    for TOPIC_PATTERN in "${TOPIC_PATTERNS[@]}"; do
        # Get topic ARN
        TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, \`$TOPIC_PATTERN\`)].TopicArn" --output text)
        
        if [ ! -z "$TOPIC_ARN" ]; then
            echo "  Found SNS topic: $TOPIC_ARN"
            
            # Delete all subscriptions first
            SUBSCRIPTIONS=$(aws sns list-subscriptions-by-topic --topic-arn "$TOPIC_ARN" --query 'Subscriptions[].SubscriptionArn' --output text)
            if [ ! -z "$SUBSCRIPTIONS" ]; then
                for SUB_ARN in $SUBSCRIPTIONS; do
                    if [ "$SUB_ARN" != "PendingConfirmation" ]; then
                        aws sns unsubscribe --subscription-arn "$SUB_ARN"
                        echo "  ✅ Subscription deleted: $SUB_ARN"
                    fi
                done
            fi
            
            # Delete the topic
            aws sns delete-topic --topic-arn "$TOPIC_ARN"
            echo "  ✅ SNS topic deleted: $TOPIC_PATTERN"
        else
            echo "  ℹ️  SNS topic not found: $TOPIC_PATTERN"
        fi
    done
}

# Function to clean up GuardDuty sample findings (optional)
cleanup_sample_findings() {
    echo "🔄 Checking for GuardDuty sample findings..."
    
    # Note: Sample findings are automatically archived after 15 minutes
    # We'll just inform the user about this
    SAMPLE_FINDINGS=$(aws guardduty list-findings --detector-id $(aws guardduty list-detectors --query 'DetectorIds[0]' --output text) --finding-criteria '{"Criterion":{"type":{"Eq":["SampleFinding"]}}}' --query 'FindingIds' --output text 2>/dev/null || echo "")
    
    if [ ! -z "$SAMPLE_FINDINGS" ] && [ "$SAMPLE_FINDINGS" != "None" ]; then
        echo "  ℹ️  Sample findings detected. These will be automatically archived after 15 minutes."
        echo "  ℹ️  No manual cleanup required for sample findings."
    else
        echo "  ✅ No sample findings found or already archived"
    fi
}

# Main cleanup execution
main() {
    echo "🚀 AWS GuardDuty SNS Integration Demo Cleanup"
    echo "=============================================="
    
    check_aws_cli
    
    echo ""
    delete_eventbridge_rule
    
    echo ""
    delete_sns_resources
    
    echo ""
    cleanup_sample_findings
    
    echo ""
    echo "🎉 Cleanup completed successfully!"
    echo ""
    echo "📋 Summary of cleaned up resources:"
    echo "   • EventBridge rules: guardduty-findings-to-sns, guardduty-high-critical-findings"
    echo "   • SNS topics: guardduty-findings-alerts, guardduty-high-critical-alerts"
    echo "   • SNS subscriptions (email notifications)"
    echo ""
    echo "ℹ️  Note: GuardDuty itself remains enabled for ongoing security monitoring"
    echo "ℹ️  Sample findings will be automatically archived after 15 minutes"
}

# Run main function
main
