#!/bin/bash

# AWS Resource Monitoring Script

# Function to get resource counts
get_resource_counts() {
    echo "=== AWS Resource Summary ==="
    echo "Timestamp: $(date)"
    echo
    
    # S3 Buckets
    BUCKET_COUNT=$(aws s3 ls | wc -l)
    echo "S3 Buckets: $BUCKET_COUNT"
    
    # EC2 Instances
    RUNNING_INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].InstanceId' \
        --output text | wc -w)
    echo "Running EC2 Instances: $RUNNING_INSTANCES"
    
    # IAM Users
    USER_COUNT=$(aws iam list-users --query 'Users[*].UserName' --output text | wc -w)
    echo "IAM Users: $USER_COUNT"
    
    echo "=========================="
}

get_resource_counts
