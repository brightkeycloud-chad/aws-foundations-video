#!/bin/bash

# Get collection endpoint
if [ -f ".collection-endpoint" ]; then
    ENDPOINT=$(cat .collection-endpoint)
else
    echo "❌ Collection endpoint not found. Run ./02-setup-opensearch-serverless.sh first."
    exit 1
fi

echo "Creating index: bedrock-knowledge-base-default-index"
echo "Endpoint: $ENDPOINT"

# Create the index using AWS CLI and curl
curl -X PUT \
  "${ENDPOINT}/bedrock-knowledge-base-default-index" \
  -H "Content-Type: application/json" \
  -d @create-index.json \
  --aws-sigv4 "aws:amz:us-east-1:aoss" \
  --user "$(aws configure get aws_access_key_id):$(aws configure get aws_secret_access_key)"

echo ""
echo "✅ Index creation request sent"
