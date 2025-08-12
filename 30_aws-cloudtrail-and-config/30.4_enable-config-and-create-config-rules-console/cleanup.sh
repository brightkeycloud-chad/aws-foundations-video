#!/bin/bash

# AWS Config Demo Cleanup Script
# This script removes all resources created during the AWS Config demonstration

set -e

echo "Starting AWS Config demo cleanup..."

# Get current region and account ID
REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "unknown")

echo "Cleaning up AWS Config resources in region: $REGION"

# Config rules created in demo
CONFIG_RULES=("s3-bucket-public-access-prohibited" "ec2-security-group-attached-to-eni")

# Delete Config Rules
echo "Deleting Config Rules..."
for RULE in "${CONFIG_RULES[@]}"; do
    if aws configservice describe-config-rules --config-rule-names "$RULE" --query 'ConfigRules[0].ConfigRuleName' --output text 2>/dev/null | grep -q "$RULE"; then
        echo "Deleting Config Rule: $RULE"
        aws configservice delete-config-rule --config-rule-name "$RULE" || echo "Warning: Could not delete Config Rule $RULE"
    else
        echo "Config Rule $RULE not found, skipping"
    fi
done

# Stop Config Recorder
echo "Stopping Config Recorder..."
RECORDER_NAME=$(aws configservice describe-configuration-recorders --query 'ConfigurationRecorders[0].name' --output text 2>/dev/null || echo "None")

if [ "$RECORDER_NAME" != "None" ] && [ "$RECORDER_NAME" != "" ]; then
    echo "Found Config Recorder: $RECORDER_NAME"
    
    # Stop the recorder
    aws configservice stop-configuration-recorder --configuration-recorder-name "$RECORDER_NAME" || echo "Warning: Could not stop Config Recorder"
    
    # Delete the recorder
    echo "Deleting Config Recorder: $RECORDER_NAME"
    aws configservice delete-configuration-recorder --configuration-recorder-name "$RECORDER_NAME" || echo "Warning: Could not delete Config Recorder"
else
    echo "No Config Recorder found"
fi

# Delete Delivery Channel
echo "Deleting Config Delivery Channel..."
DELIVERY_CHANNEL=$(aws configservice describe-delivery-channels --query 'DeliveryChannels[0].name' --output text 2>/dev/null || echo "None")

if [ "$DELIVERY_CHANNEL" != "None" ] && [ "$DELIVERY_CHANNEL" != "" ]; then
    echo "Found Delivery Channel: $DELIVERY_CHANNEL"
    aws configservice delete-delivery-channel --delivery-channel-name "$DELIVERY_CHANNEL" || echo "Warning: Could not delete Delivery Channel"
else
    echo "No Delivery Channel found"
fi

# Clean up S3 bucket
echo "Looking for Config S3 bucket..."
CONFIG_BUCKET_PREFIX="config-bucket-${ACCOUNT_ID}"

BUCKETS=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '$CONFIG_BUCKET_PREFIX')].Name" --output text 2>/dev/null || echo "")

if [ -n "$BUCKETS" ]; then
    for BUCKET in $BUCKETS; do
        echo "Found Config S3 bucket: $BUCKET"
        
        # Remove bucket policy if it exists
        echo "Removing bucket policy from: $BUCKET"
        aws s3api delete-bucket-policy --bucket "$BUCKET" 2>/dev/null || echo "No bucket policy to remove"
        
        # Remove all objects from bucket (including versions if versioning is enabled)
        echo "Emptying S3 bucket: $BUCKET"
        aws s3 rm "s3://$BUCKET" --recursive || echo "Warning: Could not empty bucket $BUCKET"
        
        # Remove any object versions if versioning is enabled
        aws s3api list-object-versions --bucket "$BUCKET" --query 'Versions[].{Key:Key,VersionId:VersionId}' --output text 2>/dev/null | while read key version; do
            if [ -n "$key" ] && [ -n "$version" ] && [ "$key" != "None" ]; then
                aws s3api delete-object --bucket "$BUCKET" --key "$key" --version-id "$version" || echo "Warning: Could not delete version $version of $key"
            fi
        done
        
        # Remove any delete markers
        aws s3api list-object-versions --bucket "$BUCKET" --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output text 2>/dev/null | while read key version; do
            if [ -n "$key" ] && [ -n "$version" ] && [ "$key" != "None" ]; then
                aws s3api delete-object --bucket "$BUCKET" --key "$key" --version-id "$version" || echo "Warning: Could not delete marker $version of $key"
            fi
        done
        
        # Delete the bucket
        echo "Deleting S3 bucket: $BUCKET"
        aws s3api delete-bucket --bucket "$BUCKET" || echo "Warning: Could not delete bucket $BUCKET"
    done
else
    echo "No Config S3 buckets found with prefix $CONFIG_BUCKET_PREFIX"
fi

# Clean up SNS topic
echo "Looking for Config SNS topic..."
TOPIC_NAME="config-topic"

TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, '$TOPIC_NAME')].TopicArn" --output text 2>/dev/null || echo "")

if [ -n "$TOPIC_ARN" ] && [ "$TOPIC_ARN" != "None" ]; then
    echo "Found Config SNS topic: $TOPIC_ARN"
    aws sns delete-topic --topic-arn "$TOPIC_ARN" || echo "Warning: Could not delete SNS topic"
else
    echo "No Config SNS topic found with name $TOPIC_NAME"
fi

# Note: AWS Config service-linked role is managed by AWS and doesn't need manual cleanup
echo "Note: AWS Config service-linked role is managed by AWS and will be cleaned up automatically"

# Clean up any remaining Config aggregators (if any were created)
echo "Checking for Config Aggregators..."
AGGREGATORS=$(aws configservice describe-configuration-aggregators --query 'ConfigurationAggregators[].ConfigurationAggregatorName' --output text 2>/dev/null || echo "")

if [ -n "$AGGREGATORS" ] && [ "$AGGREGATORS" != "None" ]; then
    for AGGREGATOR in $AGGREGATORS; do
        echo "Found Config Aggregator: $AGGREGATOR"
        aws configservice delete-configuration-aggregator --configuration-aggregator-name "$AGGREGATOR" || echo "Warning: Could not delete Config Aggregator"
    done
else
    echo "No Config Aggregators found"
fi

# Wait a moment for resources to be deleted
echo "Waiting 10 seconds for resources to be fully deleted..."
sleep 10

echo "AWS Config demo cleanup completed!"
echo "Note: It may take a few minutes for all resources to be fully removed from AWS."
echo "The AWS Config service-linked role will be automatically managed by AWS."
echo "Please verify in the AWS Console that all resources have been cleaned up."
