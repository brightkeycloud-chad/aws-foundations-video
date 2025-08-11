#!/bin/bash

# Script 2: Create OpenSearch Serverless Collection
echo "Setting up OpenSearch Serverless collection for Knowledge Base..."

# Get current user ARN and account ID
USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "📝 Current user ARN: $USER_ARN"
echo "📝 Account ID: $ACCOUNT_ID"

# Create encryption policy
echo "Creating encryption policy..."
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

aws opensearchserverless create-security-policy \
    --name bedrock-kb-encryption-policy \
    --type encryption \
    --policy file://encryption-policy.json

if [ $? -eq 0 ]; then
    echo "✅ Created encryption policy: bedrock-kb-encryption-policy"
else
    echo "⚠️  Encryption policy may already exist or failed to create"
fi

# Create network policy
echo "Creating network policy..."
cat > network-policy.json << EOF
{
  "Rules": [
    {
      "ResourceType": "collection",
      "Resource": ["collection/bedrock-kb-collection"],
      "AllowFromPublic": true
    },
    {
      "ResourceType": "dashboard",
      "Resource": ["collection/bedrock-kb-collection"],
      "AllowFromPublic": true
    }
  ]
}
EOF

aws opensearchserverless create-security-policy \
    --name bedrock-kb-network-policy \
    --type network \
    --policy file://network-policy.json

if [ $? -eq 0 ]; then
    echo "✅ Created network policy: bedrock-kb-network-policy"
else
    echo "⚠️  Network policy may already exist or failed to create"
fi

# Create data access policy
echo "Creating data access policy..."
cat > data-access-policy.json << EOF
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
  "Principal": ["$USER_ARN", "arn:aws:iam::$ACCOUNT_ID:role/BedrockKnowledgeBaseRole"]
}
EOF

aws opensearchserverless create-access-policy \
    --name bedrock-kb-data-access-policy \
    --type data \
    --policy file://data-access-policy.json

if [ $? -eq 0 ]; then
    echo "✅ Created data access policy: bedrock-kb-data-access-policy"
else
    echo "⚠️  Data access policy may already exist or failed to create"
fi

# Create OpenSearch Serverless collection
echo "Creating OpenSearch Serverless collection..."
aws opensearchserverless create-collection \
    --name bedrock-kb-collection \
    --type VECTORSEARCH \
    --description "Knowledge base collection for Bedrock demo"

if [ $? -eq 0 ]; then
    echo "✅ OpenSearch Serverless collection creation initiated: bedrock-kb-collection"
    echo "⏳ Collection is being created (this may take 2-3 minutes)..."
    
    # Wait for collection to become active
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
else
    echo "❌ Failed to create OpenSearch Serverless collection"
    exit 1
fi

echo ""
echo "🎉 OpenSearch Serverless setup completed!"
echo "📝 Collection name: bedrock-kb-collection"
echo "📝 Collection type: VECTORSEARCH"
echo "💾 Collection endpoint saved to .collection-endpoint file"
