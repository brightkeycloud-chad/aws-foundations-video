#!/bin/bash

# AWS GuardDuty SNS Integration - EventBridge Rule Creation Script
# This script automates the creation of EventBridge rule for GuardDuty findings

set -e

echo "🚀 Creating EventBridge rule for GuardDuty findings..."

# Get the default region
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    echo "❌ No default region configured. Please set your AWS region."
    exit 1
fi

echo "🌍 Using region: $REGION"

# Variables
RULE_NAME="guardduty-findings-to-sns"
TOPIC_NAME="guardduty-findings-alerts"
DESCRIPTION="Send GuardDuty findings to SNS topic"

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
    echo "✅ AWS CLI configured successfully"
}

# Function to create SNS topic
create_sns_topic() {
    echo "🔄 Creating SNS topic..."
    
    # Check if topic already exists
    EXISTING_TOPIC=$(aws sns list-topics --query "Topics[?contains(TopicArn, '$TOPIC_NAME')].TopicArn" --output text)
    
    if [ ! -z "$EXISTING_TOPIC" ]; then
        echo "  ℹ️  SNS topic already exists: $EXISTING_TOPIC"
        TOPIC_ARN="$EXISTING_TOPIC"
    else
        TOPIC_ARN=$(aws sns create-topic --name "$TOPIC_NAME" --query 'TopicArn' --output text)
        echo "  ✅ SNS topic created: $TOPIC_ARN"
    fi
}

# Function to create EventBridge rule
create_eventbridge_rule() {
    echo "🔄 Creating EventBridge rule..."
    
    # Event pattern for GuardDuty findings
    EVENT_PATTERN='{
        "source": ["aws.guardduty"],
        "detail-type": ["GuardDuty Finding"]
    }'
    
    # Create the rule
    aws events put-rule \
        --name "$RULE_NAME" \
        --description "$DESCRIPTION" \
        --event-pattern "$EVENT_PATTERN" \
        --state ENABLED
    
    echo "  ✅ EventBridge rule created: $RULE_NAME"
    echo "  ℹ️  Rule captures ALL GuardDuty findings (all severity levels)"
}

# Function to create EventBridge rule for HIGH/CRITICAL only
create_high_severity_rule() {
    echo "🔄 Would you like to filter for HIGH and CRITICAL severity findings only? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "🔄 Creating HIGH/CRITICAL severity rule..."
        
        # Event pattern for HIGH and CRITICAL findings only (severity >= 7.0)
        EVENT_PATTERN_HIGH='{
            "source": ["aws.guardduty"],
            "detail-type": ["GuardDuty Finding"],
            "detail": {
                "severity": [{ "numeric": [">=", 7.0] }]
            }
        }'
        
        # Update the rule with severity filter
        aws events put-rule \
            --name "$RULE_NAME" \
            --description "$DESCRIPTION - HIGH and CRITICAL severity only" \
            --event-pattern "$EVENT_PATTERN_HIGH" \
            --state ENABLED
        
        echo "  ✅ EventBridge rule updated for HIGH/CRITICAL severity (≥ 7.0)"
        echo "  📊 Severity levels:"
        echo "     • CRITICAL: 9.0 - 10.0 (captured)"
        echo "     • HIGH: 7.0 - 8.9 (captured)"
        echo "     • MEDIUM: 4.0 - 6.9 (filtered out)"
        echo "     • LOW: 1.0 - 3.9 (filtered out)"
    else
        echo "  ℹ️  Using default rule (all severity levels)"
    fi
}

# Function to add SNS target to EventBridge rule
add_sns_target() {
    echo "🔄 Adding SNS target to EventBridge rule..."
    
    # Get account ID for the target ID
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
    TARGET_ID="1"
    
    # Add SNS topic as target
    aws events put-targets \
        --rule "$RULE_NAME" \
        --targets "Id=$TARGET_ID,Arn=$TOPIC_ARN"
    
    echo "  ✅ SNS target added to EventBridge rule"
}

# Function to add resource policy to SNS topic
add_sns_policy() {
    echo "🔄 Adding EventBridge permissions to SNS topic..."
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
    
    # SNS topic policy to allow EventBridge to publish
    POLICY='{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowEventBridgeToPublish",
                "Effect": "Allow",
                "Principal": {
                    "Service": "events.amazonaws.com"
                },
                "Action": "sns:Publish",
                "Resource": "'$TOPIC_ARN'",
                "Condition": {
                    "StringEquals": {
                        "aws:SourceAccount": "'$ACCOUNT_ID'"
                    }
                }
            }
        ]
    }'
    
    aws sns set-topic-attributes \
        --topic-arn "$TOPIC_ARN" \
        --attribute-name Policy \
        --attribute-value "$POLICY"
    
    echo "  ✅ SNS topic policy updated"
}

# Function to create email subscription (optional)
create_email_subscription() {
    echo "🔄 Would you like to create an email subscription? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "📧 Enter your email address:"
        read -r EMAIL_ADDRESS
        
        if [[ "$EMAIL_ADDRESS" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            aws sns subscribe \
                --topic-arn "$TOPIC_ARN" \
                --protocol email \
                --notification-endpoint "$EMAIL_ADDRESS"
            
            echo "  ✅ Email subscription created. Please check your email and confirm the subscription."
        else
            echo "  ❌ Invalid email address format"
        fi
    else
        echo "  ℹ️  Skipping email subscription creation"
    fi
}

# Main execution
main() {
    echo "🚀 AWS GuardDuty SNS Integration Setup"
    echo "======================================"
    
    check_aws_cli
    
    echo ""
    create_sns_topic
    
    echo ""
    create_eventbridge_rule
    
    echo ""
    create_high_severity_rule
    
    echo ""
    add_sns_target
    
    echo ""
    add_sns_policy
    
    echo ""
    create_email_subscription
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "📋 Created resources:"
    echo "   • SNS Topic: $TOPIC_ARN"
    echo "   • EventBridge Rule: $RULE_NAME"
    echo "   • EventBridge Target: SNS topic"
    echo ""
    echo "🧪 To test the integration:"
    echo "   1. Go to GuardDuty console"
    echo "   2. Navigate to Settings → Sample findings"
    echo "   3. Click 'Generate sample findings'"
    echo "   4. Check your email for notifications"
    echo ""
    echo "🧹 To clean up resources later, run: ./cleanup.sh"
}

# Run main function
main
