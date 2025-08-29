#!/bin/bash

echo "Setting up IAM Identity Center for OpenSearch Serverless..."

# Get IAM Identity Center instance ARN
INSTANCE_ARN=$(aws sso-admin list-instances --query 'Instances[0].InstanceArn' --output text)
INSTANCE_ID=$(echo $INSTANCE_ARN | sed 's|.*instance/||')

if [ "$INSTANCE_ARN" = "None" ] || [ -z "$INSTANCE_ARN" ]; then
    echo "❌ No IAM Identity Center instance found. Please enable IAM Identity Center first."
    exit 1
fi

echo "📝 IAM Identity Center Instance ARN: $INSTANCE_ARN"
echo "📝 Instance ID: $INSTANCE_ID"

# Create IAM Identity Center security configuration
echo "Creating IAM Identity Center security configuration..."
aws opensearchserverless create-security-config \
    --name "bedrock-kb-identity-center-config" \
    --description "IAM Identity Center config for Bedrock Knowledge Base" \
    --type "iamidentitycenter" \
    --iam-identity-center-options "{
        \"instanceArn\": \"$INSTANCE_ARN\",
        \"userAttribute\": \"UserName\",
        \"groupAttribute\": \"GroupId\"
    }"

if [ $? -eq 0 ]; then
    echo "✅ Created IAM Identity Center security configuration"
else
    echo "⚠️  Security configuration may already exist"
fi

# Update data access policy with IAM Identity Center principals
echo "Updating data access policy for IAM Identity Center..."
cat > data-access-policy-identity-center.json << EOF
[
  {
    "Rules": [
      {
        "ResourceType": "collection",
        "Resource": ["collection/bedrock-kb-collection"],
        "Permission": [
          "aoss:CreateCollectionItems",
          "aoss:DeleteCollectionItems",
          "aoss:UpdateCollectionItems",
          "aoss:DescribeCollectionItems"
        ]
      },
      {
        "ResourceType": "index",
        "Resource": ["index/bedrock-kb-collection/*"],
        "Permission": [
          "aoss:CreateIndex",
          "aoss:DeleteIndex",
          "aoss:UpdateIndex",
          "aoss:DescribeIndex",
          "aoss:ReadDocument",
          "aoss:WriteDocument"
        ]
      }
    ],
    "Principal": [
      "iamidentitycenter/$INSTANCE_ID/user/chad@brightkeycloud.com",
      "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/BedrockKnowledgeBaseRole"
    ]
  }
]
EOF

# Update the data access policy
POLICY_VERSION=$(aws opensearchserverless get-access-policy --name bedrock-kb-data-access-policy --type data --query 'accessPolicyDetail.policyVersion' --output text)
aws opensearchserverless update-access-policy \
    --name bedrock-kb-data-access-policy \
    --type data \
    --policy-version $POLICY_VERSION \
    --policy file://data-access-policy-identity-center.json

if [ $? -eq 0 ]; then
    echo "✅ Updated data access policy with IAM Identity Center principals"
else
    echo "❌ Failed to update data access policy"
    exit 1
fi

echo ""
echo "🎉 IAM Identity Center setup completed!"
echo "📝 You can now access OpenSearch Serverless using your IAM Identity Center credentials"
echo "📝 Principal format: iamidentitycenter/$INSTANCE_ID/user/chad@brightkeycloud.com"
