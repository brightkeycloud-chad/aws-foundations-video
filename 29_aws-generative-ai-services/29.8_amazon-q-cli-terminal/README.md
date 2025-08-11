# Amazon Q CLI Terminal Demo

## Overview
This 5-minute demonstration showcases Amazon Q for command line interface, demonstrating how to use AI-powered assistance for AWS tasks, code generation, and infrastructure management directly from the terminal.

## Prerequisites
- AWS CLI configured with appropriate permissions
- Amazon Q CLI installed (`pip install amazon-q-cli` or download from AWS)
- Active AWS account with Amazon Q access

## Demo Steps (5 minutes)

### Step 1: Install and Configure Amazon Q CLI (1 minute)

1. **Install Amazon Q CLI:**
```bash
# Install via pip
pip install amazon-q-cli

# Or download and install from AWS
curl -o amazon-q-cli.pkg https://d2yblsmsllhwdu.cloudfront.net/amazon-q-cli/latest/amazon-q-cli.pkg
sudo installer -pkg amazon-q-cli.pkg -target /
```

2. **Configure Amazon Q:**
```bash
# Start Amazon Q CLI
q

# Follow the authentication prompts
# This will open a browser for AWS SSO authentication
```

### Step 2: Basic Amazon Q Interactions (1.5 minutes)

1. **Ask for AWS service help:**
```bash
# In the Q CLI session, try these commands:
q> How do I create an S3 bucket using AWS CLI?

q> What are the best practices for EC2 security groups?

q> Generate a CloudFormation template for a simple web application
```

2. **Code generation example:**
```bash
q> Write a Python script to list all EC2 instances in my account

q> Create a bash script to backup all S3 buckets
```

### Step 3: Infrastructure Analysis and Recommendations (1.5 minutes)

1. **Analyze current AWS resources:**
```bash
q> Analyze my current AWS infrastructure and suggest cost optimizations

q> What security improvements can I make to my current setup?

q> Help me understand my AWS bill and identify expensive resources
```

2. **Generate infrastructure code:**
```bash
q> Create a Terraform configuration for a three-tier web application

q> Generate a CDK stack for a serverless API with DynamoDB
```

### Step 4: Interactive Problem Solving (1 minute)

1. **Troubleshooting assistance:**
```bash
q> My Lambda function is timing out, how can I debug this?

q> I'm getting access denied errors when trying to access S3, what should I check?

q> How do I set up cross-region replication for my S3 bucket?
```

2. **Best practices guidance:**
```bash
q> What are the AWS Well-Architected Framework principles I should follow?

q> How do I implement least privilege access for my IAM users?
```

## Sample Interaction Flow

Here's what a typical 5-minute demo session might look like:

```bash
$ q
Welcome to Amazon Q CLI! 

q> I need to create a secure S3 bucket for storing sensitive documents. Can you help?

Amazon Q: I'll help you create a secure S3 bucket with appropriate security settings. Here's a step-by-step approach:

1. Create the bucket with encryption:
```bash
aws s3 mb s3://your-secure-documents-bucket-$(date +%s) --region us-east-1
```

2. Enable versioning:
```bash
aws s3api put-bucket-versioning \
    --bucket your-secure-documents-bucket-$(date +%s) \
    --versioning-configuration Status=Enabled
```

3. Block public access:
```bash
aws s3api put-public-access-block \
    --bucket your-secure-documents-bucket-$(date +%s) \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

Would you like me to explain any of these commands or help with additional security measures?

q> Yes, can you also show me how to set up server-side encryption?

Amazon Q: Absolutely! Here's how to enable server-side encryption with AWS KMS:

```bash
# Create a KMS key for encryption
aws kms create-key \
    --description "S3 bucket encryption key" \
    --key-usage ENCRYPT_DECRYPT

# Enable default encryption on the bucket
aws s3api put-bucket-encryption \
    --bucket your-secure-documents-bucket-$(date +%s) \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:kms",
                    "KMSMasterKeyID": "your-kms-key-id"
                },
                "BucketKeyEnabled": true
            }
        ]
    }'
```

This ensures all objects are encrypted at rest using your KMS key.

q> /quit
```

## Key Features Demonstrated

1. **Natural Language Queries**: Ask questions in plain English
2. **Code Generation**: Generate AWS CLI commands, scripts, and infrastructure code
3. **Best Practices**: Get recommendations following AWS best practices
4. **Troubleshooting**: Interactive problem-solving assistance
5. **Multi-service Knowledge**: Comprehensive understanding of AWS services
6. **Context Awareness**: Maintains conversation context for follow-up questions

## Advanced Usage Examples

### Infrastructure as Code Generation
```bash
q> Create a complete CDK stack for a serverless web application with:
- API Gateway
- Lambda functions
- DynamoDB table
- CloudFront distribution
- S3 bucket for static assets
```

### Cost Optimization
```bash
q> Analyze my EC2 instances and suggest right-sizing opportunities

q> What are the most cost-effective storage classes for my S3 usage patterns?
```

### Security Analysis
```bash
q> Review my IAM policies and identify overly permissive permissions

q> What security groups rules should I audit for potential risks?
```

## Expected Results
- Interactive AI assistance for AWS tasks
- Generated code and configurations following best practices
- Contextual help and troubleshooting guidance
- Improved productivity for AWS operations

## Troubleshooting
- Ensure AWS credentials are properly configured
- Check internet connectivity for AI model access
- Verify Amazon Q service availability in your region
- Update to the latest version if experiencing issues

## Citations and Documentation

1. **Amazon Q Developer User Guide**
   - https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/

2. **Amazon Q CLI Installation Guide**
   - https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-getting-started-installing.html

3. **Amazon Q for Command Line**
   - https://aws.amazon.com/q/developer/

4. **AWS CLI User Guide**
   - https://docs.aws.amazon.com/cli/latest/userguide/

5. **Amazon Q Developer Features**
   - https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/what-is.html
