#!/bin/bash

# Cleanup script for Secrets Manager Console Terminal Demonstration
# This script deletes the demo secret

echo "Starting cleanup for Secrets Manager Console Terminal Demonstration..."

SECRET_NAME="demo/database/credentials"

# Check if secret exists
echo "Checking if secret exists: $SECRET_NAME"
aws secretsmanager describe-secret --secret-id "$SECRET_NAME" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Secret '$SECRET_NAME' not found or already deleted."
    echo "Cleanup complete - no action needed."
    exit 0
fi

echo "Found secret: $SECRET_NAME"

# Delete the secret immediately (force delete without recovery window)
echo "Deleting secret immediately..."
aws secretsmanager delete-secret --secret-id "$SECRET_NAME" --force-delete-without-recovery

if [ $? -eq 0 ]; then
    echo "✅ Successfully deleted secret '$SECRET_NAME'."
    echo "The secret has been permanently removed."
else
    echo "❌ Failed to delete secret."
    echo "Please manually delete the secret through the AWS Console:"
    echo "1. Go to AWS Secrets Manager"
    echo "2. Select the secret: $SECRET_NAME"
    echo "3. Click 'Actions' > 'Delete secret'"
    echo "4. Choose immediate deletion or set recovery window"
fi

echo "Cleanup script completed."
