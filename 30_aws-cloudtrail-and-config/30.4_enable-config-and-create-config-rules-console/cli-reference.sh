#!/bin/bash

# AWS Config CLI Reference Script
# This script shows the CLI equivalent commands for the console demonstration
# NOTE: This is for reference only - the demo uses the console interface

echo "=== AWS Config CLI Reference Commands ==="
echo "These commands show the CLI equivalent of the console demonstration steps"
echo "DO NOT RUN - This is for educational reference only"
echo

# Get account ID and region for examples
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "123456789012")
REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")

echo "# Step 1: Create S3 bucket for Config"
echo "aws s3api create-bucket --bucket config-bucket-${ACCOUNT_ID}-${REGION} --region $REGION"
echo

echo "# Step 2: Create bucket policy for Config"
echo "cat > config-bucket-policy.json << EOF"
cat << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSConfigBucketPermissionsCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::config-bucket-ACCOUNT_ID-REGION"
        },
        {
            "Sid": "AWSConfigBucketExistenceCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::config-bucket-ACCOUNT_ID-REGION"
        },
        {
            "Sid": "AWSConfigBucketDelivery",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::config-bucket-ACCOUNT_ID-REGION/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
EOF
echo "aws s3api put-bucket-policy --bucket config-bucket-${ACCOUNT_ID}-${REGION} --policy file://config-bucket-policy.json"
echo

echo "# Step 3: Create SNS topic for Config notifications (optional)"
echo "aws sns create-topic --name config-topic"
echo "TOPIC_ARN=\$(aws sns list-topics --query \"Topics[?contains(TopicArn, 'config-topic')].TopicArn\" --output text)"
echo

echo "# Step 4: Create Config service-linked role (automatic in console)"
echo "# Note: Service-linked roles are created automatically by AWS Config"
echo "# aws iam create-service-linked-role --aws-service-name config.amazonaws.com"
echo

echo "# Step 5: Create Configuration Recorder"
echo "cat > config-recorder.json << EOF"
cat << 'EOF'
{
    "name": "default",
    "roleARN": "arn:aws:iam::ACCOUNT_ID:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig",
    "recordingGroup": {
        "allSupported": true,
        "includeGlobalResourceTypes": true,
        "recordingModeOverrides": []
    }
}
EOF
echo "aws configservice put-configuration-recorder --configuration-recorder file://config-recorder.json"
echo

echo "# Step 6: Create Delivery Channel"
echo "cat > delivery-channel.json << EOF"
cat << 'EOF'
{
    "name": "default",
    "s3BucketName": "config-bucket-ACCOUNT_ID-REGION",
    "snsTopicARN": "arn:aws:sns:REGION:ACCOUNT_ID:config-topic"
}
EOF
echo "aws configservice put-delivery-channel --delivery-channel file://delivery-channel.json"
echo

echo "# Step 7: Start Configuration Recorder"
echo "aws configservice start-configuration-recorder --configuration-recorder-name default"
echo

echo "# Step 8: Create Config Rules"
echo "# Rule 1: S3 bucket public access prohibited"
echo "cat > s3-public-access-rule.json << EOF"
cat << 'EOF'
{
    "ConfigRuleName": "s3-bucket-public-access-prohibited",
    "Source": {
        "Owner": "AWS",
        "SourceIdentifier": "S3_BUCKET_PUBLIC_ACCESS_PROHIBITED"
    }
}
EOF
echo "aws configservice put-config-rule --config-rule file://s3-public-access-rule.json"
echo

echo "# Rule 2: EC2 security group attached to ENI"
echo "cat > ec2-sg-attached-rule.json << EOF"
cat << 'EOF'
{
    "ConfigRuleName": "ec2-security-group-attached-to-eni",
    "Source": {
        "Owner": "AWS",
        "SourceIdentifier": "EC2_SECURITY_GROUP_ATTACHED_TO_ENI"
    }
}
EOF
echo "aws configservice put-config-rule --config-rule file://ec2-sg-attached-rule.json"
echo

echo "# Verification commands:"
echo "# Check recorder status"
echo "aws configservice describe-configuration-recorder-status"
echo
echo "# List Config rules"
echo "aws configservice describe-config-rules"
echo
echo "# Get compliance summary"
echo "aws configservice get-compliance-summary-by-config-rule"
echo
echo "# List discovered resources"
echo "aws configservice get-discovered-resource-counts"
echo
echo "# Get compliance details for a specific rule"
echo "aws configservice get-compliance-details-by-config-rule --config-rule-name s3-bucket-public-access-prohibited"
echo

echo "=== End of CLI Reference ==="
echo "Remember: The actual demonstration uses the AWS Console interface"
echo "These CLI commands are provided for educational comparison only"
