#!/bin/bash

# Script to describe the demo secret metadata

SECRET_NAME="demo/database/credentials"

echo "Describing secret: $SECRET_NAME"
echo "==============================="

# Describe the secret (metadata only, no secret values)
aws secretsmanager describe-secret --secret-id "$SECRET_NAME" --output json | jq '{
  Name: .Name,
  Description: .Description,
  KmsKeyId: .KmsKeyId,
  RotationEnabled: .RotationEnabled,
  LastChangedDate: .LastChangedDate,
  LastAccessedDate: .LastAccessedDate,
  Tags: .Tags,
  VersionIdsToStages: .VersionIdsToStages
}'

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Secret described successfully!"
    echo "💡 This shows metadata only - use get-secret-value for actual secret content"
else
    echo "❌ Failed to describe secret. Please check:"
    echo "1. Secret exists in Secrets Manager"
    echo "2. You have secretsmanager:DescribeSecret permission"
    echo "3. jq is installed for JSON formatting"
fi
