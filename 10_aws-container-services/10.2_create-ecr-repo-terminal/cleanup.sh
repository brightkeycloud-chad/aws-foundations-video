#!/bin/bash

# ECR Repository Cleanup Script
# This script cleans up resources created during the ECR demo

set -e

# Configuration
REPOSITORY_NAME="hello-world-demo"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "=== ECR Repository Cleanup ==="
echo "Repository: $REPOSITORY_NAME"
echo "Region: $REGION"
echo

# Step 1: Delete ECR repository and all images
echo "Step 1: Deleting ECR repository and all images..."
aws ecr delete-repository \
    --repository-name $REPOSITORY_NAME \
    --region $REGION \
    --force

echo "ECR repository deleted successfully!"
echo

# Step 2: Remove local Docker images
echo "Step 2: Removing local Docker images..."
docker rmi $REPOSITORY_NAME:latest 2>/dev/null || echo "Local image $REPOSITORY_NAME:latest not found"
docker rmi $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest 2>/dev/null || echo "Tagged image not found locally"

echo "Local images cleaned up!"
echo

# Step 3: Clean up any dangling images
echo "Step 3: Cleaning up dangling images..."
docker image prune -f

echo
echo "=== Cleanup completed successfully! ==="
