#!/bin/bash

# AWS CloudTrail Demo Cleanup Script
# This script removes all resources created during the CloudTrail demonstration

set -e

echo "Starting CloudTrail demo cleanup..."

# Get AWS account ID for bucket name pattern
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "unknown")

# Trail name used in demo
TRAIL_NAME="demo-cloudtrail-trail"

# Expected S3 bucket pattern
BUCKET_PREFIX="cloudtrail-logs-demo-${ACCOUNT_ID}"

echo "Cleaning up CloudTrail trail: $TRAIL_NAME"

# Stop logging and delete the trail
if aws cloudtrail describe-trails --trail-name-list "$TRAIL_NAME" --query 'trailList[0].Name' --output text 2>/dev/null | grep -q "$TRAIL_NAME"; then
    echo "Stopping logging for trail: $TRAIL_NAME"
    aws cloudtrail stop-logging --name "$TRAIL_NAME" || echo "Warning: Could not stop logging (trail may not exist)"
    
    echo "Deleting CloudTrail trail: $TRAIL_NAME"
    aws cloudtrail delete-trail --name "$TRAIL_NAME" || echo "Warning: Could not delete trail"
else
    echo "Trail $TRAIL_NAME not found, skipping trail deletion"
fi

# Find and clean up S3 bucket
echo "Looking for S3 buckets with prefix: $BUCKET_PREFIX"
BUCKETS=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '$BUCKET_PREFIX')].Name" --output text 2>/dev/null || echo "")

if [ -n "$BUCKETS" ]; then
    for BUCKET in $BUCKETS; do
        echo "Found CloudTrail S3 bucket: $BUCKET"
        
        # Remove all objects from bucket (including versions if versioning is enabled)
        echo "Emptying S3 bucket: $BUCKET"
        aws s3 rm "s3://$BUCKET" --recursive || echo "Warning: Could not empty bucket $BUCKET"
        
        # Remove any object versions if versioning is enabled
        aws s3api list-object-versions --bucket "$BUCKET" --query 'Versions[].{Key:Key,VersionId:VersionId}' --output text 2>/dev/null | while read key version; do
            if [ -n "$key" ] && [ -n "$version" ]; then
                aws s3api delete-object --bucket "$BUCKET" --key "$key" --version-id "$version" || echo "Warning: Could not delete version $version of $key"
            fi
        done
        
        # Remove any delete markers
        aws s3api list-object-versions --bucket "$BUCKET" --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output text 2>/dev/null | while read key version; do
            if [ -n "$key" ] && [ -n "$version" ]; then
                aws s3api delete-object --bucket "$BUCKET" --key "$key" --version-id "$version" || echo "Warning: Could not delete marker $version of $key"
            fi
        done
        
        # Delete the bucket
        echo "Deleting S3 bucket: $BUCKET"
        aws s3api delete-bucket --bucket "$BUCKET" || echo "Warning: Could not delete bucket $BUCKET"
    done
else
    echo "No CloudTrail S3 buckets found with prefix $BUCKET_PREFIX"
fi

# Clean up CloudWatch Log Group if it exists
LOG_GROUP_NAME="CloudTrail/demo-trail"
echo "Checking for CloudWatch Log Group: $LOG_GROUP_NAME"

if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP_NAME" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "$LOG_GROUP_NAME"; then
    echo "Deleting CloudWatch Log Group: $LOG_GROUP_NAME"
    aws logs delete-log-group --log-group-name "$LOG_GROUP_NAME" || echo "Warning: Could not delete log group"
else
    echo "CloudWatch Log Group $LOG_GROUP_NAME not found"
fi

# Clean up IAM role if it was created (CloudTrail creates roles with specific naming pattern)
echo "Looking for CloudTrail IAM roles..."
CLOUDTRAIL_ROLES=$(aws iam list-roles --query "Roles[?starts_with(RoleName, 'CloudTrail_CloudWatchLogsRole')].RoleName" --output text 2>/dev/null || echo "")

if [ -n "$CLOUDTRAIL_ROLES" ]; then
    for ROLE in $CLOUDTRAIL_ROLES; do
        echo "Found CloudTrail IAM role: $ROLE"
        
        # Detach policies
        ATTACHED_POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLE" --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null || echo "")
        for POLICY in $ATTACHED_POLICIES; do
            echo "Detaching policy $POLICY from role $ROLE"
            aws iam detach-role-policy --role-name "$ROLE" --policy-arn "$POLICY" || echo "Warning: Could not detach policy"
        done
        
        # Delete inline policies
        INLINE_POLICIES=$(aws iam list-role-policies --role-name "$ROLE" --query 'PolicyNames' --output text 2>/dev/null || echo "")
        for POLICY in $INLINE_POLICIES; do
            echo "Deleting inline policy $POLICY from role $ROLE"
            aws iam delete-role-policy --role-name "$ROLE" --policy-name "$POLICY" || echo "Warning: Could not delete inline policy"
        done
        
        # Delete the role
        echo "Deleting IAM role: $ROLE"
        aws iam delete-role --role-name "$ROLE" || echo "Warning: Could not delete role"
    done
else
    echo "No CloudTrail IAM roles found"
fi

echo "CloudTrail demo cleanup completed!"
echo "Note: It may take a few minutes for all resources to be fully removed from AWS."
echo "Please verify in the AWS Console that all resources have been cleaned up."
