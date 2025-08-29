#!/bin/bash

# AWS Health Event Monitor Provisioning Script
# This script creates all resources needed for the EventBridge Health monitoring demo

set -e  # Exit on any error

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
EMAIL_ADDRESS="chad@brightkeycloud.com"

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
    print_status "Getting AWS account information..."
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    AWS_REGION=$(aws configure get region)
    
    if [ -z "$AWS_REGION" ]; then
        AWS_REGION="us-east-1"
        print_warning "No default region found, using us-east-1"
    fi
    
    print_success "Account ID: $AWS_ACCOUNT_ID"
    print_success "Region: $AWS_REGION"
}

# Function to prompt for email address
get_email_address() {
    if [ -z "$EMAIL_ADDRESS" ]; then
        echo -n "Enter your email address for SNS notifications: "
        read EMAIL_ADDRESS
        
        if [ -z "$EMAIL_ADDRESS" ]; then
            print_error "Email address is required"
            exit 1
        fi
    fi
}

# Function to create SNS topic and subscription
create_sns_topic() {
    print_status "Creating SNS topic: $SNS_TOPIC_NAME"
    
    SNS_TOPIC_ARN=$(aws sns create-topic \
        --name "$SNS_TOPIC_NAME" \
        --query 'TopicArn' \
        --output text)
    
    print_success "SNS topic created: $SNS_TOPIC_ARN"
    
    print_status "Creating email subscription..."
    aws sns subscribe \
        --topic-arn "$SNS_TOPIC_ARN" \
        --protocol email \
        --notification-endpoint "$EMAIL_ADDRESS" > /dev/null
    
    print_success "Email subscription created. Please check your email and confirm the subscription."
}

# Function to create Lambda function
create_lambda_function() {
    print_status "Creating Lambda function: $FUNCTION_NAME"
    
    # Create the Lambda function code
    cat > lambda_function.py << 'EOF'
import json
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event, indent=2)}")
    
    # Extract health event details
    detail = event.get('detail', {})
    
    # Create human-readable summary
    summary = create_health_summary(detail, event)
    
    # Send to SNS
    send_sns_notification(summary)
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Health event processed successfully',
            'summary': summary
        })
    }

def create_health_summary(detail, event):
    service = detail.get('service', 'Unknown Service')
    event_type = detail.get('eventTypeCode', 'Unknown Event')
    category = detail.get('eventTypeCategory', 'unknown')
    status = detail.get('statusCode', 'unknown')
    region = detail.get('eventRegion', 'unknown')
    scope = detail.get('eventScopeCode', 'unknown')
    
    # Extract description
    descriptions = detail.get('eventDescription', [])
    description = descriptions[0].get('latestDescription', 'No description available') if descriptions else 'No description available'
    
    # Format times
    start_time = detail.get('startTime', 'Unknown')
    end_time = detail.get('endTime', 'Ongoing')
    
    # Count affected resources
    affected_entities = detail.get('affectedEntities', [])
    resource_count = len(affected_entities)
    
    # Create severity indicator
    severity_emoji = get_severity_emoji(category, status)
    
    summary = f"""
🏥 AWS HEALTH ALERT {severity_emoji}

📋 Event Summary:
• Service: {service}
• Event Type: {event_type.replace('_', ' ').title()}
• Category: {category.title()}
• Status: {status.title()}
• Region: {region}
• Scope: {scope.replace('_', ' ').title()}

⏰ Timeline:
• Started: {start_time}
• Ended: {end_time}

📊 Impact:
• Affected Resources: {resource_count}
• Account: {detail.get('affectedAccount', 'Multiple')}

📝 Description:
{description[:500]}{'...' if len(description) > 500 else ''}

🔗 Event ARN:
{detail.get('eventArn', 'N/A')}

Generated at: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}
    """.strip()
    
    return summary

def get_severity_emoji(category, status):
    if category == 'issue' and status == 'open':
        return '🚨'
    elif category == 'scheduledChange':
        return '📅'
    elif category == 'investigation':
        return '🔍'
    elif status == 'closed':
        return '✅'
    else:
        return '📢'

def send_sns_notification(message):
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    if not sns_topic_arn:
        print("SNS_TOPIC_ARN environment variable not set")
        return
    
    sns = boto3.client('sns')
    
    try:
        response = sns.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject='AWS Health Event Alert'
        )
        print(f"SNS message sent successfully: {response['MessageId']}")
    except Exception as e:
        print(f"Error sending SNS message: {str(e)}")
EOF

    # Create deployment package
    zip -q lambda_function.zip lambda_function.py
    
    # Create IAM role for Lambda
    print_status "Creating IAM role for Lambda function..."
    
    cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

    ROLE_ARN=$(aws iam create-role \
        --role-name "${FUNCTION_NAME}Role" \
        --assume-role-policy-document file://trust-policy.json \
        --query 'Role.Arn' \
        --output text 2>/dev/null || \
        aws iam get-role --role-name "${FUNCTION_NAME}Role" --query 'Role.Arn' --output text)
    
    print_success "IAM role created/found: $ROLE_ARN"
    
    # Attach basic execution policy
    aws iam attach-role-policy \
        --role-name "${FUNCTION_NAME}Role" \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null || true
    
    # Create SNS publish policy
    cat > sns-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "$SNS_TOPIC_ARN"
        }
    ]
}
EOF

    aws iam put-role-policy \
        --role-name "${FUNCTION_NAME}Role" \
        --policy-name "SNSPublishPolicy" \
        --policy-document file://sns-policy.json
    
    print_status "Waiting for IAM role to propagate..."
    sleep 10
    
    # Create Lambda function
    LAMBDA_ARN=$(aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime python3.12 \
        --role "$ROLE_ARN" \
        --handler lambda_function.lambda_handler \
        --zip-file fileb://lambda_function.zip \
        --environment Variables="{SNS_TOPIC_ARN=$SNS_TOPIC_ARN}" \
        --query 'FunctionArn' \
        --output text 2>/dev/null || \
        aws lambda get-function --function-name "$FUNCTION_NAME" --query 'Configuration.FunctionArn' --output text)
    
    print_success "Lambda function created: $LAMBDA_ARN"
    
    # Clean up temporary files
    rm -f lambda_function.py lambda_function.zip trust-policy.json sns-policy.json
}

# Function to create EventBridge rule
create_eventbridge_rule() {
    print_status "Creating EventBridge rule: $RULE_NAME"
    
    # Create event pattern for AWS Health events
    cat > event-pattern.json << 'EOF'
{
    "source": ["aws.health"],
    "detail-type": ["AWS Health Event"]
}
EOF

    # Create the rule
    aws events put-rule \
        --name "$RULE_NAME" \
        --description "Captures all AWS Health events for processing" \
        --event-pattern file://event-pattern.json \
        --state ENABLED > /dev/null
    
    print_success "EventBridge rule created: $RULE_NAME"
    
    # Add Lambda permission for EventBridge
    print_status "Adding Lambda permission for EventBridge..."
    aws lambda add-permission \
        --function-name "$FUNCTION_NAME" \
        --statement-id "eventbridge-health-rule" \
        --action "lambda:InvokeFunction" \
        --principal events.amazonaws.com \
        --source-arn "arn:aws:events:$AWS_REGION:$AWS_ACCOUNT_ID:rule/$RULE_NAME" 2>/dev/null || true
    
    # Add Lambda as target
    print_status "Adding Lambda function as target..."
    cat > targets.json << EOF
[
    {
        "Id": "1",
        "Arn": "$LAMBDA_ARN"
    }
]
EOF

    aws events put-targets \
        --rule "$RULE_NAME" \
        --targets file://targets.json > /dev/null
    
    print_success "Lambda function added as target"
    
    # Clean up temporary files
    rm -f event-pattern.json targets.json
}

# Function to display summary
display_summary() {
    echo
    print_success "=== AWS Health Monitor Setup Complete ==="
    echo
    echo "Resources created:"
    echo "• SNS Topic: $SNS_TOPIC_ARN"
    echo "• Lambda Function: $LAMBDA_ARN"
    echo "• EventBridge Rule: $RULE_NAME"
    echo "• Email Subscription: $EMAIL_ADDRESS"
    echo
    print_warning "Important: Please confirm your email subscription to receive notifications!"
    echo
    print_status "To test the system, run: ./test-health-event.sh"
    print_status "To clean up resources, run: ./cleanup.sh"
}

# Main execution
main() {
    echo "🏥 AWS Health Event Monitor Setup"
    echo "=================================="
    echo
    
    get_aws_info
    get_email_address
    create_sns_topic
    create_lambda_function
    create_eventbridge_rule
    display_summary
}

# Run main function
main "$@"
