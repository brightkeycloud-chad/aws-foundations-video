#!/bin/bash

# Test script for sending messages to SQS queue
# Usage: ./send_test_messages.sh [queue-name] [region]

QUEUE_NAME=${1:-"demo-lambda-trigger-queue"}
REGION=${2:-"us-east-1"}

echo "Getting queue URL for: $QUEUE_NAME in region: $REGION"

# Get the queue URL
QUEUE_URL=$(aws sqs get-queue-url --queue-name "$QUEUE_NAME" --region "$REGION" --query 'QueueUrl' --output text)

if [ $? -ne 0 ]; then
    echo "Error: Could not get queue URL. Make sure the queue exists and you have proper permissions."
    exit 1
fi

echo "Queue URL: $QUEUE_URL"
echo ""

# Send test messages
echo "Sending test messages..."

# Message 1: JSON order message
echo "1. Sending JSON order message..."
aws sqs send-message \
    --queue-url "$QUEUE_URL" \
    --message-body '{"orderId": "ORD-12345", "customerId": "CUST-001", "amount": 99.99, "product": "AWS Training Course"}' \
    --region "$REGION"

# Message 2: Simple text message
echo "2. Sending simple text message..."
aws sqs send-message \
    --queue-url "$QUEUE_URL" \
    --message-body "Hello from SQS! This is a simple text message." \
    --region "$REGION"

# Message 3: Another JSON message with different structure
echo "3. Sending notification message..."
aws sqs send-message \
    --queue-url "$QUEUE_URL" \
    --message-body '{"type": "notification", "userId": "user123", "message": "Your order has been processed", "timestamp": "2025-01-01T12:00:00Z"}' \
    --region "$REGION"

# Message 4: Batch of messages
echo "4. Sending batch of messages..."
aws sqs send-message-batch \
    --queue-url "$QUEUE_URL" \
    --entries '[
        {
            "Id": "msg1",
            "MessageBody": "{\"orderId\": \"ORD-67890\", \"customerId\": \"CUST-002\", \"amount\": 149.99}"
        },
        {
            "Id": "msg2", 
            "MessageBody": "{\"orderId\": \"ORD-11111\", \"customerId\": \"CUST-003\", \"amount\": 79.99}"
        }
    ]' \
    --region "$REGION"

echo ""
echo "All test messages sent successfully!"
echo "Check your Lambda function logs in CloudWatch to see the processing results."
echo ""
echo "To view CloudWatch logs:"
echo "aws logs describe-log-groups --log-group-name-prefix '/aws/lambda/demo-sqs-processor' --region $REGION"
