#!/bin/bash

# CloudTrail Demo Setup Check Script
# This script verifies prerequisites and prepares the environment for the CloudTrail demonstration

set -e

echo "=== CloudTrail Demo Setup Check ==="
echo

# Check AWS CLI is installed and configured
echo "1. Checking AWS CLI configuration..."
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region || echo "us-east-1")
USER_ARN=$(aws sts get-caller-identity --query Arn --output text)

echo "✅ AWS CLI configured"
echo "   Account ID: $ACCOUNT_ID"
echo "   Region: $REGION"
echo "   User/Role: $USER_ARN"
echo

# Check required permissions
echo "2. Checking CloudTrail permissions..."
PERMISSIONS_OK=true

# Test CloudTrail permissions
if ! aws cloudtrail describe-trails --query 'trailList[0].Name' --output text &> /dev/null; then
    echo "❌ Missing CloudTrail read permissions"
    PERMISSIONS_OK=false
fi

# Test S3 permissions (try to list buckets)
if ! aws s3api list-buckets --query 'Buckets[0].Name' --output text &> /dev/null; then
    echo "❌ Missing S3 permissions"
    PERMISSIONS_OK=false
fi

# Test IAM permissions (try to list roles)
if ! aws iam list-roles --max-items 1 --query 'Roles[0].RoleName' --output text &> /dev/null; then
    echo "❌ Missing IAM read permissions"
    PERMISSIONS_OK=false
fi

if [ "$PERMISSIONS_OK" = true ]; then
    echo "✅ Required permissions verified"
else
    echo "❌ Some permissions are missing. Please ensure your user has:"
    echo "   - CloudTrail full access"
    echo "   - S3 full access"
    echo "   - IAM read access"
    echo "   - CloudWatch Logs access (if using CloudWatch integration)"
    exit 1
fi
echo

# Check for existing CloudTrail trails
echo "3. Checking existing CloudTrail configuration..."
EXISTING_TRAILS=$(aws cloudtrail describe-trails --query 'trailList[].Name' --output text)

if [ -n "$EXISTING_TRAILS" ]; then
    echo "⚠️  Existing CloudTrail trails found:"
    for trail in $EXISTING_TRAILS; do
        echo "   - $trail"
    done
    echo "   This demo will create a new trail named 'demo-cloudtrail-trail'"
else
    echo "✅ No existing trails found - ready for demo"
fi
echo

# Generate unique bucket name suggestion
TIMESTAMP=$(date +%s)
SUGGESTED_BUCKET="cloudtrail-logs-demo-${ACCOUNT_ID}-${TIMESTAMP}"

echo "4. Demo preparation complete!"
echo "✅ All prerequisites met"
echo "✅ Suggested S3 bucket name: $SUGGESTED_BUCKET"
echo "✅ Demo trail name will be: demo-cloudtrail-trail"
echo
echo "You can now proceed with the CloudTrail console demonstration."
echo "Remember to run './cleanup.sh' after the demo to remove all created resources."
