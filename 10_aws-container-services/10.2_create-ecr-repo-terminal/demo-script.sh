#!/bin/bash

# ECR Repository Creation Demo Script
# This script demonstrates creating an ECR repository and pushing a Docker image

set -e

# Configuration
REPOSITORY_NAME="hello-world-demo"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "=== ECR Repository Creation Demo ==="
echo "Repository: $REPOSITORY_NAME"
echo "Region: $REGION"
echo "Account ID: $ACCOUNT_ID"
echo

# Step 1: Create ECR Repository
echo "Step 1: Creating ECR repository..."
aws ecr create-repository \
    --repository-name $REPOSITORY_NAME \
    --region $REGION

echo "Repository created successfully!"
echo

# Step 2: Authenticate Docker to ECR
echo "Step 2: Authenticating Docker to ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "Docker authenticated successfully!"
echo

# Step 3: Build Docker image
echo "Step 3: Building Docker image..."
docker build -t $REPOSITORY_NAME .

echo "Docker image built successfully!"
echo

# Step 4: Tag and push image
echo "Step 4: Tagging and pushing image to ECR..."
docker tag $REPOSITORY_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest

echo "Image pushed successfully!"
echo

# Step 5: Verify image in ECR
echo "Step 5: Verifying image in ECR..."
aws ecr list-images --repository-name $REPOSITORY_NAME --region $REGION

echo
echo "=== Demo completed successfully! ==="
echo "Your image is now available at: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest"
