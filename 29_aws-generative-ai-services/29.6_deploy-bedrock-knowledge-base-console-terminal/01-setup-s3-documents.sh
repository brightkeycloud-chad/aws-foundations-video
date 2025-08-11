#!/bin/bash

# Script 1: Create S3 Bucket and Upload Sample Documents
echo "Setting up S3 bucket and sample documents for Knowledge Base..."

# Create unique bucket name with timestamp
BUCKET_NAME="bedrock-kb-docs-$(date +%s)"
echo "Creating S3 bucket: $BUCKET_NAME"

aws s3 mb s3://$BUCKET_NAME --region us-east-1

if [ $? -eq 0 ]; then
    echo "✅ Created bucket: $BUCKET_NAME"
else
    echo "❌ Failed to create S3 bucket"
    exit 1
fi

# Create sample document 1
echo "Creating sample documents..."
cat > aws-services-overview.txt << EOF
Amazon Web Services (AWS) Overview

AWS is a comprehensive cloud computing platform that offers over 200 services including:

Compute Services:
- Amazon EC2: Virtual servers in the cloud
- AWS Lambda: Serverless compute service
- Amazon ECS: Container orchestration service

Storage Services:
- Amazon S3: Object storage service
- Amazon EBS: Block storage for EC2
- Amazon EFS: Managed file system

Database Services:
- Amazon RDS: Managed relational database
- Amazon DynamoDB: NoSQL database service
- Amazon Redshift: Data warehouse service

AI/ML Services:
- Amazon Bedrock: Generative AI service
- Amazon SageMaker: Machine learning platform
- Amazon Rekognition: Image and video analysis

Networking Services:
- Amazon VPC: Virtual private cloud
- Amazon CloudFront: Content delivery network
- AWS Direct Connect: Dedicated network connection

Security Services:
- AWS IAM: Identity and access management
- AWS KMS: Key management service
- AWS CloudTrail: API logging and monitoring
EOF

echo "✅ Created aws-services-overview.txt"

# Create sample document 2
cat > bedrock-features.txt << EOF
Amazon Bedrock Features and Capabilities

Amazon Bedrock is a fully managed service that offers foundation models (FMs) from leading AI companies through a single API.

Key Features:
- Foundation Models: Access to models from Anthropic, AI21 Labs, Cohere, Meta, and Amazon
- Model Customization: Fine-tune models with your own data
- Agents: Build conversational AI applications
- Knowledge Bases: Implement Retrieval Augmented Generation (RAG)
- Guardrails: Implement responsible AI practices

Foundation Models Available:
- Claude 3 (Anthropic): Advanced reasoning and analysis
- Jurassic-2 (AI21 Labs): Text generation and comprehension
- Command (Cohere): Text generation and embeddings
- Llama 2 (Meta): Open-source language model
- Titan (Amazon): Text generation and embeddings

Use Cases:
- Content generation and summarization
- Conversational AI and chatbots
- Code generation and analysis
- Document processing and analysis
- Creative writing and ideation
- Customer service automation
- Research and data analysis

Security and Compliance:
- Data encryption in transit and at rest
- VPC support for network isolation
- IAM integration for access control
- Compliance with SOC, PCI, and other standards
- Data residency controls
- Audit logging with CloudTrail

Pricing Model:
- Pay-per-use for inference
- No upfront costs or minimum fees
- Separate pricing for model customization
- Volume discounts available
EOF

echo "✅ Created bedrock-features.txt"

# Create sample document 3
cat > aws-best-practices.txt << EOF
AWS Best Practices and Well-Architected Framework

The AWS Well-Architected Framework provides guidance for building secure, high-performing, resilient, and efficient infrastructure for applications.

Five Pillars of Well-Architected Framework:

1. Operational Excellence
- Automate operations processes
- Make frequent, small, reversible changes
- Refine operations procedures frequently
- Anticipate failure and learn from operational events

2. Security
- Implement strong identity foundation
- Apply security at all layers
- Enable traceability
- Automate security best practices
- Protect data in transit and at rest

3. Reliability
- Automatically recover from failure
- Test recovery procedures
- Scale horizontally to increase availability
- Stop guessing capacity requirements

4. Performance Efficiency
- Democratize advanced technologies
- Go global in minutes
- Use serverless architectures
- Experiment more often
- Consider mechanical sympathy

5. Cost Optimization
- Implement cloud financial management
- Adopt consumption models
- Measure overall efficiency
- Stop spending on undifferentiated heavy lifting
- Analyze and attribute expenditure

General Best Practices:
- Use Infrastructure as Code (CloudFormation, CDK)
- Implement proper monitoring and logging
- Design for failure and build resilient systems
- Use managed services when possible
- Implement proper backup and disaster recovery
- Follow the principle of least privilege
- Use multiple Availability Zones
- Implement proper tagging strategies
EOF

echo "✅ Created aws-best-practices.txt"

# Upload documents to S3
echo "Uploading documents to S3..."
aws s3 cp aws-services-overview.txt s3://$BUCKET_NAME/
if [ $? -eq 0 ]; then
    echo "✅ Uploaded aws-services-overview.txt"
else
    echo "❌ Failed to upload aws-services-overview.txt"
fi

aws s3 cp bedrock-features.txt s3://$BUCKET_NAME/
if [ $? -eq 0 ]; then
    echo "✅ Uploaded bedrock-features.txt"
else
    echo "❌ Failed to upload bedrock-features.txt"
fi

aws s3 cp aws-best-practices.txt s3://$BUCKET_NAME/
if [ $? -eq 0 ]; then
    echo "✅ Uploaded aws-best-practices.txt"
else
    echo "❌ Failed to upload aws-best-practices.txt"
fi

# Save bucket name for other scripts
echo $BUCKET_NAME > .bucket-name

echo ""
echo "🎉 S3 setup completed successfully!"
echo "📝 Bucket name: $BUCKET_NAME"
echo "📄 Uploaded 3 sample documents"
echo "💾 Bucket name saved to .bucket-name file"
