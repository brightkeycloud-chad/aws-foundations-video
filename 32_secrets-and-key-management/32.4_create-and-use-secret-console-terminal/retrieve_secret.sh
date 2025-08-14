#!/bin/bash

# Script to retrieve the demo secret from AWS Secrets Manager

SECRET_NAME="demo/database/credentials"

echo "Retrieving secret: $SECRET_NAME"
echo "=================================="

# Retrieve the secret value
aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text | jq .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Secret retrieved successfully!"
else
    echo "❌ Failed to retrieve secret. Please check:"
    echo "1. AWS CLI is configured correctly"
    echo "2. Secret exists in Secrets Manager"
    echo "3. You have appropriate IAM permissions"
fi
