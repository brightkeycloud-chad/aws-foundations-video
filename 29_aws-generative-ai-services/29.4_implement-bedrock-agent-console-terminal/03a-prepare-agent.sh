#!/bin/bash

# Script 3a: Prepare the Bedrock Agent after console creation
echo "Preparing Bedrock Agent for use..."

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Get agent ID
echo "Looking up agent ID..."
AGENT_ID=$(aws bedrock-agent list-agents --query 'agentSummaries[?agentName==`WeatherAgent`].agentId' --output text)

if [ -z "$AGENT_ID" ] || [ "$AGENT_ID" == "None" ]; then
    echo "❌ WeatherAgent not found. Please create the agent via the AWS Console first."
    echo "   Follow Step 3 in the README to create the agent using the console."
    exit 1
fi

echo "✅ Found WeatherAgent with ID: $AGENT_ID"

# Check current agent status
echo "Checking agent status..."
AGENT_STATUS=$(aws bedrock-agent get-agent --agent-id $AGENT_ID --query 'agent.agentStatus' --output text)
echo "Current agent status: $AGENT_STATUS"

if [ "$AGENT_STATUS" = "PREPARED" ]; then
    echo "✅ Agent is already prepared and ready to use!"
    exit 0
fi

# Update agent with proper configuration if needed
echo "Updating agent configuration..."
aws bedrock-agent update-agent \
    --agent-id $AGENT_ID \
    --agent-name "WeatherAgent" \
    --description "Demo agent for weather information" \
    --foundation-model "anthropic.claude-3-haiku-20240307-v1:0" \
    --agent-resource-role-arn "arn:aws:iam::$ACCOUNT_ID:role/BedrockAgentRole" \
    --instruction "You are a helpful weather assistant. When users ask about weather in different locations, use the get_weather function to provide current weather information. Be friendly and informative in your responses." \
    > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Agent configuration updated"
else
    echo "⚠️  Agent configuration update failed, but continuing..."
fi

# Wait for update to complete
echo "Waiting for agent update to complete..."
sleep 10

# Prepare the agent
echo "Preparing agent..."
aws bedrock-agent prepare-agent --agent-id $AGENT_ID > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Agent preparation initiated"
else
    echo "❌ Failed to initiate agent preparation"
    exit 1
fi

# Wait for preparation to complete
echo "Waiting for agent preparation to complete (this may take 30-60 seconds)..."
for i in {1..12}; do
    sleep 5
    STATUS=$(aws bedrock-agent get-agent --agent-id $AGENT_ID --query 'agent.agentStatus' --output text)
    echo "  Status check $i/12: $STATUS"
    
    if [ "$STATUS" = "PREPARED" ]; then
        echo "🎉 Agent is now PREPARED and ready to use!"
        exit 0
    elif [ "$STATUS" = "FAILED" ]; then
        echo "❌ Agent preparation failed!"
        FAILURE_REASONS=$(aws bedrock-agent get-agent --agent-id $AGENT_ID --query 'agent.failureReasons' --output text)
        echo "Failure reasons: $FAILURE_REASONS"
        exit 1
    fi
done

echo "⚠️  Agent preparation is taking longer than expected."
echo "   Current status: $STATUS"
echo "   You can check the status manually in the AWS Console or run this script again."
exit 1
