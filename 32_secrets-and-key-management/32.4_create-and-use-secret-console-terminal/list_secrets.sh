#!/bin/bash

# Script to list all secrets in AWS Secrets Manager

echo "Listing all secrets in AWS Secrets Manager"
echo "=========================================="

# List secrets with key information
aws secretsmanager list-secrets --query 'SecretList[*].{Name:Name,Description:Description,LastChanged:LastChangedDate}' --output table

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Secrets listed successfully!"
    echo "💡 Use describe-secret for more details about specific secrets"
else
    echo "❌ Failed to list secrets. Please check:"
    echo "1. AWS CLI is configured correctly"
    echo "2. You have secretsmanager:ListSecrets permission"
fi
