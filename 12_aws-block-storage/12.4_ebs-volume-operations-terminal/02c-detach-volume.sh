#!/bin/bash

# 02c-detach-volume.sh
# Script to detach an EBS volume from an EC2 instance
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
VOLUME_ID_FILE="./volume-id.txt"
FORCE_DETACH="${FORCE_DETACH:-false}"

echo "=================================================="
echo "AWS EBS Volume Detachment Script"
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

print_status "Configuration:"
echo "  Region: $AWS_REGION"
echo "  Volume ID: $VOLUME_ID"
echo "  Force detach: $FORCE_DETACH"
echo

# Get current volume information
print_status "Retrieving current volume information..."
VOLUME_INFO=$(aws ec2 describe-volumes \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'Volumes[0].[State,Size,VolumeType,Attachments[0].InstanceId,Attachments[0].Device,Attachments[0].State]' \
    --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$VOLUME_INFO" = "NOT_FOUND" ]; then
    print_error "Volume $VOLUME_ID not found in region $AWS_REGION"
    exit 1
fi

VOLUME_STATE=$(echo "$VOLUME_INFO" | cut -f1)
VOLUME_SIZE=$(echo "$VOLUME_INFO" | cut -f2)
VOLUME_TYPE=$(echo "$VOLUME_INFO" | cut -f3)
ATTACHED_INSTANCE=$(echo "$VOLUME_INFO" | cut -f4)
DEVICE_NAME=$(echo "$VOLUME_INFO" | cut -f5)
ATTACHMENT_STATE=$(echo "$VOLUME_INFO" | cut -f6)

print_success "Volume found: $VOLUME_ID"
print_status "Current volume details:"
echo "  State: $VOLUME_STATE"
echo "  Size: ${VOLUME_SIZE} GiB"
echo "  Type: $VOLUME_TYPE"
echo "  Attached to: ${ATTACHED_INSTANCE:-None}"
echo "  Device: ${DEVICE_NAME:-N/A}"
echo "  Attachment state: ${ATTACHMENT_STATE:-N/A}"

# Check if volume is attached
if [ "$VOLUME_STATE" = "available" ]; then
    print_warning "Volume is already detached (state: available)"
    print_status "No action needed - volume is ready for reuse or deletion"
    exit 0
fi

if [ "$VOLUME_STATE" != "in-use" ]; then
    print_error "Volume is not in a detachable state (current state: $VOLUME_STATE)"
    exit 1
fi

if [ -z "$ATTACHED_INSTANCE" ] || [ "$ATTACHED_INSTANCE" = "None" ]; then
    print_error "Volume appears to be in-use but no instance attachment found"
    print_error "This may indicate an inconsistent state"
    exit 1
fi

# Get instance information
print_status "Retrieving instance information..."
INSTANCE_INFO=$(aws ec2 describe-instances \
    --region "$AWS_REGION" \
    --instance-ids "$ATTACHED_INSTANCE" \
    --query 'Reservations[0].Instances[0].[InstanceId,State.Name,Platform]' \
    --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$INSTANCE_INFO" != "NOT_FOUND" ]; then
    INSTANCE_STATE=$(echo "$INSTANCE_INFO" | cut -f2)
    INSTANCE_PLATFORM=$(echo "$INSTANCE_INFO" | cut -f3)
    
    print_status "Instance details:"
    echo "  Instance ID: $ATTACHED_INSTANCE"
    echo "  State: $INSTANCE_STATE"
    echo "  Platform: ${INSTANCE_PLATFORM:-Linux}"
else
    print_warning "Could not retrieve instance information (instance may have been terminated)"
    INSTANCE_STATE="unknown"
    INSTANCE_PLATFORM="unknown"
fi

# Check if this is a root volume
print_status "Checking if this is a root volume..."
if [ "$INSTANCE_INFO" != "NOT_FOUND" ]; then
    ROOT_DEVICE=$(aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --instance-ids "$ATTACHED_INSTANCE" \
        --query 'Reservations[0].Instances[0].RootDeviceName' \
        --output text)
    
    if [ "$DEVICE_NAME" = "$ROOT_DEVICE" ]; then
        print_error "Cannot detach root volume ($DEVICE_NAME) while instance is running"
        print_error "You must stop the instance first to detach the root volume"
        exit 1
    fi
    
    print_success "Volume is not the root device (root: $ROOT_DEVICE, volume: $DEVICE_NAME)"
fi

# Show important warnings
echo
print_warning "IMPORTANT SAFETY INFORMATION:"
print_warning "• Detaching a volume while it's being used can cause data corruption"
print_warning "• You should unmount the volume from within the instance first"
print_warning "• Any unsaved data in memory buffers may be lost"

if [ "$INSTANCE_PLATFORM" != "windows" ]; then
    print_status "For Linux instances, unmount with:"
    echo "  sudo umount $DEVICE_NAME"
else
    print_status "For Windows instances:"
    echo "  1. Open Disk Management"
    echo "  2. Right-click the disk and select 'Offline'"
fi

echo
if [ "$FORCE_DETACH" != "true" ]; then
    print_warning "Have you unmounted the volume from within the instance?"
    read -p "Continue with detachment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled by user"
        print_status "Remember to unmount the volume before detaching to prevent data loss"
        exit 0
    fi
fi

echo
print_status "=== DETACHING VOLUME ==="

# Perform the detachment
print_status "Detaching volume $VOLUME_ID from instance $ATTACHED_INSTANCE..."

DETACH_COMMAND="aws ec2 detach-volume --region $AWS_REGION --volume-id $VOLUME_ID"
if [ "$FORCE_DETACH" = "true" ]; then
    DETACH_COMMAND="$DETACH_COMMAND --force"
    print_warning "Using force detach - this may cause data corruption!"
fi

eval $DETACH_COMMAND

if [ $? -eq 0 ]; then
    print_success "Detachment initiated successfully"
else
    print_error "Failed to initiate volume detachment"
    exit 1
fi

# Monitor detachment progress
print_status "Monitoring detachment progress..."
TIMEOUT=120  # 2 minutes timeout
ELAPSED=0
INTERVAL=5

while [ $ELAPSED -lt $TIMEOUT ]; do
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
    
    # Check attachment state
    CURRENT_ATTACHMENT=$(aws ec2 describe-volumes \
        --region "$AWS_REGION" \
        --volume-ids "$VOLUME_ID" \
        --query 'Volumes[0].Attachments[0].State' \
        --output text 2>/dev/null || echo "detached")
    
    if [ "$CURRENT_ATTACHMENT" = "detached" ] || [ "$CURRENT_ATTACHMENT" = "None" ]; then
        print_success "Volume successfully detached!"
        break
    fi
    
    print_status "Detachment state: $CURRENT_ATTACHMENT (elapsed: ${ELAPSED}s)"
    
    if [ "$CURRENT_ATTACHMENT" = "detaching" ]; then
        continue
    elif [ "$CURRENT_ATTACHMENT" = "attached" ]; then
        print_warning "Volume is still attached - detachment may have failed"
        break
    fi
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    print_error "Detachment monitoring timed out after 2 minutes"
    print_status "The detachment may still be in progress"
    print_status "Check status with: aws ec2 describe-volumes --volume-ids $VOLUME_ID"
fi

# Wait for volume to become available
print_status "Waiting for volume to become available..."
aws ec2 wait volume-available --region "$AWS_REGION" --volume-ids "$VOLUME_ID"

if [ $? -eq 0 ]; then
    print_success "Volume is now available for reuse!"
else
    print_warning "Volume may still be in transition state"
fi

# Show final volume status
print_status "Final volume status:"
aws ec2 describe-volumes \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'Volumes[0].[VolumeId,State,Size,VolumeType,AvailabilityZone]' \
    --output table

# Show updated instance block device mappings (if instance still exists)
if [ "$INSTANCE_INFO" != "NOT_FOUND" ]; then
    print_status "Updated instance block device mappings:"
    aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --instance-ids "$ATTACHED_INSTANCE" \
        --query 'Reservations[0].Instances[0].BlockDeviceMappings[].[DeviceName,Ebs.VolumeId,Ebs.Status]' \
        --output table 2>/dev/null || print_warning "Could not retrieve instance block device mappings"
fi

echo
print_success "Volume detachment completed successfully!"
print_status "Volume ID: $VOLUME_ID"
print_status "The volume is now available and can be:"
echo "  • Attached to another instance in the same AZ"
echo "  • Used to create a snapshot"
echo "  • Deleted to stop incurring charges"
echo
print_status "Next steps:"
echo "  • Run './02a-attach-volume.sh' to attach to another instance"
echo "  • Run './03-cleanup.sh' to delete the volume and clean up"
echo "  • Create a snapshot: aws ec2 create-snapshot --volume-id $VOLUME_ID"
echo
