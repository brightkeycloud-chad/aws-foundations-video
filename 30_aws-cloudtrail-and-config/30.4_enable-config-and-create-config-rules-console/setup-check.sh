#!/bin/bash

# AWS Config Demo Setup Check Script
# This script verifies prerequisites and prepares the environment for the AWS Config demonstration

set -e

echo "=== AWS Config Demo Setup Check ==="
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
echo "2. Checking AWS Config permissions..."
PERMISSIONS_OK=true

# Test Config permissions
if ! aws configservice describe-configuration-recorders &> /dev/null; then
    echo "❌ Missing AWS Config permissions"
    PERMISSIONS_OK=false
fi

# Test S3 permissions
if ! aws s3api list-buckets --query 'Buckets[0].Name' --output text &> /dev/null; then
    echo "❌ Missing S3 permissions"
    PERMISSIONS_OK=false
fi

# Test SNS permissions
if ! aws sns list-topics --query 'Topics[0].TopicArn' --output text &> /dev/null; then
    echo "❌ Missing SNS permissions"
    PERMISSIONS_OK=false
fi

# Test IAM permissions
if ! aws iam list-roles --max-items 1 --query 'Roles[0].RoleName' --output text &> /dev/null; then
    echo "❌ Missing IAM permissions"
    PERMISSIONS_OK=false
fi

if [ "$PERMISSIONS_OK" = true ]; then
    echo "✅ Required permissions verified"
else
    echo "❌ Some permissions are missing. Please ensure your user has:"
    echo "   - AWS Config full access"
    echo "   - S3 full access"
    echo "   - SNS full access"
    echo "   - IAM read/write access"
    exit 1
fi
echo

# Check for existing AWS Config setup
echo "3. Checking existing AWS Config configuration..."
EXISTING_RECORDERS=$(aws configservice describe-configuration-recorders --query 'ConfigurationRecorders[].name' --output text 2>/dev/null || echo "")

if [ -n "$EXISTING_RECORDERS" ]; then
    echo "⚠️  Existing Config recorders found:"
    for recorder in $EXISTING_RECORDERS; do
        echo "   - $recorder"
    done
    echo "   This demo may modify existing Config setup"
else
    echo "✅ No existing Config recorders found - ready for demo"
fi

# Check for existing Config rules
EXISTING_RULES=$(aws configservice describe-config-rules --query 'ConfigRules[].ConfigRuleName' --output text 2>/dev/null || echo "")
if [ -n "$EXISTING_RULES" ]; then
    echo "⚠️  Existing Config rules found:"
    for rule in $EXISTING_RULES; do
        echo "   - $rule"
    done
fi
echo

# Check for existing AWS resources to monitor
echo "4. Checking for AWS resources to monitor..."
RESOURCE_COUNT=0

# Check EC2 instances
EC2_COUNT=$(aws ec2 describe-instances --query 'length(Reservations[].Instances[])' --output text 2>/dev/null || echo "0")
if [ "$EC2_COUNT" -gt 0 ]; then
    echo "✅ Found $EC2_COUNT EC2 instances to monitor"
    RESOURCE_COUNT=$((RESOURCE_COUNT + EC2_COUNT))
fi

# Check S3 buckets
S3_COUNT=$(aws s3api list-buckets --query 'length(Buckets)' --output text 2>/dev/null || echo "0")
if [ "$S3_COUNT" -gt 0 ]; then
    echo "✅ Found $S3_COUNT S3 buckets to monitor"
    RESOURCE_COUNT=$((RESOURCE_COUNT + S3_COUNT))
fi

# Check Security Groups
SG_COUNT=$(aws ec2 describe-security-groups --query 'length(SecurityGroups)' --output text 2>/dev/null || echo "0")
if [ "$SG_COUNT" -gt 0 ]; then
    echo "✅ Found $SG_COUNT Security Groups to monitor"
    RESOURCE_COUNT=$((RESOURCE_COUNT + SG_COUNT))
fi

# Check IAM roles
IAM_COUNT=$(aws iam list-roles --query 'length(Roles)' --output text 2>/dev/null || echo "0")
if [ "$IAM_COUNT" -gt 0 ]; then
    echo "✅ Found $IAM_COUNT IAM roles to monitor"
    RESOURCE_COUNT=$((RESOURCE_COUNT + IAM_COUNT))
fi

if [ "$RESOURCE_COUNT" -gt 0 ]; then
    echo "✅ Total discoverable resources: $RESOURCE_COUNT"
else
    echo "⚠️  No AWS resources found. Consider creating some resources first:"
    echo "   - Launch an EC2 instance"
    echo "   - Create an S3 bucket"
    echo "   - Create a security group"
fi
echo

# Generate unique names for demo resources
TIMESTAMP=$(date +%s)
SUGGESTED_BUCKET="config-bucket-${ACCOUNT_ID}-${REGION}"
SUGGESTED_TOPIC="config-topic"

echo "5. Demo preparation complete!"
echo "✅ All prerequisites met"
echo "✅ Suggested S3 bucket name: $SUGGESTED_BUCKET"
echo "✅ Suggested SNS topic name: $SUGGESTED_TOPIC"
echo "✅ Config rules to create:"
echo "   - s3-bucket-public-access-prohibited"
echo "   - ec2-security-group-attached-to-eni"
echo
echo "You can now proceed with the AWS Config console demonstration."
echo "Remember to run './cleanup.sh' after the demo to remove all created resources."
