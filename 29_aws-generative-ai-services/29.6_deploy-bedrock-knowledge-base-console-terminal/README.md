# Amazon Bedrock Knowledge Base Deployment Demo

## Overview
This 5-minute demonstration shows how to create and deploy an Amazon Bedrock Knowledge Base using both AWS Console and terminal commands. The knowledge base will be populated with sample documents and integrated with a vector database for semantic search capabilities.

## Prerequisites
- AWS CLI configured with appropriate permissions
- Access to Amazon Bedrock service
- IAM permissions for Bedrock, S3, and OpenSearch Serverless
- Python3 for testing (optional)

## Quick Start
For a streamlined experience, use the provided scripts:

```bash
# Run all setup steps automatically
./run-all-setup.sh

# Or run individual steps:
./01-setup-s3-documents.sh
./02-setup-opensearch-serverless.sh
./03-create-iam-role.sh
# (Then create knowledge base via console)
./04-test-knowledge-base.sh
```

## Demo Steps (5 minutes)

### Step 1: Create S3 Bucket and Upload Sample Documents (1 minute)

**Using the provided script:**
```bash
./01-setup-s3-documents.sh
```

**What the script does:**
- Creates a unique S3 bucket with timestamp suffix
- Creates three comprehensive sample documents:
  - `aws-services-overview.txt` - Overview of AWS services
  - `bedrock-features.txt` - Detailed Bedrock capabilities
  - `aws-best-practices.txt` - Well-Architected Framework guidance
- Uploads all documents to the S3 bucket
- Saves bucket name for use by other scripts

**Manual alternative via Console:**
- Create S3 bucket via S3 Console
- Upload documents via drag-and-drop interface

### Step 2: Create OpenSearch Serverless Collection (1.5 minutes)

**Using the provided script:**
```bash
./02-setup-opensearch-serverless.sh
```

**What the script does:**
- Creates encryption policy for the collection
- Creates network policy allowing public access
- Creates data access policy with proper permissions
- Creates OpenSearch Serverless collection with VECTORSEARCH type
- Waits for collection to become ACTIVE
- Saves collection endpoint for reference

**The script creates three security policies:**
- **Encryption Policy**: Uses AWS-owned keys for encryption
- **Network Policy**: Allows public access to collection and dashboard
- **Data Access Policy**: Grants necessary permissions for Bedrock and current user

### Step 3: Create IAM Role for Knowledge Base (1 minute)

**Using the provided script:**
```bash
./03-create-iam-role.sh
```

**What the script does:**
- Creates trust policy allowing Bedrock service to assume the role
- Creates `BedrockKnowledgeBaseRole` with the trust policy
- Creates custom policy with permissions for:
  - S3 bucket access (GetObject, ListBucket)
  - OpenSearch Serverless access (APIAccessAll)
  - Bedrock model invocation (InvokeModel)
- Attaches the custom policy to the role

### Step 4: Create Knowledge Base via Console (1.5 minutes)

**Console Steps:**
1. **Navigate to Amazon Bedrock Console:**
   - Go to AWS Console → Amazon Bedrock → Knowledge bases
   - Click "Create knowledge base"

2. **Configure Knowledge Base:**
   - Name: `AWS-Services-KB`
   - Description: `Knowledge base for AWS services information`
   - IAM Role: Select `BedrockKnowledgeBaseRole`

3. **Configure Data Source:**
   - Data source name: `AWS-Docs-Source`
   - S3 URI: `s3://[your-bucket-name]/` (bucket name shown in script output)
   - Chunking strategy: `Default chunking`

4. **Configure Vector Database:**
   - Vector database: `Amazon OpenSearch Serverless`
   - Collection: Select `bedrock-kb-collection`
   - Vector index name: `bedrock-kb-index`
   - Vector field name: `bedrock-kb-vector`
   - Text field name: `AMAZON_BEDROCK_TEXT_CHUNK`
   - Metadata field name: `AMAZON_BEDROCK_METADATA`

5. **Configure Embeddings Model:**
   - Embeddings model: `Titan Embeddings G1 - Text`

6. **Create and Sync:**
   - Click "Create knowledge base"
   - Wait for creation to complete
   - Click "Sync" to ingest the documents

### Step 5: Test Knowledge Base (1 minute)

**Using the provided script:**
```bash
./04-test-knowledge-base.sh
```

**What the script does:**
- Creates Python virtual environment for clean dependency management
- Installs boto3 for AWS SDK access
- Automatically finds the AWS-Services-KB knowledge base
- Tests with multiple queries:
  - "What is Amazon EC2?"
  - "Tell me about Amazon Bedrock features"
  - "What are the AWS Well-Architected Framework pillars?"
  - "How does Amazon S3 work?"
- Saves detailed retrieval results to JSON files
- Shows relevance scores and content previews

**Manual testing via Console:**
- Use the built-in test interface in the knowledge base details page
- Try sample queries to see semantic search results

## Script Files Included

| Script | Purpose | Duration |
|--------|---------|----------|
| `run-all-setup.sh` | Runs all setup steps automatically | 3-4 min |
| `01-setup-s3-documents.sh` | Creates S3 bucket and uploads documents | 1 min |
| `02-setup-opensearch-serverless.sh` | Creates OpenSearch Serverless collection | 1.5 min |
| `03-create-iam-role.sh` | Creates IAM role with proper permissions | 1 min |
| `04-test-knowledge-base.sh` | Tests knowledge base with sample queries | 1 min |
| `cleanup.sh` | Removes all demo resources | 2 min |

## Expected Results
- Successfully created S3 bucket with sample documents
- OpenSearch Serverless collection configured for vector search
- Knowledge base created and synchronized with documents
- Ability to retrieve relevant information using semantic search
- Test queries return relevant content with similarity scores

## Sample Knowledge Base Queries

The knowledge base can answer questions like:
- **"What is Amazon EC2?"** → Returns information about virtual servers
- **"Tell me about Bedrock features"** → Returns Bedrock capabilities and models
- **"What are the security best practices?"** → Returns Well-Architected security guidance
- **"How does S3 work?"** → Returns object storage information

## Console Alternative Steps

If demonstrating primarily through console:

1. **S3 Console**: Create bucket and upload documents via drag-and-drop
2. **OpenSearch Serverless Console**: Create collection with vector search configuration
3. **IAM Console**: Create role with appropriate policies
4. **Bedrock Console**: Create knowledge base with guided wizard
5. **Test Interface**: Use built-in test interface to query the knowledge base

## Troubleshooting

**Common Issues:**
- **OpenSearch Collection**: Ensure collection is in "Active" state before creating knowledge base
- **IAM Permissions**: Verify role has correct permissions for S3, OpenSearch, and Bedrock
- **Document Upload**: Check that documents are properly uploaded to S3
- **Synchronization**: Allow time for document synchronization to complete
- **Python/boto3**: The test script requires Python3 and creates a virtual environment

**Debug Commands:**
```bash
# Check if resources exist
aws s3 ls s3://$(cat .bucket-name)
aws opensearchserverless list-collections --query 'collectionSummaries[?name==`bedrock-kb-collection`]'
aws iam get-role --role-name BedrockKnowledgeBaseRole

# Check knowledge base status
aws bedrock-agent list-knowledge-bases --query 'knowledgeBaseSummaries[?name==`AWS-Services-KB`]'

# Check Python and virtual environment
python3 --version
ls -la bedrock-kb-venv/
```

## Cleanup
When the demo is complete, run the cleanup script:
```bash
./cleanup.sh
```

This will remove all created resources including:
- Bedrock Knowledge Base and data sources
- OpenSearch Serverless collection and policies
- S3 bucket and contents
- IAM role and policies
- Local files and virtual environment

## Citations and Documentation

1. **Amazon Bedrock Knowledge Bases User Guide**
   - https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html

2. **Creating a Knowledge Base**
   - https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-create.html

3. **Amazon OpenSearch Serverless Developer Guide**
   - https://docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless.html

4. **Bedrock Knowledge Base Data Sources**
   - https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-ds.html

5. **Vector Databases for RAG**
   - https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html

6. **IAM Roles for Bedrock Knowledge Bases**
   - https://docs.aws.amazon.com/bedrock/latest/userguide/kb-permissions.html
