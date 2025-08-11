#!/bin/bash

# Script 1: Create IAM Role for Bedrock Agent
echo "Creating IAM role for Bedrock Agent..."

# Create trust policy for Bedrock
cat > bedrock-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

echo "Created trust policy file: bedrock-trust-policy.json"

# Create the role
echo "Creating BedrockAgentRole..."
aws iam create-role \
    --role-name BedrockAgentRole \
    --assume-role-policy-document file://bedrock-trust-policy.json

if [ $? -eq 0 ]; then
    echo "✅ Successfully created BedrockAgentRole"
else
    echo "❌ Failed to create BedrockAgentRole (may already exist)"
fi

# Attach policy
echo "Attaching AmazonBedrockFullAccess policy..."
aws iam attach-role-policy \
    --role-name BedrockAgentRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess

if [ $? -eq 0 ]; then
    echo "✅ Successfully attached policy to BedrockAgentRole"
else
    echo "❌ Failed to attach policy"
fi

echo "IAM role setup completed!"
