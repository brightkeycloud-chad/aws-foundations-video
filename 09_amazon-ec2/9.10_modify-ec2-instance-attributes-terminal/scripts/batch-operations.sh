#!/bin/bash

# EC2 Instance Attributes Demo - Batch Operations
# This script demonstrates modifying attributes for multiple instances

set -e  # Exit on any error

echo "=== EC2 Instance Attributes Demo - Batch Operations ==="
echo

# Function to display usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --tag-filter KEY=VALUE    Filter instances by tag (e.g., Environment=Development)"
    echo "  --instance-ids ID1,ID2    Comma-separated list of instance IDs"
    echo "  --enable-protection       Enable termination protection"
    echo "  --disable-protection      Disable termination protection"
    echo "  --help                    Show this help message"
    echo
    echo "Examples:"
    echo "  $0 --tag-filter Environment=Development --enable-protection"
    echo "  $0 --instance-ids i-1234567890abcdef0,i-0987654321fedcba0 --disable-protection"
}

# Parse command line arguments
TAG_FILTER=""
INSTANCE_IDS=""
ACTION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --tag-filter)
            TAG_FILTER="$2"
            shift 2
            ;;
        --instance-ids)
            INSTANCE_IDS="$2"
            shift 2
            ;;
        --enable-protection)
            ACTION="enable"
            shift
            ;;
        --disable-protection)
            ACTION="disable"
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate arguments
if [[ -z "$ACTION" ]]; then
    echo "❌ Please specify an action: --enable-protection or --disable-protection"
    show_usage
    exit 1
fi

if [[ -z "$TAG_FILTER" && -z "$INSTANCE_IDS" ]]; then
    echo "❌ Please specify either --tag-filter or --instance-ids"
    show_usage
    exit 1
fi

# Get list of instance IDs
if [[ -n "$TAG_FILTER" ]]; then
    echo "🔍 Finding instances with tag filter: $TAG_FILTER"
    
    # Parse tag filter
    TAG_KEY=$(echo "$TAG_FILTER" | cut -d'=' -f1)
    TAG_VALUE=$(echo "$TAG_FILTER" | cut -d'=' -f2)
    
    # Get instance IDs matching the tag filter
    INSTANCE_LIST=$(aws ec2 describe-instances \
        --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[*].Instances[*].InstanceId' \
        --output text)
    
    if [[ -z "$INSTANCE_LIST" ]]; then
        echo "❌ No instances found with tag $TAG_FILTER"
        exit 1
    fi
    
    # Convert to array
    read -ra INSTANCES <<< "$INSTANCE_LIST"
    
elif [[ -n "$INSTANCE_IDS" ]]; then
    echo "🔍 Using provided instance IDs: $INSTANCE_IDS"
    
    # Convert comma-separated list to array
    IFS=',' read -ra INSTANCES <<< "$INSTANCE_IDS"
fi

echo "📋 Found ${#INSTANCES[@]} instance(s) to modify:"
for instance in "${INSTANCES[@]}"; do
    echo "   • $instance"
done
echo

# Confirm action
if [[ "$ACTION" == "enable" ]]; then
    ACTION_DESC="enable termination protection"
    ACTION_FLAG="--disable-api-termination"
else
    ACTION_DESC="disable termination protection"
    ACTION_FLAG="--no-disable-api-termination"
fi

echo "⚠️  About to $ACTION_DESC for ${#INSTANCES[@]} instance(s)."
echo "Continue? (y/N): "
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled by user"
    exit 0
fi

echo

# Process each instance
SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILED_INSTANCES=()

for instance in "${INSTANCES[@]}"; do
    echo "🔄 Processing instance: $instance"
    
    # Check if instance exists
    if ! aws ec2 describe-instances --instance-ids "$instance" &> /dev/null; then
        echo "   ❌ Instance not found or no permission"
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        FAILED_INSTANCES+=("$instance")
        continue
    fi
    
    # Apply the change
    if aws ec2 modify-instance-attribute --instance-id "$instance" $ACTION_FLAG &> /dev/null; then
        echo "   ✅ Successfully modified"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "   ❌ Failed to modify"
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        FAILED_INSTANCES+=("$instance")
    fi
done

echo

# Summary
echo "📊 Batch Operation Summary:"
echo "   ✅ Successful: $SUCCESS_COUNT"
echo "   ❌ Failed: $FAILURE_COUNT"

if [[ $FAILURE_COUNT -gt 0 ]]; then
    echo
    echo "❌ Failed instances:"
    for failed_instance in "${FAILED_INSTANCES[@]}"; do
        echo "   • $failed_instance"
    done
fi

echo
echo "✅ Batch operation complete!"

# Verification option
if [[ $SUCCESS_COUNT -gt 0 ]]; then
    echo
    echo "🔍 Verify changes? (y/N): "
    read -r VERIFY
    
    if [[ "$VERIFY" =~ ^[Yy]$ ]]; then
        echo
        echo "📋 Verification Results:"
        for instance in "${INSTANCES[@]}"; do
            if [[ ! " ${FAILED_INSTANCES[@]} " =~ " ${instance} " ]]; then
                PROTECTION_STATUS=$(aws ec2 describe-instance-attribute --instance-id "$instance" --attribute disableApiTermination --query 'DisableApiTermination.Value' --output text 2>/dev/null || echo "ERROR")
                echo "   $instance: Termination Protection = $PROTECTION_STATUS"
            fi
        done
    fi
fi
