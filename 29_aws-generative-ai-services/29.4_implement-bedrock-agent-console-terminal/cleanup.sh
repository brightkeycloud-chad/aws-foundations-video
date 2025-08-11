#!/bin/bash

# Cleanup script for Bedrock Agent Demo
# This script removes all resources created during the demonstration

echo "Starting cleanup of Bedrock Agent demo resources..."

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Delete Bedrock Agent
echo "Deleting Bedrock Agent..."
AGENT_ID=$(aws bedrock-agent list-agents --query 'agentSummaries[?agentName==`WeatherAgent`].agentId' --output text 2>/dev/null)
if [ ! -z "$AGENT_ID" ]; then
    aws bedrock-agent delete-agent --agent-id $AGENT_ID --skip-resource-in-use-check 2>/dev/null
    echo "Bedrock Agent deleted: $AGENT_ID"
else
    echo "No Bedrock Agent found to delete"
fi

# Delete Lambda function
echo "Deleting Lambda function..."
aws lambda delete-function --function-name bedrock-agent-weather 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Lambda function deleted: bedrock-agent-weather"
else
    echo "Lambda function not found or already deleted"
fi

# Delete IAM roles and policies
echo "Deleting IAM roles..."

# Detach and delete BedrockAgentRole
aws iam detach-role-policy --role-name BedrockAgentRole --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess 2>/dev/null
aws iam delete-role --role-name BedrockAgentRole 2>/dev/null
if [ $? -eq 0 ]; then
    echo "IAM role deleted: BedrockAgentRole"
else
    echo "BedrockAgentRole not found or already deleted"
fi

# Detach and delete lambda-execution-role
aws iam detach-role-policy --role-name lambda-execution-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null
aws iam delete-role --role-name lambda-execution-role 2>/dev/null
if [ $? -eq 0 ]; then
    echo "IAM role deleted: lambda-execution-role"
else
    echo "lambda-execution-role not found or already deleted"
fi

# Clean up local files
echo "Cleaning up local files..."
rm -f bedrock-trust-policy.json
rm -f lambda_function.py
rm -f lambda-function.zip
rm -f response.json
rm -f response-seattle.json
rm -f response-newyork.json
rm -f response-miami.json
rm -f test_agent.py

# Clean up virtual environment
if [ -d "bedrock-agent-venv" ]; then
    echo "Removing Python virtual environment..."
    rm -rf bedrock-agent-venv
    echo "Virtual environment removed"
fi

echo "Cleanup completed successfully!"
echo "All demo resources have been removed."
