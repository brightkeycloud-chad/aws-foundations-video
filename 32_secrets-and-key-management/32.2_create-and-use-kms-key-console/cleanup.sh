#!/bin/bash

# Cleanup script for KMS Key Console Demonstration
# This script schedules the demo KMS key for deletion

echo "Starting cleanup for KMS Key Console Demonstration..."

# Set the key alias
KEY_ALIAS="demo-encryption-key"

# Get the key ID from the alias
echo "Looking up key ID for alias: $KEY_ALIAS"
KEY_ID=$(aws kms describe-key --key-id "alias/$KEY_ALIAS" --query 'KeyMetadata.KeyId' --output text 2>/dev/null)

if [ $? -ne 0 ] || [ "$KEY_ID" == "None" ] || [ -z "$KEY_ID" ]; then
    echo "Key with alias '$KEY_ALIAS' not found or already deleted."
    echo "Cleanup complete - no action needed."
    exit 0
fi

echo "Found key ID: $KEY_ID"

# Schedule key deletion (minimum 7 days waiting period)
echo "Scheduling key deletion with 7-day waiting period..."
aws kms schedule-key-deletion --key-id "$KEY_ID" --pending-window-in-days 7

if [ $? -eq 0 ]; then
    echo "✅ Successfully scheduled key '$KEY_ALIAS' for deletion."
    echo "The key will be deleted after the 7-day waiting period."
    echo "You can cancel the deletion during this period if needed."
else
    echo "❌ Failed to schedule key deletion."
    echo "Please manually delete the key through the AWS Console:"
    echo "1. Go to KMS > Customer managed keys"
    echo "2. Select the key: $KEY_ALIAS"
    echo "3. Click 'Key actions' > 'Schedule key deletion'"
fi

echo "Cleanup script completed."
