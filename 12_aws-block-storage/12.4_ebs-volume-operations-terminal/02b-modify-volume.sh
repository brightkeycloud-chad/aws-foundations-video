#!/bin/bash

# 02b-modify-volume.sh
# Script to modify an EBS volume (expand size, change IOPS, etc.)
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
SIZE_INCREASE="${SIZE_INCREASE:-5}"  # Default increase by 5 GiB

echo "=================================================="
echo "AWS EBS Volume Modification Script"
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
echo "  Size increase: ${SIZE_INCREASE} GiB"
echo

# Get current volume information
print_status "Retrieving current volume information..."
VOLUME_INFO=$(aws ec2 describe-volumes \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'Volumes[0].[State,Size,VolumeType,Iops,Throughput,Attachments[0].InstanceId]' \
    --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$VOLUME_INFO" = "NOT_FOUND" ]; then
    print_error "Volume $VOLUME_ID not found in region $AWS_REGION"
    exit 1
fi

VOLUME_STATE=$(echo "$VOLUME_INFO" | cut -f1)
CURRENT_SIZE=$(echo "$VOLUME_INFO" | cut -f2)
VOLUME_TYPE=$(echo "$VOLUME_INFO" | cut -f3)
CURRENT_IOPS=$(echo "$VOLUME_INFO" | cut -f4)
CURRENT_THROUGHPUT=$(echo "$VOLUME_INFO" | cut -f5)
ATTACHED_INSTANCE=$(echo "$VOLUME_INFO" | cut -f6)

print_success "Volume found: $VOLUME_ID"
print_status "Current volume details:"
echo "  State: $VOLUME_STATE"
echo "  Size: ${CURRENT_SIZE} GiB"
echo "  Type: $VOLUME_TYPE"
echo "  IOPS: ${CURRENT_IOPS:-N/A}"
echo "  Throughput: ${CURRENT_THROUGHPUT:-N/A} MiB/s"
echo "  Attached to: ${ATTACHED_INSTANCE:-None}"

# Calculate new size
NEW_SIZE=$((CURRENT_SIZE + SIZE_INCREASE))

print_status "Planned modification:"
echo "  Current size: ${CURRENT_SIZE} GiB"
echo "  New size: ${NEW_SIZE} GiB"
echo "  Increase: ${SIZE_INCREASE} GiB"

# Check if volume is in a modifiable state
if [ "$VOLUME_STATE" != "available" ] && [ "$VOLUME_STATE" != "in-use" ]; then
    print_error "Volume is not in a modifiable state (current state: $VOLUME_STATE)"
    print_error "Volume must be in 'available' or 'in-use' state for modification"
    exit 1
fi

# Check for existing modifications
print_status "Checking for existing modifications..."
EXISTING_MODS=$(aws ec2 describe-volumes-modifications \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'VolumesModifications[?ModificationState==`modifying`].[VolumeId,ModificationState]' \
    --output text)

if [ -n "$EXISTING_MODS" ]; then
    print_error "Volume $VOLUME_ID has modifications in progress"
    print_status "Current modification status:"
    aws ec2 describe-volumes-modifications \
        --region "$AWS_REGION" \
        --volume-ids "$VOLUME_ID" \
        --query 'VolumesModifications[0].[VolumeId,ModificationState,OriginalSize,TargetSize,Progress]' \
        --output table
    print_error "Wait for current modifications to complete before starting new ones"
    exit 1
fi

# Estimate cost impact (rough calculation for gp3)
if [ "$VOLUME_TYPE" = "gp3" ]; then
    COST_INCREASE=$(echo "scale=2; $SIZE_INCREASE * 0.08" | bc 2>/dev/null || echo "~\$$(($SIZE_INCREASE * 8 / 100))")
    print_status "Estimated monthly cost increase: \$${COST_INCREASE}"
fi

# Confirm modification
echo
print_warning "This will modify the volume size from ${CURRENT_SIZE} GiB to ${NEW_SIZE} GiB"
print_warning "Volume modifications cannot be reversed, only further expanded"
if [ "$ATTACHED_INSTANCE" != "None" ] && [ "$ATTACHED_INSTANCE" != "" ]; then
    print_warning "Volume is attached to instance $ATTACHED_INSTANCE"
    print_warning "You may need to extend the filesystem inside the instance after modification"
fi

read -p "Continue with volume modification? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Operation cancelled by user"
    exit 0
fi

echo
print_status "=== MODIFYING VOLUME ==="

# Perform the volume modification
print_status "Initiating volume modification..."
MODIFICATION_RESULT=$(aws ec2 modify-volume \
    --region "$AWS_REGION" \
    --volume-id "$VOLUME_ID" \
    --size "$NEW_SIZE" \
    --query '[VolumeModification.VolumeId,VolumeModification.ModificationState]' \
    --output text)

if [ $? -eq 0 ]; then
    print_success "Volume modification initiated successfully"
    print_status "Modification result: $MODIFICATION_RESULT"
else
    print_error "Failed to initiate volume modification"
    exit 1
fi

# Monitor modification progress
print_status "Monitoring modification progress..."
echo "This may take several minutes depending on the volume size and type..."

# Show initial modification status
aws ec2 describe-volumes-modifications \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'VolumesModifications[0].[VolumeId,ModificationState,OriginalSize,TargetSize,Progress]' \
    --output table

# Wait and monitor progress
TIMEOUT=300  # 5 minutes timeout
ELAPSED=0
INTERVAL=15

while [ $ELAPSED -lt $TIMEOUT ]; do
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
    
    MOD_STATUS=$(aws ec2 describe-volumes-modifications \
        --region "$AWS_REGION" \
        --volume-ids "$VOLUME_ID" \
        --query 'VolumesModifications[0].[ModificationState,Progress]' \
        --output text)
    
    MOD_STATE=$(echo "$MOD_STATUS" | cut -f1)
    MOD_PROGRESS=$(echo "$MOD_STATUS" | cut -f2)
    
    print_status "Modification status: $MOD_STATE, Progress: ${MOD_PROGRESS}%"
    
    if [ "$MOD_STATE" = "completed" ]; then
        print_success "Volume modification completed!"
        break
    elif [ "$MOD_STATE" = "failed" ]; then
        print_error "Volume modification failed!"
        break
    elif [ "$MOD_STATE" = "optimizing" ]; then
        print_status "Modification completed, now optimizing performance..."
        break
    fi
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    print_warning "Modification monitoring timed out after 5 minutes"
    print_status "The modification may still be in progress"
fi

# Show final modification status
print_status "Final modification status:"
aws ec2 describe-volumes-modifications \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'VolumesModifications[0].[VolumeId,ModificationState,OriginalSize,TargetSize,Progress,StartTime]' \
    --output table

# Show updated volume information
print_status "Updated volume information:"
aws ec2 describe-volumes \
    --region "$AWS_REGION" \
    --volume-ids "$VOLUME_ID" \
    --query 'Volumes[0].[VolumeId,State,Size,VolumeType,Iops,Throughput]' \
    --output table

echo
print_success "Volume modification process completed!"
print_status "Volume ID: $VOLUME_ID"
print_status "New size: ${NEW_SIZE} GiB"

if [ "$ATTACHED_INSTANCE" != "None" ] && [ "$ATTACHED_INSTANCE" != "" ]; then
    print_warning "IMPORTANT: Filesystem extension required!"
    print_status "The volume has been expanded, but you need to extend the filesystem:"
    echo
    print_status "For Linux instances:"
    echo "  1. Connect to instance: aws ec2-instance-connect ssh --instance-id $ATTACHED_INSTANCE"
    echo "  2. Check current filesystem: df -h"
    echo "  3. Extend partition: sudo growpart /dev/xvdf 1  # adjust device name"
    echo "  4. Extend filesystem: sudo resize2fs /dev/xvdf1  # for ext4"
    echo "     or: sudo xfs_growfs /mount/point  # for xfs"
    echo
    print_status "For Windows instances:"
    echo "  1. Connect via RDP"
    echo "  2. Open Disk Management"
    echo "  3. Right-click the volume and select 'Extend Volume'"
fi

print_status "Next step: Run './02c-detach-volume.sh' to detach the volume"
echo
