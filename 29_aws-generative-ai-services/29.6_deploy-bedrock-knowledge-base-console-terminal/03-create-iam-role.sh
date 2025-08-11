#!/bin/bash

# Script 3: Create IAM Role for Knowledge Base
echo "Creating IAM role for Bedrock Knowledge Base..."

# Get bucket name from previous script
if [ -f ".bucket-name" ]; then
    BUCKET_NAME=$(cat .bucket-name)
    echo "📝 Using bucket: $BUCKET_NAME"
else
    echo "❌ Bucket name not found. Please run ./01-setup-s3-documents.sh first."
    exit 1
fi

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create trust policy for Bedrock Knowledge Base
echo "Creating trust policy..."
cat > kb-trust-policy.json << EOF
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

echo "✅ Created trust policy file: kb-trust-policy.json"

# Create the role
echo "Creating BedrockKnowledgeBaseRole..."
aws iam create-role \
    --role-name BedrockKnowledgeBaseRole \
    --assume-role-policy-document file://kb-trust-policy.json

if [ $? -eq 0 ]; then
    echo "✅ Successfully created BedrockKnowledgeBaseRole"
else
    echo "⚠️  BedrockKnowledgeBaseRole may already exist"
fi

# Create custom policy for knowledge base
echo "Creating custom permissions policy..."
cat > kb-permissions-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::$BUCKET_NAME",
        "arn:aws:s3:::$BUCKET_NAME/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "aoss:APIAccessAll"
      ],
      "Resource": "arn:aws:aoss:*:*:collection/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel"
      ],
      "Resource": "arn:aws:bedrock:*::foundation-model/*"
    }
  ]
}
EOF

echo "✅ Created permissions policy file: kb-permissions-policy.json"

# Create the policy
aws iam create-policy \
    --policy-name BedrockKnowledgeBasePolicy \
    --policy-document file://kb-permissions-policy.json

if [ $? -eq 0 ]; then
    echo "✅ Successfully created BedrockKnowledgeBasePolicy"
else
    echo "⚠️  BedrockKnowledgeBasePolicy may already exist"
fi

# Attach policy to role
echo "Attaching policy to role..."
aws iam attach-role-policy \
    --role-name BedrockKnowledgeBaseRole \
    --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/BedrockKnowledgeBasePolicy

if [ $? -eq 0 ]; then
    echo "✅ Successfully attached policy to BedrockKnowledgeBaseRole"
else
    echo "❌ Failed to attach policy to role"
    exit 1
fi

# Wait a moment for role to propagate
echo "Waiting for IAM role to propagate..."
sleep 10

echo ""
echo "🎉 IAM role setup completed!"
echo "📝 Role name: BedrockKnowledgeBaseRole"
echo "📝 Policy name: BedrockKnowledgeBasePolicy"
echo "📝 Role ARN: arn:aws:iam::$ACCOUNT_ID:role/BedrockKnowledgeBaseRole"
