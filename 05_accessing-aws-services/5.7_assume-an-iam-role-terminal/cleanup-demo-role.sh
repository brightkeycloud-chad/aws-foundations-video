#!/bin/bash

# Cleanup Demo IAM Role Script
# This script removes the DemoAssumeRole created for the demonstration

set -e  # Exit on any error

echo "🧹 Cleaning up Demo IAM Role..."

# Detach policy from role
echo "🔗 Detaching S3ReadOnlyAccess policy..."
aws iam detach-role-policy \
  --role-name DemoAssumeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Delete the IAM role
echo "🗑️  Deleting IAM role: DemoAssumeRole..."
aws iam delete-role --role-name DemoAssumeRole

# Clean up Python virtual environment
if [ -d "venv" ]; then
    echo "🐍 Removing Python virtual environment..."
    rm -rf venv
    echo "Virtual environment removed"
fi

echo "✅ Demo cleanup completed!"
echo "The DemoAssumeRole and virtual environment have been removed."