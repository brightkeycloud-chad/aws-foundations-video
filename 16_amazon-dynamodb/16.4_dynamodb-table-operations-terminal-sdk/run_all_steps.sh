#!/bin/bash

# Run All Steps - Complete DynamoDB Demonstration
# DynamoDB Table Operations Demo

set -e  # Exit on any error

echo "🎵 Complete DynamoDB CLI & SDK Demonstration"
echo "============================================"
echo

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to pause between steps
pause_between_steps() {
    echo
    echo -e "${YELLOW}Press Enter to continue to the next step, or Ctrl+C to exit...${NC}"
    read -r
    echo
}

# Function to run a step with error handling
run_step() {
    local step_script=$1
    local step_name=$2
    
    echo -e "${BLUE}Running $step_name...${NC}"
    echo "Script: $step_script"
    echo
    
    if [ -f "$step_script" ]; then
        if bash "$step_script"; then
            echo -e "${GREEN}✓ $step_name completed successfully${NC}"
        else
            echo -e "${RED}✗ $step_name failed${NC}"
            exit 1
        fi
    else
        echo -e "${RED}✗ Script not found: $step_script${NC}"
        exit 1
    fi
}

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}✗ AWS CLI not found. Please install AWS CLI first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo -e "${RED}✗ AWS credentials not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

# Check Python and boto3 for SDK demo
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠️  Python3 not found. SDK demonstration will be skipped.${NC}"
    SKIP_PYTHON=true
else
    if ! python3 -c "import boto3" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  boto3 not installed. SDK demonstration will be skipped.${NC}"
        echo "To install: pip install boto3"
        SKIP_PYTHON=true
    else
        SKIP_PYTHON=false
    fi
fi

echo -e "${GREEN}✓ Prerequisites check completed${NC}"
echo

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "This demonstration will run through all DynamoDB operations:"
echo "  1. Create table with AWS CLI"
echo "  2. Add items using CLI"
echo "  3. Query and get operations"
echo "  4. Update and delete operations"
if [ "$SKIP_PYTHON" = false ]; then
    echo "  5. Python SDK demonstration"
fi
echo "  6. Cleanup (optional)"
echo

echo -e "${YELLOW}The complete demonstration will take approximately 5-10 minutes.${NC}"
echo -e "${YELLOW}You can pause between steps to explain concepts.${NC}"
echo

read -p "Do you want to proceed with the complete demonstration? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${BLUE}Demonstration cancelled.${NC}"
    exit 0
fi

echo -e "${GREEN}Starting complete DynamoDB demonstration...${NC}"
echo

# Step 1: Create Table
run_step "$SCRIPT_DIR/step1_create_table.sh" "Step 1: Create Table"
pause_between_steps

# Step 2: Add Items
run_step "$SCRIPT_DIR/step2_add_items.sh" "Step 2: Add Items"
pause_between_steps

# Step 3: Query Operations
run_step "$SCRIPT_DIR/step3_query_operations.sh" "Step 3: Query Operations"
pause_between_steps

# Step 4: Update and Delete
run_step "$SCRIPT_DIR/step4_update_delete.sh" "Step 4: Update and Delete Operations"

# Step 5: Python SDK (if available)
if [ "$SKIP_PYTHON" = false ]; then
    pause_between_steps
    echo -e "${BLUE}Running Step 5: Python SDK Demonstration...${NC}"
    echo "Script: step5_python_sdk_demo.py"
    echo
    
    if python3 "$SCRIPT_DIR/step5_python_sdk_demo.py"; then
        echo -e "${GREEN}✓ Step 5: Python SDK Demonstration completed successfully${NC}"
    else
        echo -e "${RED}✗ Step 5: Python SDK Demonstration failed${NC}"
        exit 1
    fi
fi

echo
echo -e "${GREEN}🎉 Complete demonstration finished successfully!${NC}"
echo

# Ask about cleanup
echo -e "${YELLOW}Would you like to clean up the resources (delete the Music table)?${NC}"
echo "This will remove all data and stop any ongoing charges."
echo

read -p "Clean up resources? (yes/no): " -r
echo

if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    run_step "$SCRIPT_DIR/cleanup.sh" "Cleanup"
    echo
    echo -e "${GREEN}Demonstration completed with cleanup! 🧹${NC}"
else
    echo -e "${BLUE}Resources preserved. Remember to clean up manually later to avoid charges.${NC}"
    echo "To clean up later, run: ./cleanup.sh"
fi

echo
echo "Demonstration Summary:"
echo "======================"
echo "✓ Created DynamoDB table with partition and sort keys"
echo "✓ Added items with different attributes (schema flexibility)"
echo "✓ Performed query operations (efficient data retrieval)"
echo "✓ Demonstrated scan operations (less efficient)"
echo "✓ Updated items with SET and ADD expressions"
echo "✓ Used conditional updates"
echo "✓ Deleted items"
if [ "$SKIP_PYTHON" = false ]; then
    echo "✓ Showed Python SDK usage with boto3"
    echo "✓ Demonstrated batch operations"
fi
echo
echo "Key Learning Points:"
echo "• DynamoDB is a NoSQL database with flexible schema"
echo "• Query operations are more efficient than Scan"
echo "• Update expressions allow atomic modifications"
echo "• Conditional expressions prevent unwanted changes"
echo "• SDK provides more intuitive programming interface"
echo "• Proper error handling is essential"
echo
echo "Thank you for running the DynamoDB demonstration! 🎵"
