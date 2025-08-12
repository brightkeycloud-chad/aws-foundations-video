#!/bin/bash

# CloudTrail CLI Reference Script
# This script shows the CLI equivalent commands for the console demonstration
# NOTE: This is for reference only - the demo uses the console interface

echo "=== CloudTrail CLI Reference Commands ==="
echo "These commands show the CLI equivalent of the console demonstration steps"
echo "DO NOT RUN - This is for educational reference only"
echo

# Get account ID and region for examples
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "123456789012")
REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")
TIMESTAMP=$(date +%s)

echo "# Step 1: Create S3 bucket for CloudTrail logs"
echo "aws s3api create-bucket --bucket cloudtrail-logs-demo-${ACCOUNT_ID}-${TIMESTAMP} --region $REGION"
echo

echo "# Step 2: Create bucket policy for CloudTrail"
echo "cat > cloudtrail-bucket-policy.json << EOF"
cat << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::cloudtrail-logs-demo-ACCOUNT_ID-TIMESTAMP"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::cloudtrail-logs-demo-ACCOUNT_ID-TIMESTAMP/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
EOF
echo "aws s3api put-bucket-policy --bucket cloudtrail-logs-demo-${ACCOUNT_ID}-${TIMESTAMP} --policy file://cloudtrail-bucket-policy.json"
echo

echo "# Step 3: Create CloudWatch Log Group (optional)"
echo "aws logs create-log-group --log-group-name CloudTrail/demo-trail"
echo

echo "# Step 4: Create IAM role for CloudWatch Logs (optional)"
echo "cat > cloudtrail-logs-role-trust-policy.json << EOF"
cat << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
echo "aws iam create-role --role-name CloudTrail_CloudWatchLogsRole --assume-role-policy-document file://cloudtrail-logs-role-trust-policy.json"
echo

echo "# Step 5: Attach policy to IAM role"
echo "cat > cloudtrail-logs-role-policy.json << EOF"
cat << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogGroup",
                "logs:CreateLogStream"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
echo "aws iam put-role-policy --role-name CloudTrail_CloudWatchLogsRole --policy-name CloudTrail_CloudWatchLogsRolePolicy --policy-document file://cloudtrail-logs-role-policy.json"
echo

echo "# Step 6: Create the CloudTrail trail"
echo "aws cloudtrail create-trail \\"
echo "    --name demo-cloudtrail-trail \\"
echo "    --s3-bucket-name cloudtrail-logs-demo-${ACCOUNT_ID}-${TIMESTAMP} \\"
echo "    --s3-key-prefix cloudtrail-logs/ \\"
echo "    --include-global-service-events \\"
echo "    --is-multi-region-trail \\"
echo "    --enable-log-file-validation \\"
echo "    --cloud-watch-logs-log-group-arn arn:aws:logs:${REGION}:${ACCOUNT_ID}:log-group:CloudTrail/demo-trail:* \\"
echo "    --cloud-watch-logs-role-arn arn:aws:iam::${ACCOUNT_ID}:role/CloudTrail_CloudWatchLogsRole"
echo

echo "# Step 7: Start logging"
echo "aws cloudtrail start-logging --name demo-cloudtrail-trail"
echo

echo "# Verification commands:"
echo "# Check trail status"
echo "aws cloudtrail get-trail-status --name demo-cloudtrail-trail"
echo
echo "# List recent events"
echo "aws cloudtrail lookup-events --max-items 10"
echo
echo "# Describe the trail"
echo "aws cloudtrail describe-trails --trail-name-list demo-cloudtrail-trail"
echo

echo "=== End of CLI Reference ==="
echo "Remember: The actual demonstration uses the AWS Console interface"
echo "These CLI commands are provided for educational comparison only"
