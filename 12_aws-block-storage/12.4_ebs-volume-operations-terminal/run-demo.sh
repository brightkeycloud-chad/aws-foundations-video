#!/bin/bash

# run-demo.sh
# Master script to run the complete EBS volume operations demonstration
# Part of AWS Foundations Training - EBS Volume Operations

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${CYAN}=================================================="
    echo -e "$1"
    echo -e "==================================================${NC}"
}

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

# Configuration
DEMO_MODE="${DEMO_MODE:-interactive}"  # interactive or auto
INSTANCE_ID="${INSTANCE_ID}"

print_header "AWS EBS Volume Operations - Complete Demonstration"
echo

print_status "This demonstration will:"
echo "  1. Create an EBS volume"
echo "  2. Attach it to an EC2 instance"
echo "  3. Modify the volume (expand size)"
echo "  4. Detach the volume"
echo "  5. Clean up all resources"
echo

# Check prerequisites
print_status "Checking prerequisites..."

# Check if scripts exist
SCRIPTS=("01-create-volume.sh" "02a-attach-volume.sh" "02b-modify-volume.sh" "02c-detach-volume.sh" "03-cleanup.sh")
for script in "${SCRIPTS[@]}"; do
    if [ ! -f "./$script" ]; then
        print_error "Script not found: $script"
        exit 1
    fi
    if [ ! -x "./$script" ]; then
        print_error "Script not executable: $script"
        print_status "Run: chmod +x ./$script"
        exit 1
    fi
done

print_success "All required scripts found and executable"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured"
    exit 1
fi

print_success "AWS CLI configured and credentials valid"

# Check for instance ID if running volume operations
if [ -n "$INSTANCE_ID" ]; then
    print_status "Using instance ID: $INSTANCE_ID"
else
    print_warning "INSTANCE_ID not set. Volume operations will prompt for it."
    print_status "To set it: export INSTANCE_ID=i-1234567890abcdef0"
    
    if [ "$DEMO_MODE" = "interactive" ]; then
        echo
        print_status "Available instances:"
        aws ec2 describe-instances \
            --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,Placement.AvailabilityZone]' \
            --output table
        
        echo
        read -p "Enter instance ID to use (or press Enter to skip volume operations): " USER_INSTANCE_ID
        if [ -n "$USER_INSTANCE_ID" ]; then
            export INSTANCE_ID="$USER_INSTANCE_ID"
            print_success "Using instance ID: $INSTANCE_ID"
        fi
    fi
fi

echo
print_header "PHASE 1: VOLUME CREATION"

if [ "$DEMO_MODE" = "interactive" ]; then
    read -p "Press Enter to create EBS volume..."
fi

./01-create-volume.sh

if [ $? -ne 0 ]; then
    print_error "Volume creation failed"
    exit 1
fi

echo
print_header "PHASE 2: VOLUME OPERATIONS"

if [ -n "$INSTANCE_ID" ]; then
    # Phase 2a: Attach Volume
    print_status "Step 2a: Attaching volume to instance..."
    if [ "$DEMO_MODE" = "interactive" ]; then
        read -p "Press Enter to attach volume to instance..."
    fi
    
    ./02a-attach-volume.sh
    
    if [ $? -ne 0 ]; then
        print_error "Volume attachment failed"
        print_warning "You may need to run cleanup manually"
        exit 1
    fi
    
    # Phase 2b: Modify Volume
    echo
    print_status "Step 2b: Modifying volume (expanding size)..."
    if [ "$DEMO_MODE" = "interactive" ]; then
        read -p "Press Enter to modify volume size..."
    fi
    
    ./02b-modify-volume.sh
    
    if [ $? -ne 0 ]; then
        print_error "Volume modification failed"
        print_warning "Volume may still be attached - check before cleanup"
    fi
    
    # Phase 2c: Detach Volume
    echo
    print_status "Step 2c: Detaching volume from instance..."
    if [ "$DEMO_MODE" = "interactive" ]; then
        read -p "Press Enter to detach volume..."
    fi
    
    ./02c-detach-volume.sh
    
    if [ $? -ne 0 ]; then
        print_error "Volume detachment failed"
        print_warning "You may need to run cleanup manually"
        exit 1
    fi
    
else
    print_warning "Skipping volume operations (no instance ID provided)"
    print_status "The volume has been created and is ready for manual operations"
    print_status "Available operation scripts:"
    echo "  • ./02a-attach-volume.sh - Attach volume to instance"
    echo "  • ./02b-modify-volume.sh - Modify volume properties"
    echo "  • ./02c-detach-volume.sh - Detach volume from instance"
fi

echo
print_header "PHASE 3: CLEANUP"

if [ "$DEMO_MODE" = "interactive" ]; then
    echo
    print_warning "The cleanup phase will delete the created volume"
    read -p "Continue with cleanup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleanup skipped. Remember to clean up manually to avoid charges!"
        print_status "Run: ./03-cleanup.sh"
        exit 0
    fi
fi

./03-cleanup.sh

if [ $? -ne 0 ]; then
    print_error "Cleanup failed"
    print_warning "You may have resources that need manual cleanup"
    exit 1
fi

echo
print_header "DEMONSTRATION COMPLETE"
print_success "All phases completed successfully!"
print_status "The EBS volume demonstration is now complete."
echo

# Show final summary
print_status "What was demonstrated:"
echo "  ✓ EBS volume creation with proper tagging"
if [ -n "$INSTANCE_ID" ]; then
    echo "  ✓ Volume attachment to EC2 instance"
    echo "  ✓ Volume modification (size expansion)"
    echo "  ✓ Volume detachment from instance"
fi
echo "  ✓ Resource cleanup and cost management"
echo

print_status "Key learning points:"
echo "  • Volumes must be in the same AZ as target instances"
echo "  • Volume modifications can be done while attached"
echo "  • Proper unmounting prevents data corruption during detachment"
echo "  • Proper cleanup prevents unnecessary charges"
echo "  • Tagging helps with resource management"
echo

print_status "Individual scripts available for specific operations:"
echo "  • 01-create-volume.sh - Create new EBS volumes"
echo "  • 02a-attach-volume.sh - Attach volumes to instances"
echo "  • 02b-modify-volume.sh - Modify volume properties"
echo "  • 02c-detach-volume.sh - Safely detach volumes"
echo "  • 03-cleanup.sh - Clean up resources"
echo

print_success "Thank you for completing the AWS EBS Volume Operations demonstration!"
