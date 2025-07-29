#!/bin/bash

# ECS Fargate Deployment Demo Script (CLI portion)
# This script demonstrates CLI operations for ECS Fargate deployment

set -e

# Configuration
CLUSTER_NAME="fargate-demo-cluster"
TASK_DEFINITION_FAMILY="sample-fargate-demo"
SERVICE_NAME="fargate-demo-service"
REGION="us-west-2"

echo "=== ECS Fargate CLI Demo ==="
echo "Cluster: $CLUSTER_NAME"
echo "Task Definition: $TASK_DEFINITION_FAMILY"
echo "Service: $SERVICE_NAME"
echo "Region: $REGION"
echo

# Function to wait for service to be stable
wait_for_service() {
    echo "Waiting for service to become stable..."
    aws ecs wait services-stable \
        --cluster $CLUSTER_NAME \
        --services $SERVICE_NAME \
        --region $REGION
    echo "Service is now stable!"
}

# Step 1: List running tasks
echo "Step 1: Listing running tasks..."
TASKS=$(aws ecs list-tasks \
    --cluster $CLUSTER_NAME \
    --region $REGION \
    --query 'taskArns[0]' \
    --output text)

if [ "$TASKS" != "None" ] && [ "$TASKS" != "" ]; then
    echo "Found running task: $TASKS"
    echo
    
    # Step 2: Get task details
    echo "Step 2: Getting task details..."
    aws ecs describe-tasks \
        --cluster $CLUSTER_NAME \
        --tasks $TASKS \
        --region $REGION \
        --query 'tasks[0].{TaskArn:taskArn,LastStatus:lastStatus,DesiredStatus:desiredStatus,PublicIp:attachments[0].details[?name==`networkInterfaceId`].value | [0]}' \
        --output table
    
    # Get the public IP
    PUBLIC_IP=$(aws ecs describe-tasks \
        --cluster $CLUSTER_NAME \
        --tasks $TASKS \
        --region $REGION \
        --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value | [0]' \
        --output text)
    
    if [ "$PUBLIC_IP" != "None" ] && [ "$PUBLIC_IP" != "" ]; then
        # Get the actual public IP from the ENI
        ACTUAL_PUBLIC_IP=$(aws ec2 describe-network-interfaces \
            --network-interface-ids $PUBLIC_IP \
            --region $REGION \
            --query 'NetworkInterfaces[0].Association.PublicIp' \
            --output text)
        
        echo
        echo "Public IP Address: $ACTUAL_PUBLIC_IP"
        echo "Application URL: http://$ACTUAL_PUBLIC_IP"
    fi
else
    echo "No running tasks found. Make sure to create the service first using the console."
fi

echo

# Step 3: Check service status
echo "Step 3: Checking service status..."
aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION \
    --query 'services[0].{ServiceName:serviceName,Status:status,RunningCount:runningCount,PendingCount:pendingCount,DesiredCount:desiredCount}' \
    --output table

echo

# Step 4: Show recent service events
echo "Step 4: Recent service events..."
aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION \
    --query 'services[0].events[:5].{Time:createdAt,Message:message}' \
    --output table

echo
echo "=== CLI Demo completed! ==="
echo "Use the console to view the full application details and access the web interface."
