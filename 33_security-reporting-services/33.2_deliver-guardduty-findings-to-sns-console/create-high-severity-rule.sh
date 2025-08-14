#!/bin/bash

# AWS GuardDuty HIGH/CRITICAL Severity EventBridge Rule
# This script creates an EventBridge rule that only captures HIGH and CRITICAL severity findings

set -e

echo "🚨 Creating EventBridge rule for HIGH and CRITICAL GuardDuty findings..."

# Get the default region
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    echo "❌ No default region configured. Please set your AWS region."
    exit 1
fi

echo "🌍 Using region: $REGION"

# Variables
RULE_NAME="guardduty-high-critical-findings"
TOPIC_NAME="guardduty-high-critical-alerts"
DESCRIPTION="Send HIGH and CRITICAL GuardDuty findings to SNS topic"

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
    echo "🔄 Creating SNS topic for HIGH/CRITICAL alerts..."
    
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

# Function to create EventBridge rule with severity filter
create_severity_filtered_rule() {
    echo "🔄 Creating EventBridge rule with severity filter..."
    
    # Event pattern for HIGH and CRITICAL findings (severity >= 7.0)
    # Based on AWS documentation:
    # - CRITICAL: 9.0 - 10.0
    # - HIGH: 7.0 - 8.9
    # - MEDIUM: 4.0 - 6.9 (filtered out)
    # - LOW: 1.0 - 3.9 (filtered out)
    EVENT_PATTERN='{
        "source": ["aws.guardduty"],
        "detail-type": ["GuardDuty Finding"],
        "detail": {
            "severity": [{ "numeric": [">=", 7.0] }]
        }
    }'
    
    # Create the rule
    aws events put-rule \
        --name "$RULE_NAME" \
        --description "$DESCRIPTION" \
        --event-pattern "$EVENT_PATTERN" \
        --state ENABLED
    
    echo "  ✅ EventBridge rule created: $RULE_NAME"
    echo "  📊 Severity filter applied:"
    echo "     • CRITICAL (9.0-10.0): ✅ Captured"
    echo "     • HIGH (7.0-8.9): ✅ Captured"
    echo "     • MEDIUM (4.0-6.9): ❌ Filtered out"
    echo "     • LOW (1.0-3.9): ❌ Filtered out"
}

# Function to add SNS target to EventBridge rule
add_sns_target() {
    echo "🔄 Adding SNS target to EventBridge rule..."
    
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

# Function to create email subscription
create_email_subscription() {
    echo "🔄 Would you like to create an email subscription for HIGH/CRITICAL alerts? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "📧 Enter your email address:"
        read -r EMAIL_ADDRESS
        
        if [[ "$EMAIL_ADDRESS" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            aws sns subscribe \
                --topic-arn "$TOPIC_ARN" \
                --protocol email \
                --notification-endpoint "$EMAIL_ADDRESS"
            
            echo "  ✅ Email subscription created for HIGH/CRITICAL alerts"
            echo "  📧 Please check your email and confirm the subscription"
        else
            echo "  ❌ Invalid email address format"
        fi
    else
        echo "  ℹ️  Skipping email subscription creation"
    fi
}

# Function to display rule details
display_rule_details() {
    echo ""
    echo "📋 EventBridge Rule Details:"
    echo "   Rule Name: $RULE_NAME"
    echo "   Description: $DESCRIPTION"
    echo "   Event Pattern:"
    echo '   {
     "source": ["aws.guardduty"],
     "detail-type": ["GuardDuty Finding"],
     "detail": {
       "severity": [{ "numeric": [">=", 7.0] }]
     }
   }'
    echo ""
    echo "🎯 This rule will ONLY trigger for:"
    echo "   • GuardDuty findings with severity ≥ 7.0"
    echo "   • HIGH severity findings (7.0 - 8.9)"
    echo "   • CRITICAL severity findings (9.0 - 10.0)"
    echo ""
    echo "🚫 This rule will NOT trigger for:"
    echo "   • MEDIUM severity findings (4.0 - 6.9)"
    echo "   • LOW severity findings (1.0 - 3.9)"
}

# Main execution
main() {
    echo "🚨 GuardDuty HIGH/CRITICAL Severity Alert Setup"
    echo "=============================================="
    
    check_aws_cli
    
    echo ""
    create_sns_topic
    
    echo ""
    create_severity_filtered_rule
    
    echo ""
    add_sns_target
    
    echo ""
    add_sns_policy
    
    echo ""
    create_email_subscription
    
    display_rule_details
    
    echo ""
    echo "🎉 HIGH/CRITICAL severity alert setup completed!"
    echo ""
    echo "🧪 To test with HIGH/CRITICAL findings:"
    echo "   1. Run: ./generate-sample-findings.sh"
    echo "   2. Sample findings include HIGH severity examples"
    echo "   3. Check your email for notifications"
    echo ""
    echo "🧹 To clean up this specific rule:"
    echo "   aws events remove-targets --rule $RULE_NAME --ids 1"
    echo "   aws events delete-rule --name $RULE_NAME"
    echo "   aws sns delete-topic --topic-arn $TOPIC_ARN"
}

# Run main function
main
