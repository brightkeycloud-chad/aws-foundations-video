#!/bin/bash

# Script 3b: Add Lambda permission for Bedrock Agent
echo "Adding Lambda permission for Bedrock Agent..."

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Get agent ID
echo "Looking up agent ID..."
AGENT_ID=$(aws bedrock-agent list-agents --query 'agentSummaries[?agentName==`WeatherAgent`].agentId' --output text)

if [ -z "$AGENT_ID" ] || [ "$AGENT_ID" == "None" ]; then
    echo "❌ WeatherAgent not found. Please create the agent via the AWS Console first."
    exit 1
fi

echo "✅ Found WeatherAgent with ID: $AGENT_ID"

# Check if Lambda function exists
echo "Checking Lambda function..."
aws lambda get-function --function-name bedrock-agent-weather > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Lambda function 'bedrock-agent-weather' not found."
    echo "   Please run ./02-create-lambda-function.sh first."
    exit 1
fi

echo "✅ Lambda function exists"

# Add permission for Bedrock to invoke Lambda function
echo "Adding permission for Bedrock to invoke Lambda function..."
aws lambda add-permission \
    --function-name bedrock-agent-weather \
    --statement-id bedrock-agent-invoke \
    --action lambda:InvokeFunction \
    --principal bedrock.amazonaws.com \
    --source-arn "arn:aws:bedrock:us-east-1:$ACCOUNT_ID:agent/$AGENT_ID" \
    > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Successfully added Lambda permission for Bedrock agent"
elif [ $? -eq 254 ]; then
    # Check if permission already exists
    aws lambda get-policy --function-name bedrock-agent-weather | grep -q "bedrock-agent-invoke"
    if [ $? -eq 0 ]; then
        echo "✅ Lambda permission already exists"
    else
        echo "❌ Failed to add Lambda permission"
        exit 1
    fi
else
    echo "❌ Failed to add Lambda permission"
    exit 1
fi

echo "🎉 Lambda permission setup completed!"
echo "The Bedrock agent can now invoke the Lambda function."
