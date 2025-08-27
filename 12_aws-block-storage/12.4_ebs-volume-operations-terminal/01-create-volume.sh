#!/bin/bash

# 01-create-volume.sh
# Script to create an EBS volume for demonstration purposes
# Part of AWS Foundations Training - EBS Volume Operations

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration variables
AWS_REGION="${AWS_REGION:-us-east-1}"
AVAILABILITY_ZONE="${AVAILABILITY_ZONE:-us-east-1b}"
VOLUME_SIZE="${VOLUME_SIZE:-10}"
VOLUME_TYPE="${VOLUME_TYPE:-gp3}"

# File to store volume ID for other scripts
VOLUME_ID_FILE="./volume-id.txt"

echo "=================================================="
echo "AWS EBS Volume Creation Script"
echo "=================================================="
echo

print_status "Configuration:"
echo "  Region: $AWS_REGION"
echo "  Availability Zone: $AVAILABILITY_ZONE"
echo "  Volume Size: ${VOLUME_SIZE} GiB"
echo "  Volume Type: $VOLUME_TYPE"
echo

# Check if AWS CLI is installed and configured
print_status "Checking AWS CLI configuration..."
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Test AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured or invalid."
    print_error "Please run 'aws configure' or set up your credentials."
    exit 1
fi

print_success "AWS CLI is configured and credentials are valid."

# Verify the availability zone exists
print_status "Verifying availability zone exists..."
if ! aws ec2 describe-availability-zones --zone-names "$AVAILABILITY_ZONE" &> /dev/null; then
    print_error "Availability zone '$AVAILABILITY_ZONE' does not exist in region '$AWS_REGION'."
    print_status "Available zones in $AWS_REGION:"
    aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output table
    exit 1
fi

print_success "Availability zone '$AVAILABILITY_ZONE' is valid."

# Create the EBS volume
print_status "Creating EBS volume..."
VOLUME_ID=$(aws ec2 create-volume \
    --region "$AWS_REGION" \
    --volume-type "$VOLUME_TYPE" \
    --size "$VOLUME_SIZE" \
    --availability-zone "$AVAILABILITY_ZONE" \
    --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=CLI-Demo-Volume},{Key=Environment,Value=Training},{Key=CreatedBy,Value=DemoScript},{Key=Purpose,Value=AWS-Foundations-Training}]" \
    --query 'VolumeId' \
    --output text)

if [ $? -eq 0 ]; then
    print_success "Volume created with ID: $VOLUME_ID"
    echo "$VOLUME_ID" > "$VOLUME_ID_FILE"
    print_status "Volume ID saved to $VOLUME_ID_FILE"
else
    print_error "Failed to create volume."
    exit 1
fi

# Wait for volume to become available
print_status "Waiting for volume to become available..."
aws ec2 wait volume-available --volume-ids "$VOLUME_ID" --region "$AWS_REGION"

if [ $? -eq 0 ]; then
    print_success "Volume is now available!"
else
    print_error "Timeout waiting for volume to become available."
    exit 1
fi

# Display volume information
print_status "Volume details:"
aws ec2 describe-volumes \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'Volumes[0].[VolumeId,State,Size,VolumeType,AvailabilityZone,Encrypted]' \
    --output table

# Display volume tags
print_status "Volume tags:"
aws ec2 describe-volumes \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'Volumes[0].Tags[].[Key,Value]' \
    --output table

echo
print_success "Volume creation completed successfully!"
print_status "Volume ID: $VOLUME_ID"
print_status "Next step: Run './02-volume-operations.sh' to perform volume operations"
echo
