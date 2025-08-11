#!/bin/bash

# Master script to run all setup steps for Bedrock Knowledge Base demo
echo "🚀 Starting Bedrock Knowledge Base Demo Setup"
echo "=============================================="

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

# Step 1: Setup S3 and Documents
echo "Step 1: Setting up S3 bucket and sample documents"
echo "=================================================="
./01-setup-s3-documents.sh
if [ $? -ne 0 ]; then
    echo "❌ Failed to setup S3 bucket and documents"
    exit 1
fi
echo ""

# Step 2: Setup OpenSearch Serverless
echo "Step 2: Setting up OpenSearch Serverless collection"
echo "===================================================="
./02-setup-opensearch-serverless.sh
if [ $? -ne 0 ]; then
    echo "❌ Failed to setup OpenSearch Serverless collection"
    exit 1
fi
echo ""

# Step 3: Create IAM Role
echo "Step 3: Creating IAM role for Knowledge Base"
echo "============================================="
./03-create-iam-role.sh
if [ $? -ne 0 ]; then
    echo "❌ Failed to create IAM role"
    exit 1
fi
echo ""

# Step 4: Instructions for console work
echo "Step 4: Create Knowledge Base (Console Required)"
echo "================================================"
echo "⚠️  MANUAL STEP REQUIRED:"
echo ""
echo "Please complete the following in the AWS Console:"
echo "1. Navigate to Amazon Bedrock → Knowledge bases → Create knowledge base"
echo "2. Knowledge Base Details:"
echo "   - Name: AWS-Services-KB"
echo "   - Description: Knowledge base for AWS services information"
echo "   - IAM Role: BedrockKnowledgeBaseRole"
echo "3. Data Source Configuration:"
echo "   - Data source name: AWS-Docs-Source"
echo "   - S3 URI: s3://$(cat .bucket-name)/"
echo "   - Chunking strategy: Default chunking"
echo "4. Vector Database Configuration:"
echo "   - Vector database: Amazon OpenSearch Serverless"
echo "   - Collection: bedrock-kb-collection"
echo "   - Vector index name: bedrock-kb-index"
echo "   - Vector field name: bedrock-kb-vector"
echo "   - Text field name: AMAZON_BEDROCK_TEXT_CHUNK"
echo "   - Metadata field name: AMAZON_BEDROCK_METADATA"
echo "5. Embeddings Model:"
echo "   - Select: Titan Embeddings G1 - Text"
echo "6. Create and Sync:"
echo "   - Click 'Create knowledge base'"
echo "   - Wait for creation to complete"
echo "   - Click 'Sync' to ingest the documents"
echo ""
echo "After creating and syncing the knowledge base, you can test it:"
echo "  ./04-test-knowledge-base.sh"
echo ""

echo "🎯 Setup completed! Ready for console configuration."
echo ""
echo "📝 Resources created:"
echo "   - S3 bucket: $(cat .bucket-name)"
echo "   - OpenSearch collection: bedrock-kb-collection"
echo "   - IAM role: BedrockKnowledgeBaseRole"
