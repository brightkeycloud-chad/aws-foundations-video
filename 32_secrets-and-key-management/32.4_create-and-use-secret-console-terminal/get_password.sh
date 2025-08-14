#!/bin/bash

# Script to extract just the password from the demo secret

SECRET_NAME="demo/database/credentials"

echo "Extracting password from secret: $SECRET_NAME"
echo "============================================="

# Get just the password field
PASSWORD=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text | jq -r '.password')

if [ $? -eq 0 ] && [ "$PASSWORD" != "null" ]; then
    echo "Password: $PASSWORD"
    echo ""
    echo "✅ Password extracted successfully!"
    echo "💡 In production, avoid echoing passwords to console"
else
    echo "❌ Failed to extract password. Please check:"
    echo "1. Secret exists and contains 'password' field"
    echo "2. jq is installed for JSON parsing"
    echo "3. AWS CLI permissions are correct"
fi
