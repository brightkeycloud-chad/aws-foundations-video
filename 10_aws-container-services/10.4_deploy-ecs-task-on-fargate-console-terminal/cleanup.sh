#!/bin/bash

# ECS Fargate Cleanup Script
# This script cleans up resources created during the ECS Fargate demo

set -e

# Configuration
CLUSTER_NAME="fargate-demo-cluster"
TASK_DEFINITION_FAMILY="sample-fargate-demo"
SERVICE_NAME="fargate-demo-service"
REGION="us-west-2"

echo "=== ECS Fargate Cleanup ==="
echo "Cluster: $CLUSTER_NAME"
echo "Service: $SERVICE_NAME"
echo "Task Definition: $TASK_DEFINITION_FAMILY"
echo

# Step 1: Delete the service
echo "Step 1: Deleting ECS service..."
aws ecs delete-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --force \
    --region $REGION

echo "Service deletion initiated. Waiting for service to be deleted..."
aws ecs wait services-inactive \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION

echo "Service deleted successfully!"
echo

# Step 2: Delete the cluster
echo "Step 2: Deleting ECS cluster..."
aws ecs delete-cluster \
    --cluster $CLUSTER_NAME \
    --region $REGION

echo "Cluster deleted successfully!"
echo

# Step 3: Deregister task definition revisions
echo "Step 3: Deregistering task definition revisions..."
TASK_DEF_ARNS=$(aws ecs list-task-definitions \
    --family-prefix $TASK_DEFINITION_FAMILY \
    --region $REGION \
    --query 'taskDefinitionArns' \
    --output text)

if [ "$TASK_DEF_ARNS" != "" ]; then
    for arn in $TASK_DEF_ARNS; do
        echo "Deregistering task definition: $arn"
        aws ecs deregister-task-definition \
            --task-definition $arn \
            --region $REGION > /dev/null
    done
    echo "Task definitions deregistered successfully!"
else
    echo "No task definitions found to deregister."
fi

echo
echo "=== Cleanup completed successfully! ==="
echo "Note: Security groups and other VPC resources may need to be cleaned up manually if they were created specifically for this demo."
