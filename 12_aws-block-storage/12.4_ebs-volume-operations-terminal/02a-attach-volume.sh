#!/bin/bash

# 02a-attach-volume.sh
# Script to attach an EBS volume to an EC2 instance
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
INSTANCE_ID="${INSTANCE_ID}"  # Must be provided by user
DEVICE_NAME="${DEVICE_NAME:-/dev/sdf}"
VOLUME_ID_FILE="./volume-id.txt"

echo "=================================================="
echo "AWS EBS Volume Attachment Script"
echo "=================================================="
echo

# Check if volume ID file exists
if [ ! -f "$VOLUME_ID_FILE" ]; then
    print_error "Volume ID file not found: $VOLUME_ID_FILE"
    print_error "Please run './01-create-volume.sh' first to create a volume."
    exit 1
fi

# Read volume ID from file
VOLUME_ID=$(cat "$VOLUME_ID_FILE")
print_status "Using volume ID: $VOLUME_ID"

# Check if instance ID is provided
if [ -z "$INSTANCE_ID" ]; then
    print_error "INSTANCE_ID environment variable is required."
    print_error "Please set it with: export INSTANCE_ID=i-1234567890abcdef0"
    print_error "Or run: INSTANCE_ID=i-1234567890abcdef0 ./02a-attach-volume.sh"
    echo
    print_status "Available instances in region $AWS_REGION:"
    aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,Placement.AvailabilityZone]' \
        --output table
    exit 1
fi

print_status "Configuration:"
echo "  Region: $AWS_REGION"
echo "  Volume ID: $VOLUME_ID"
echo "  Instance ID: $INSTANCE_ID"
echo "  Device Name: $DEVICE_NAME"
echo

# Verify instance exists and get its details
print_status "Verifying target instance..."
INSTANCE_INFO=$(aws ec2 describe-instances \
    --region "$AWS_REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].[InstanceId,State.Name,Placement.AvailabilityZone]' \
    --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$INSTANCE_INFO" = "NOT_FOUND" ]; then
    print_error "Instance $INSTANCE_ID not found in region $AWS_REGION"
    exit 1
fi

INSTANCE_STATE=$(echo "$INSTANCE_INFO" | cut -f2)
INSTANCE_AZ=$(echo "$INSTANCE_INFO" | cut -f3)

print_success "Instance found: $INSTANCE_ID"
print_status "Instance state: $INSTANCE_STATE"
print_status "Instance AZ: $INSTANCE_AZ"

# Verify volume exists and get its details
print_status "Verifying volume..."
VOLUME_INFO=$(aws ec2 describe-volumes \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'Volumes[0].[State,AvailabilityZone,Size,VolumeType]' \
    --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$VOLUME_INFO" = "NOT_FOUND" ]; then
    print_error "Volume $VOLUME_ID not found in region $AWS_REGION"
    exit 1
fi

VOLUME_STATE=$(echo "$VOLUME_INFO" | cut -f1)
VOLUME_AZ=$(echo "$VOLUME_INFO" | cut -f2)
VOLUME_SIZE=$(echo "$VOLUME_INFO" | cut -f3)
VOLUME_TYPE=$(echo "$VOLUME_INFO" | cut -f4)

print_success "Volume found: $VOLUME_ID"
print_status "Volume state: $VOLUME_STATE"
print_status "Volume AZ: $VOLUME_AZ"
print_status "Volume size: ${VOLUME_SIZE} GiB"
print_status "Volume type: $VOLUME_TYPE"

# Verify volume and instance are in the same AZ
if [ "$VOLUME_AZ" != "$INSTANCE_AZ" ]; then
    print_error "Volume AZ ($VOLUME_AZ) does not match instance AZ ($INSTANCE_AZ)"
    print_error "Volumes can only be attached to instances in the same Availability Zone"
    exit 1
fi

print_success "Volume and instance are in the same AZ: $VOLUME_AZ"

# Check if volume is available for attachment
if [ "$VOLUME_STATE" != "available" ]; then
    print_error "Volume is not available for attachment (current state: $VOLUME_STATE)"
    if [ "$VOLUME_STATE" = "in-use" ]; then
        print_status "Volume attachment details:"
        aws ec2 describe-volumes \
            --region "$AWS_REGION" \
            --volume-ids "$VOLUME_ID" \
            --query 'Volumes[0].Attachments[0].[InstanceId,Device,State]' \
            --output table
    fi
    exit 1
fi

# Check if instance is running
if [ "$INSTANCE_STATE" != "running" ]; then
    print_warning "Instance is not in 'running' state (current: $INSTANCE_STATE)"
    print_warning "Volume attachment may fail if instance is not running"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled by user"
        exit 0
    fi
fi

# Check if device name is already in use
print_status "Checking if device name is available..."
EXISTING_DEVICE=$(aws ec2 describe-instances \
    --region "$AWS_REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].BlockDeviceMappings[?DeviceName=='$DEVICE_NAME'].DeviceName" \
    --output text)

if [ "$EXISTING_DEVICE" = "$DEVICE_NAME" ]; then
    print_warning "Device name $DEVICE_NAME is already in use on instance $INSTANCE_ID"
    print_status "Current block device mappings:"
    aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].BlockDeviceMappings[].[DeviceName,Ebs.VolumeId]' \
        --output table
    
    read -p "Continue with attachment anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled by user"
        exit 0
    fi
fi

echo
print_status "=== ATTACHING VOLUME ==="

# Attach the volume
print_status "Attaching volume $VOLUME_ID to instance $INSTANCE_ID at device $DEVICE_NAME..."
aws ec2 attach-volume \
    --region "$AWS_REGION" \
    --volume-id "$VOLUME_ID" \
    --instance-id "$INSTANCE_ID" \
    --device "$DEVICE_NAME"

if [ $? -eq 0 ]; then
    print_success "Attachment initiated successfully"
else
    print_error "Failed to initiate volume attachment"
    exit 1
fi

# Wait for attachment to complete
print_status "Waiting for volume to be attached..."
aws ec2 wait volume-in-use --region "$AWS_REGION" --volume-ids "$VOLUME_ID"

if [ $? -eq 0 ]; then
    print_success "Volume successfully attached!"
else
    print_error "Timeout waiting for volume attachment"
    exit 1
fi

# Show attachment details
print_status "Attachment details:"
aws ec2 describe-volumes \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'Volumes[0].Attachments[0].[VolumeId,InstanceId,Device,State,AttachTime]' \
    --output table

# Show updated instance block device mappings
print_status "Updated instance block device mappings:"
aws ec2 describe-instances \
    --region "$AWS_REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].BlockDeviceMappings[].[DeviceName,Ebs.VolumeId,Ebs.Status]' \
    --output table

echo
print_success "Volume attachment completed successfully!"
print_status "Volume ID: $VOLUME_ID"
print_status "Instance ID: $INSTANCE_ID"
print_status "Device: $DEVICE_NAME"
print_warning "Remember to format and mount the volume inside the instance before use"
print_status "Next steps:"
echo "  • Connect to the instance: aws ec2-instance-connect ssh --instance-id $INSTANCE_ID"
echo "  • Format the volume: sudo mkfs -t ext4 $DEVICE_NAME"
echo "  • Mount the volume: sudo mount $DEVICE_NAME /mnt/ebs-volume"
echo "  • Or run './02b-modify-volume.sh' to demonstrate volume modification"
echo
