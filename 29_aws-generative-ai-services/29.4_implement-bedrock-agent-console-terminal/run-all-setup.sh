#!/bin/bash

# Master script to run all setup steps for Bedrock Agent demo
echo "🚀 Starting Bedrock Agent Demo Setup"
echo "===================================="

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI is not configured or credentials are invalid"
    echo "Please run 'aws configure' first"
    exit 1
fi

echo "✅ AWS CLI is configured"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "📝 Using AWS Account: $ACCOUNT_ID"
echo ""

# Step 1: Create IAM Role
echo "Step 1: Creating IAM Role for Bedrock Agent"
echo "============================================"
./01-create-iam-role.sh
echo ""

# Step 2: Create Lambda Function
echo "Step 2: Creating Lambda Function"
echo "================================"
./02-create-lambda-function.sh
echo ""

# Step 3: Instructions for console work
echo "Step 3: Create Bedrock Agent (Console Required)"
echo "==============================================="
echo "⚠️  MANUAL STEP REQUIRED:"
echo ""
echo "Please complete the following in the AWS Console:"
echo "1. Navigate to Amazon Bedrock → Agents → Create Agent"
echo "2. Agent name: WeatherAgent"
echo "3. Description: Demo agent for weather information"
echo "4. Foundation model: Claude 3 Haiku"
echo "5. Agent resource role: BedrockAgentRole"
echo "6. Add Action Group:"
echo "   - Name: WeatherActions"
echo "   - Description: Get weather information"
echo "   - Action group type: Define with function details"
echo "   - Lambda function: bedrock-agent-weather"
echo "   - Function details:"
echo "     * Function name: get_weather"
echo "     * Description: Get current weather for a location"
echo "     * Parameters: location (string, required)"
echo "7. Save and create the agent"
echo ""
echo "After creating the agent in the console, run these scripts in order:"
echo "  ./03a-prepare-agent.sh      # Prepare the agent"
echo "  ./03b-add-lambda-permission.sh  # Add Lambda permission"
echo "  ./03-test-agent.sh          # Test the agent"
echo ""

echo "🎯 Setup completed! Ready for console configuration."
