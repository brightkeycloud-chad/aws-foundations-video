#!/bin/bash

# EC2 Instance Attributes Demo - Master Script
# This script runs the complete demonstration with user interaction

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print section headers
print_header() {
    echo
    print_color $BLUE "=============================================="
    print_color $BLUE "$1"
    print_color $BLUE "=============================================="
    echo
}

# Function to wait for user input
wait_for_user() {
    local message=${1:-"Press Enter to continue..."}
    print_color $YELLOW "$message"
    read -r
}

# Main demo function
main() {
    print_header "EC2 Instance Attributes Modification Demo"
    
    echo "This demonstration will show you how to modify various EC2 instance attributes"
    echo "using AWS CLI commands through automated scripts."
    echo
    echo "The demo includes:"
    echo "• Setup and verification"
    echo "• Viewing current instance attributes"
    echo "• Modifying termination protection"
    echo "• Modifying source/destination check"
    echo "• Modifying IMDS (Instance Metadata Service) settings"
    echo "• Modifying instance type (optional)"
    echo "• Cleanup"
    echo
    
    wait_for_user "Press Enter to start the demo..."
    
    # Step 1: Setup
    print_header "Step 1: Setup and Verification"
    echo "Running setup script to verify AWS CLI and list instances..."
    ./scripts/setup.sh
    
    echo
    print_color $YELLOW "Please set your INSTANCE_ID environment variable now:"
    print_color $YELLOW "export INSTANCE_ID=your-instance-id-here"
    echo
    wait_for_user "After setting INSTANCE_ID, press Enter to continue..."
    
    # Verify INSTANCE_ID is set
    if [[ -z "$INSTANCE_ID" ]]; then
        print_color $RED "❌ INSTANCE_ID is not set. Please set it and run the demo again."
        exit 1
    fi
    
    print_color $GREEN "✅ Using instance: $INSTANCE_ID"
    
    # Step 2: View current attributes
    print_header "Step 2: View Current Instance Attributes"
    echo "Let's examine the current state of your instance attributes..."
    wait_for_user
    ./scripts/view-attributes.sh
    wait_for_user "Review the current attributes, then press Enter to continue..."
    
    # Step 3: Termination protection
    print_header "Step 3: Modify Termination Protection"
    echo "This demonstration will enable and then disable termination protection."
    wait_for_user "Press Enter to start the termination protection demo..."
    ./scripts/modify-termination-protection.sh
    wait_for_user "Termination protection demo complete. Press Enter to continue..."
    
    # Step 4: Source/destination check
    print_header "Step 4: Modify Source/Destination Check"
    echo "This demonstration will disable and then re-enable source/destination checking."
    wait_for_user "Press Enter to start the source/destination check demo..."
    ./scripts/modify-source-dest-check.sh
    wait_for_user "Source/destination check demo complete. Press Enter to continue..."
    
    # Step 5: IMDS settings
    print_header "Step 5: Modify IMDS Settings"
    echo "This demonstration will show how to configure Instance Metadata Service (IMDS) security settings."
    wait_for_user "Press Enter to start the IMDS settings demo..."
    ./scripts/modify-imds-settings.sh
    wait_for_user "IMDS settings demo complete. Press Enter to continue..."
    
    # Step 6: Instance type (optional)
    print_header "Step 6: Modify Instance Type (Optional)"
    echo "⚠️  WARNING: This step will stop and restart your instance!"
    echo "This may cause temporary service interruption."
    echo
    print_color $YELLOW "Do you want to demonstrate instance type modification? (y/N): "
    read -r INSTANCE_TYPE_DEMO
    
    if [[ "$INSTANCE_TYPE_DEMO" =~ ^[Yy]$ ]]; then
        ./scripts/modify-instance-type.sh
        wait_for_user "Instance type demo complete. Press Enter to continue..."
    else
        print_color $YELLOW "⏭️  Skipping instance type modification demo."
    fi
    
    # Step 7: Cleanup
    print_header "Step 7: Cleanup"
    echo "Let's reset all the changes we made during this demonstration."
    wait_for_user "Press Enter to run cleanup..."
    ./scripts/cleanup.sh
    
    # Final summary
    print_header "Demo Complete!"
    print_color $GREEN "🎉 Congratulations! You have successfully completed the EC2 Instance Attributes demo."
    echo
    echo "What you learned:"
    echo "• How to view current instance attributes"
    echo "• How to modify termination protection"
    echo "• How to modify source/destination checking"
    echo "• How to configure IMDS security settings"
    if [[ "$INSTANCE_TYPE_DEMO" =~ ^[Yy]$ ]]; then
        echo "• How to change instance types"
    fi
    echo "• How to clean up changes"
    echo
    echo "Additional scripts available:"
    echo "• ./scripts/batch-operations.sh - Modify multiple instances at once"
    echo "• Individual scripts can be run separately as needed"
    echo
    print_color $GREEN "✅ Demo completed successfully!"
}

# Check if we're in the right directory
if [[ ! -d "scripts" ]]; then
    print_color $RED "❌ Error: scripts directory not found."
    print_color $RED "Please run this script from the demo root directory."
    exit 1
fi

# Make sure all scripts are executable
chmod +x scripts/*.sh

# Run the main demo
main
