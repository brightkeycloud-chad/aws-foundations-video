#!/bin/bash

# Create Demo IAM Role Script
# This script creates the DemoAssumeRole used in the assume role demonstration
# and sets up Python environment for boto3

set -e  # Exit on any error

echo "🚀 Setting up Demo Environment..."

# Setup Python virtual environment
echo "🐍 Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "Virtual environment created"
else
    echo "Virtual environment already exists"
fi

# Activate virtual environment and install boto3
echo "📦 Installing boto3..."
source venv/bin/activate
pip install --quiet boto3
echo "boto3 installed successfully"

echo "🔧 Creating Demo IAM Role..."

# Get current account ID
echo "📋 Getting AWS account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account ID: $ACCOUNT_ID"

# Create trust policy
echo "📝 Creating trust policy..."
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::$ACCOUNT_ID:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF

# Create the IAM role
echo "🔧 Creating IAM role: DemoAssumeRole..."
aws iam create-role \
  --role-name DemoAssumeRole \
  --assume-role-policy-document file://trust-policy.json \
  --description "Demo role for assume role demonstration"

# Attach S3 read-only policy
echo "🔗 Attaching S3ReadOnlyAccess policy..."
aws iam attach-role-policy \
  --role-name DemoAssumeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Clean up temporary file
rm trust-policy.json

echo "✅ Demo environment setup completed!"
echo "Role ARN: arn:aws:iam::$ACCOUNT_ID:role/DemoAssumeRole"
echo ""
echo "To use the Python script, activate the virtual environment:"
echo "source venv/bin/activate"
echo ""
echo "You can now assume this role using:"
echo "./assume-role.sh arn:aws:iam::$ACCOUNT_ID:role/DemoAssumeRole"
echo "python3 assume_role.py arn:aws:iam::$ACCOUNT_ID:role/DemoAssumeRole"