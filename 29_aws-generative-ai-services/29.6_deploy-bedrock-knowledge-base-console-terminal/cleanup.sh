#!/bin/bash

# Cleanup script for Bedrock Knowledge Base Demo
# This script removes all resources created during the demonstration

echo "Starting cleanup of Bedrock Knowledge Base demo resources..."

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Delete Bedrock Knowledge Base
echo "Deleting Bedrock Knowledge Base..."
KB_ID=$(aws bedrock-agent list-knowledge-bases --query 'knowledgeBaseSummaries[?name==`AWS-Services-KB`].knowledgeBaseId' --output text 2>/dev/null)
if [ ! -z "$KB_ID" ]; then
    # Delete data source first
    DS_ID=$(aws bedrock-agent list-data-sources --knowledge-base-id $KB_ID --query 'dataSourceSummaries[0].dataSourceId' --output text 2>/dev/null)
    if [ ! -z "$DS_ID" ] && [ "$DS_ID" != "None" ]; then
        aws bedrock-agent delete-data-source --knowledge-base-id $KB_ID --data-source-id $DS_ID 2>/dev/null
        echo "Deleted data source: $DS_ID"
    fi
    
    # Delete knowledge base
    aws bedrock-agent delete-knowledge-base --knowledge-base-id $KB_ID 2>/dev/null
    echo "Bedrock Knowledge Base deleted: $KB_ID"
else
    echo "No Bedrock Knowledge Base found to delete"
fi

# Delete OpenSearch Serverless collection
echo "Deleting OpenSearch Serverless collection..."
aws opensearchserverless delete-collection --name bedrock-kb-collection 2>/dev/null
if [ $? -eq 0 ]; then
    echo "OpenSearch Serverless collection deletion initiated: bedrock-kb-collection"
    echo "Note: Collection deletion may take a few minutes to complete"
else
    echo "OpenSearch Serverless collection not found or already deleted"
fi

# Wait a moment for collection deletion to start
sleep 5

# Delete OpenSearch Serverless policies
echo "Deleting OpenSearch Serverless policies..."

# Delete IAM Identity Center security configuration
SECURITY_CONFIG_ID=$(aws opensearchserverless list-security-configs --type iamidentitycenter --query 'securityConfigSummaries[?name==`bedrock-kb-identity-center-config`].id' --output text 2>/dev/null)
if [ ! -z "$SECURITY_CONFIG_ID" ] && [ "$SECURITY_CONFIG_ID" != "None" ]; then
    aws opensearchserverless delete-security-config --id $SECURITY_CONFIG_ID 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Deleted IAM Identity Center security configuration: bedrock-kb-identity-center-config"
    fi
fi

aws opensearchserverless delete-access-policy --name bedrock-kb-data-access-policy --type data 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Deleted data access policy: bedrock-kb-data-access-policy"
fi

aws opensearchserverless delete-security-policy --name bedrock-kb-network-policy --type network 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Deleted network policy: bedrock-kb-network-policy"
fi

aws opensearchserverless delete-security-policy --name bedrock-kb-encryption-policy --type encryption 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Deleted encryption policy: bedrock-kb-encryption-policy"
fi

# Delete S3 bucket and contents
echo "Deleting S3 bucket and contents..."
DEMO_BUCKETS=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `bedrock-kb-docs`)].Name' --output text 2>/dev/null)

if [ ! -z "$DEMO_BUCKETS" ]; then
    for bucket in $DEMO_BUCKETS; do
        echo "Found demo bucket: $bucket"
        
        # Delete all objects in the bucket
        aws s3 rm s3://$bucket --recursive 2>/dev/null
        
        # Delete all versions if versioning was enabled
        aws s3api delete-objects --bucket $bucket --delete "$(aws s3api list-object-versions --bucket $bucket --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json)" 2>/dev/null
        
        # Delete delete markers
        aws s3api delete-objects --bucket $bucket --delete "$(aws s3api list-object-versions --bucket $bucket --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' --output json)" 2>/dev/null
        
        # Delete the bucket
        aws s3api delete-bucket --bucket $bucket 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "Deleted demo bucket: $bucket"
        else
            echo "Could not delete bucket: $bucket (may have dependencies)"
        fi
    done
else
    echo "No demo S3 buckets found"
fi

# Delete IAM role and policy
echo "Deleting IAM resources..."

# Detach and delete custom policy
aws iam detach-role-policy --role-name BedrockKnowledgeBaseRole --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/BedrockKnowledgeBasePolicy 2>/dev/null
aws iam delete-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/BedrockKnowledgeBasePolicy 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Deleted IAM policy: BedrockKnowledgeBasePolicy"
fi

# Delete IAM role
aws iam delete-role --role-name BedrockKnowledgeBaseRole 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Deleted IAM role: BedrockKnowledgeBaseRole"
else
    echo "BedrockKnowledgeBaseRole not found or already deleted"
fi

# Clean up local files
echo "Cleaning up local files..."
rm -f aws-services-overview.txt
rm -f bedrock-features.txt
rm -f aws-best-practices.txt
rm -f encryption-policy.json
rm -f network-policy.json
rm -f data-access-policy.json
rm -f kb-trust-policy.json
rm -f kb-permissions-policy.json
rm -f .bucket-name
rm -f data-access-policy-identity-center.json
rm -f .collection-endpoint
rm -f kb-response-*.json
rm -f test_knowledge_base.py

# Clean up virtual environment
if [ -d "bedrock-kb-venv" ]; then
    echo "Removing Python virtual environment..."
    rm -rf bedrock-kb-venv
    echo "Virtual environment removed"
fi

echo "Cleanup completed successfully!"
echo ""
echo "Note: OpenSearch Serverless collection deletion may take several minutes to complete."
echo "You can check the status in the AWS Console under OpenSearch Service → Serverless collections."
echo ""
echo "All demo resources have been removed or scheduled for deletion."
