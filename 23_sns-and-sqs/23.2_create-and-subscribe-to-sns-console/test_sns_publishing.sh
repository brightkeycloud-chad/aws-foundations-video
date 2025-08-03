#!/bin/bash

# Test script for publishing messages to SNS topic
# Usage: ./test_sns_publishing.sh [topic-name] [region]

TOPIC_NAME=${1:-"demo-notifications-topic"}
REGION=${2:-"us-west-2"}

echo "Finding SNS topic: $TOPIC_NAME in region: $REGION"

# Get the topic ARN
TOPIC_ARN=$(aws sns list-topics --region "$REGION" --query "Topics[?contains(TopicArn, '$TOPIC_NAME')].TopicArn" --output text)

if [ -z "$TOPIC_ARN" ]; then
    echo "Error: Could not find topic '$TOPIC_NAME'. Make sure the topic exists and you have proper permissions."
    exit 1
fi

echo "Topic ARN: $TOPIC_ARN"
echo ""

# Send test messages
echo "Publishing test messages to SNS topic..."

# Message 1: Simple notification
echo "1. Publishing simple notification..."
aws sns publish \
    --topic-arn "$TOPIC_ARN" \
    --subject "Test Notification from AWS Demo" \
    --message "Hello! This is a test message from your AWS SNS demo. If you're receiving this, your SNS topic and subscription are working correctly!" \
    --region "$REGION"

# Message 2: Structured message
echo "2. Publishing structured notification..."
aws sns publish \
    --topic-arn "$TOPIC_ARN" \
    --subject "Order Confirmation" \
    --message "Dear Customer,

Your order has been confirmed!

Order Details:
- Order ID: ORD-12345
- Product: AWS Foundations Training
- Amount: $99.99
- Status: Confirmed

Thank you for your purchase!

Best regards,
AWS Demo Team" \
    --region "$REGION"

# Message 3: JSON message (useful for SQS integration)
echo "3. Publishing JSON message..."
aws sns publish \
    --topic-arn "$TOPIC_ARN" \
    --subject "System Alert" \
    --message '{"alertType": "info", "service": "demo", "message": "This is a JSON formatted message from SNS", "timestamp": "2025-01-01T12:00:00Z", "severity": "low"}' \
    --region "$REGION"

echo ""
echo "All test messages published successfully!"
echo "Check your email inbox for the delivered messages."
echo ""
echo "To view topic details:"
echo "aws sns get-topic-attributes --topic-arn '$TOPIC_ARN' --region $REGION"
echo ""
echo "To list subscriptions:"
echo "aws sns list-subscriptions-by-topic --topic-arn '$TOPIC_ARN' --region $REGION"
