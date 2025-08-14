#!/bin/bash

# Script to update the demo secret with new values

SECRET_NAME="demo/database/credentials"

echo "Updating secret: $SECRET_NAME"
echo "=============================="

# New secret value with updated password
NEW_SECRET_VALUE='{
  "username": "demo_user",
  "password": "UpdatedPassword456!",
  "database": "demo_database",
  "host": "demo-db.cluster-xyz.us-east-1.rds.amazonaws.com",
  "port": 5432
}'

echo "New secret value:"
echo "$NEW_SECRET_VALUE" | jq .

# Update the secret
aws secretsmanager update-secret --secret-id "$SECRET_NAME" --secret-string "$NEW_SECRET_VALUE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Secret updated successfully!"
    echo "💡 Check the AWS Console to see the new version"
else
    echo "❌ Failed to update secret. Please check:"
    echo "1. Secret exists in Secrets Manager"
    echo "2. You have secretsmanager:UpdateSecret permission"
    echo "3. JSON format is valid"
fi
