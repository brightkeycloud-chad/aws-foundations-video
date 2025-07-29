#!/bin/bash

# 03-cleanup.sh
# Script to clean up resources created during EBS volume demonstration
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
FORCE_DELETE="${FORCE_DELETE:-false}"

echo "=================================================="
echo "AWS EBS Volume Cleanup Script"
echo "=================================================="
echo

# Check if volume ID file exists
if [ ! -f "$VOLUME_ID_FILE" ]; then
    print_warning "Volume ID file not found: $VOLUME_ID_FILE"
    print_status "Searching for demo volumes created by this script..."
    
    # Search for volumes with demo tags
    DEMO_VOLUMES=$(aws ec2 describe-volumes \
        --region "$AWS_REGION" \
        --filters "Name=tag:CreatedBy,Values=DemoScript" "Name=tag:Purpose,Values=AWS-Foundations-Training" \
        --query 'Volumes[].VolumeId' \
        --output text)
    
    if [ -z "$DEMO_VOLUMES" ]; then
        print_status "No demo volumes found. Nothing to clean up."
        exit 0
    fi
    
    print_status "Found demo volumes: $DEMO_VOLUMES"
    echo "$DEMO_VOLUMES" | tr '\t' '\n' > temp_volumes.txt
    VOLUME_ID_FILE="temp_volumes.txt"
fi

# Read volume IDs
if [ -f "$VOLUME_ID_FILE" ]; then
    VOLUME_IDS=$(cat "$VOLUME_ID_FILE")
else
    print_error "No volume IDs found to clean up"
    exit 1
fi

print_status "Configuration:"
echo "  Region: $AWS_REGION"
echo "  Volume ID(s): $VOLUME_IDS"
echo

# Process each volume ID
for VOLUME_ID in $VOLUME_IDS; do
    echo "=================================================="
    print_status "Processing volume: $VOLUME_ID"
    echo "=================================================="
    
    # Check if volume exists
    if ! aws ec2 describe-volumes --region "$AWS_REGION" --volume-ids "$VOLUME_ID" &>/dev/null; then
        print_warning "Volume $VOLUME_ID not found. It may have already been deleted."
        continue
    fi
    
    # Get volume information
    VOLUME_INFO=$(aws ec2 describe-volumes \
        --region "$AWS_REGION" \
        --volume-ids "$VOLUME_ID" \
        --query 'Volumes[0].[State,Size,VolumeType,Attachments[0].InstanceId]' \
        --output text)
    
    VOLUME_STATE=$(echo "$VOLUME_INFO" | cut -f1)
    VOLUME_SIZE=$(echo "$VOLUME_INFO" | cut -f2)
    VOLUME_TYPE=$(echo "$VOLUME_INFO" | cut -f3)
    ATTACHED_INSTANCE=$(echo "$VOLUME_INFO" | cut -f4)
    
    print_status "Volume details:"
    echo "  State: $VOLUME_STATE"
    echo "  Size: ${VOLUME_SIZE} GiB"
    echo "  Type: $VOLUME_TYPE"
    echo "  Attached to: ${ATTACHED_INSTANCE:-None}"
    
    # Show estimated cost savings
    case $VOLUME_TYPE in
        gp3)
            MONTHLY_COST=$(echo "scale=2; $VOLUME_SIZE * 0.08" | bc 2>/dev/null || echo "~\$$(($VOLUME_SIZE * 8 / 100))")
            ;;
        gp2)
            MONTHLY_COST=$(echo "scale=2; $VOLUME_SIZE * 0.10" | bc 2>/dev/null || echo "~\$$(($VOLUME_SIZE * 10 / 100))")
            ;;
        *)
            MONTHLY_COST="varies"
            ;;
    esac
    
    if [ "$MONTHLY_COST" != "varies" ]; then
        print_status "Estimated monthly cost savings: \$${MONTHLY_COST}"
    fi
    
    # Handle attached volumes
    if [ "$ATTACHED_INSTANCE" != "None" ] && [ "$ATTACHED_INSTANCE" != "" ]; then
        print_warning "Volume is currently attached to instance: $ATTACHED_INSTANCE"
        
        if [ "$FORCE_DELETE" = "true" ]; then
            print_status "Force delete enabled. Detaching volume first..."
            
            # Detach the volume
            aws ec2 detach-volume --region "$AWS_REGION" --volume-id "$VOLUME_ID"
            
            # Wait for detachment
            print_status "Waiting for volume to detach..."
            aws ec2 wait volume-available --region "$AWS_REGION" --volume-ids "$VOLUME_ID"
            print_success "Volume detached successfully"
        else
            print_error "Cannot delete attached volume. Options:"
            echo "  1. Detach manually: aws ec2 detach-volume --volume-id $VOLUME_ID"
            echo "  2. Run with force: FORCE_DELETE=true ./03-cleanup.sh"
            echo "  3. Run volume operations script to detach: ./02-volume-operations.sh"
            continue
        fi
    fi
    
    # Confirm deletion unless in force mode
    if [ "$FORCE_DELETE" != "true" ]; then
        echo
        print_warning "This will permanently delete the volume and all its data!"
        print_warning "This action cannot be undone."
        read -p "Delete volume $VOLUME_ID? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Skipping deletion of volume $VOLUME_ID"
            continue
        fi
    fi
    
    # Create snapshot before deletion (optional safety measure)
    if [ "$FORCE_DELETE" != "true" ]; then
        read -p "Create snapshot before deletion? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            print_status "Creating snapshot before deletion..."
            SNAPSHOT_ID=$(aws ec2 create-snapshot \
                --region "$AWS_REGION" \
                --volume-id "$VOLUME_ID" \
                --description "Pre-deletion snapshot of demo volume $VOLUME_ID" \
                --tag-specifications "ResourceType=snapshot,Tags=[{Key=Name,Value=Demo-Volume-Backup},{Key=OriginalVolumeId,Value=$VOLUME_ID},{Key=CreatedBy,Value=CleanupScript}]" \
                --query 'SnapshotId' \
                --output text)
            
            print_success "Snapshot created: $SNAPSHOT_ID"
            print_status "You can restore the volume later using this snapshot"
        fi
    fi
    
    # Delete the volume
    print_status "Deleting volume $VOLUME_ID..."
    if aws ec2 delete-volume --region "$AWS_REGION" --volume-id "$VOLUME_ID"; then
        print_success "Volume $VOLUME_ID deleted successfully!"
    else
        print_error "Failed to delete volume $VOLUME_ID"
        print_error "The volume may be in use or have delete protection enabled"
        continue
    fi
    
    # Verify deletion
    sleep 2
    if aws ec2 describe-volumes --region "$AWS_REGION" --volume-ids "$VOLUME_ID" &>/dev/null; then
        print_warning "Volume still exists. Deletion may be in progress..."
    else
        print_success "Volume deletion confirmed"
    fi
    
    echo
done

# Clean up temporary files
print_status "Cleaning up temporary files..."
if [ -f "$VOLUME_ID_FILE" ]; then
    rm -f "$VOLUME_ID_FILE"
    print_success "Removed $VOLUME_ID_FILE"
fi

if [ -f "temp_volumes.txt" ]; then
    rm -f "temp_volumes.txt"
    print_success "Removed temp_volumes.txt"
fi

echo
print_status "=== CLEANUP SUMMARY ==="

# Show remaining demo volumes (if any)
REMAINING_VOLUMES=$(aws ec2 describe-volumes \
    --region "$AWS_REGION" \
    --filters "Name=tag:CreatedBy,Values=DemoScript" "Name=tag:Purpose,Values=AWS-Foundations-Training" \
    --query 'Volumes[].[VolumeId,State,Size]' \
    --output table 2>/dev/null || echo "")

if [ -n "$REMAINING_VOLUMES" ] && [ "$REMAINING_VOLUMES" != "" ]; then
    print_warning "Remaining demo volumes:"
    echo "$REMAINING_VOLUMES"
else
    print_success "All demo volumes have been cleaned up!"
fi

# Show any snapshots created during cleanup
CLEANUP_SNAPSHOTS=$(aws ec2 describe-snapshots \
    --region "$AWS_REGION" \
    --owner-ids self \
    --filters "Name=tag:CreatedBy,Values=CleanupScript" \
    --query 'Snapshots[].[SnapshotId,State,VolumeSize,Description]' \
    --output table 2>/dev/null || echo "")

if [ -n "$CLEANUP_SNAPSHOTS" ] && [ "$CLEANUP_SNAPSHOTS" != "" ]; then
    print_status "Snapshots created during cleanup:"
    echo "$CLEANUP_SNAPSHOTS"
    print_warning "Remember to delete these snapshots when no longer needed to avoid charges"
fi

echo
print_success "Cleanup completed!"
print_status "All demo resources have been processed."
print_status "Thank you for using the AWS EBS Volume Operations demonstration!"
echo
