#!/bin/bash

# Script 2: Create OpenSearch Serverless Collection
echo "Setting up OpenSearch Serverless collection for Knowledge Base..."

# Get current user ARN and account ID
USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "📝 Current user ARN: $USER_ARN"
echo "📝 Account ID: $ACCOUNT_ID"

# Create or update encryption policy
echo "Creating/updating encryption policy..."
cat > encryption-policy.json << EOF
{
  "Rules": [
    {
      "ResourceType": "collection",
      "Resource": ["collection/bedrock-kb-collection"]
    }
  ],
  "AWSOwnedKey": true
}
EOF

# Check if policy exists
if aws opensearchserverless get-security-policy --name bedrock-kb-encryption-policy --type encryption >/dev/null 2>&1; then
    echo "📝 Encryption policy exists, updating..."
    POLICY_VERSION=$(aws opensearchserverless get-security-policy --name bedrock-kb-encryption-policy --type encryption --query 'securityPolicyDetail.policyVersion' --output text)
    aws opensearchserverless update-security-policy \
        --name bedrock-kb-encryption-policy \
        --type encryption \
        --policy-version $POLICY_VERSION \
        --policy file://encryption-policy.json
    echo "✅ Updated encryption policy: bedrock-kb-encryption-policy"
else
    echo "📝 Creating new encryption policy..."
    aws opensearchserverless create-security-policy \
        --name bedrock-kb-encryption-policy \
        --type encryption \
        --policy file://encryption-policy.json
    echo "✅ Created encryption policy: bedrock-kb-encryption-policy"
fi

# Create or update network policy
echo "Creating/updating network policy..."
cat > network-policy.json << EOF
[
  {
    "AllowFromPublic": true,
    "Rules": [
      {
        "ResourceType": "collection",
        "Resource": ["collection/bedrock-kb-collection"]
      },
      {
        "ResourceType": "dashboard",
        "Resource": ["collection/bedrock-kb-collection"]
      }
    ]
  }
]
EOF

# Check if policy exists
if aws opensearchserverless get-security-policy --name bedrock-kb-network-policy --type network >/dev/null 2>&1; then
    echo "📝 Network policy exists, updating..."
    POLICY_VERSION=$(aws opensearchserverless get-security-policy --name bedrock-kb-network-policy --type network --query 'securityPolicyDetail.policyVersion' --output text)
    aws opensearchserverless update-security-policy \
        --name bedrock-kb-network-policy \
        --type network \
        --policy-version $POLICY_VERSION \
        --policy file://network-policy.json
    echo "✅ Updated network policy: bedrock-kb-network-policy"
else
    echo "📝 Creating new network policy..."
    aws opensearchserverless create-security-policy \
        --name bedrock-kb-network-policy \
        --type network \
        --policy file://network-policy.json
    echo "✅ Created network policy: bedrock-kb-network-policy"
fi

# Create or update data access policy
echo "Creating/updating data access policy..."

# Get IAM Identity Center instance for proper principal format
INSTANCE_ARN=$(aws sso-admin list-instances --query 'Instances[0].InstanceArn' --output text 2>/dev/null)
if [ "$INSTANCE_ARN" != "None" ] && [ ! -z "$INSTANCE_ARN" ]; then
    INSTANCE_ID=$(echo $INSTANCE_ARN | sed 's|.*instance/||')
    PRINCIPAL_ARN="iamidentitycenter/$INSTANCE_ID/user/chad@brightkeycloud.com"
    echo "📝 Using IAM Identity Center principal: $PRINCIPAL_ARN"
    
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
        }" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Created IAM Identity Center security configuration"
    else
        echo "📝 IAM Identity Center security configuration already exists"
    fi
else
    # Fallback to SSO role ARN
    PRINCIPAL_ARN="arn:aws:iam::$ACCOUNT_ID:role/AWSReservedSSO_AdministratorAccess_b7e6a830400a9ac7"
    echo "📝 Using SSO role ARN: $PRINCIPAL_ARN"
fi

cat > data-access-policy.json << EOF
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
    "Principal": ["$PRINCIPAL_ARN", "arn:aws:iam::$ACCOUNT_ID:role/BedrockKnowledgeBaseRole"]
  }
]
EOF

# Check if policy exists
if aws opensearchserverless get-access-policy --name bedrock-kb-data-access-policy --type data >/dev/null 2>&1; then
    echo "📝 Data access policy exists, updating..."
    POLICY_VERSION=$(aws opensearchserverless get-access-policy --name bedrock-kb-data-access-policy --type data --query 'accessPolicyDetail.policyVersion' --output text)
    aws opensearchserverless update-access-policy \
        --name bedrock-kb-data-access-policy \
        --type data \
        --policy-version $POLICY_VERSION \
        --policy file://data-access-policy.json
    echo "✅ Updated data access policy: bedrock-kb-data-access-policy"
else
    echo "📝 Creating new data access policy..."
    aws opensearchserverless create-access-policy \
        --name bedrock-kb-data-access-policy \
        --type data \
        --policy file://data-access-policy.json
    echo "✅ Created data access policy: bedrock-kb-data-access-policy"
fi

# Create OpenSearch Serverless collection if it doesn't exist
echo "Creating OpenSearch Serverless collection..."

# Check if collection exists
if aws opensearchserverless list-collections --query 'collectionSummaries[?name==`bedrock-kb-collection`]' --output text | grep -q bedrock-kb-collection; then
    echo "📝 Collection already exists: bedrock-kb-collection"
    STATUS=$(aws opensearchserverless list-collections --query 'collectionSummaries[?name==`bedrock-kb-collection`].status' --output text)
    echo "📝 Current status: $STATUS"
    
    if [ "$STATUS" = "ACTIVE" ]; then
        ENDPOINT=$(aws opensearchserverless list-collections --query 'collectionSummaries[?name==`bedrock-kb-collection`].collectionEndpoint' --output text)
        echo "📝 Collection endpoint: $ENDPOINT"
        echo $ENDPOINT > .collection-endpoint
        echo "✅ Using existing active collection"
    else
        echo "⏳ Waiting for existing collection to become active..."
    fi
else
    echo "📝 Creating new collection..."
    aws opensearchserverless create-collection \
        --name bedrock-kb-collection \
        --type VECTORSEARCH \
        --description "Knowledge base collection for Bedrock demo"
    
    if [ $? -eq 0 ]; then
        echo "✅ OpenSearch Serverless collection creation initiated: bedrock-kb-collection"
        echo "⏳ Collection is being created (this may take 2-3 minutes)..."
    else
        echo "❌ Failed to create OpenSearch Serverless collection"
        exit 1
    fi
fi

# Wait for collection to become active (for both new and existing collections)
if [ "$STATUS" != "ACTIVE" ]; then
    echo "Waiting for collection to become active..."
    for i in {1..12}; do
        sleep 15
        STATUS=$(aws opensearchserverless list-collections --query 'collectionSummaries[?name==`bedrock-kb-collection`].status' --output text)
        echo "  Status check $i/12: $STATUS"
        
        if [ "$STATUS" = "ACTIVE" ]; then
            echo "🎉 Collection is now ACTIVE!"
            
            # Get collection endpoint
            ENDPOINT=$(aws opensearchserverless list-collections --query 'collectionSummaries[?name==`bedrock-kb-collection`].collectionEndpoint' --output text)
            echo "📝 Collection endpoint: $ENDPOINT"
            
            # Save endpoint for other scripts
            echo $ENDPOINT > .collection-endpoint
            break
        elif [ "$STATUS" = "FAILED" ]; then
            echo "❌ Collection creation failed!"
            exit 1
        fi
        
        if [ $i -eq 12 ]; then
            echo "⚠️  Collection creation is taking longer than expected."
            echo "   Current status: $STATUS"
            echo "   You can check the status manually in the AWS Console."
        fi
    done
fi

echo ""
echo "🎉 OpenSearch Serverless setup completed!"
echo "📝 Collection name: bedrock-kb-collection"
echo "📝 Collection type: VECTORSEARCH"
echo "💾 Collection endpoint saved to .collection-endpoint file"
