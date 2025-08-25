#!/bin/bash

# Test script to verify all demo scripts are working correctly
# This script performs basic syntax and dependency checks

echo "=== EC2 Instance Attributes Demo - Script Verification ==="
echo

# Check if we're in the right directory
if [[ ! -d "scripts" ]]; then
    echo "❌ Error: scripts directory not found."
    echo "Please run this script from the demo root directory."
    exit 1
fi

echo "🔍 Checking script syntax and dependencies..."
echo

# List of scripts to check
SCRIPTS=(
    "run-demo.sh"
    "scripts/setup.sh"
    "scripts/view-attributes.sh"
    "scripts/modify-termination-protection.sh"
    "scripts/modify-source-dest-check.sh"
    "scripts/modify-imds-settings.sh"
    "scripts/modify-instance-type.sh"
    "scripts/cleanup.sh"
    "scripts/batch-operations.sh"
)

# Check each script
for script in "${SCRIPTS[@]}"; do
    echo -n "Checking $script... "
    
    # Check if file exists
    if [[ ! -f "$script" ]]; then
        echo "❌ File not found"
        continue
    fi
    
    # Check if file is executable
    if [[ ! -x "$script" ]]; then
        echo "⚠️  Not executable (fixing...)"
        chmod +x "$script"
    fi
    
    # Check syntax
    if bash -n "$script" 2>/dev/null; then
        echo "✅ OK"
    else
        echo "❌ Syntax error"
    fi
done

echo
echo "🔧 Checking AWS CLI availability..."
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI is installed"
    
    # Check if AWS CLI is configured (basic check)
    if aws sts get-caller-identity &> /dev/null; then
        echo "✅ AWS CLI appears to be configured"
    else
        echo "⚠️  AWS CLI may not be configured (run 'aws configure')"
    fi
else
    echo "❌ AWS CLI is not installed"
    echo "   Install from: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
fi

echo
echo "📋 Demo Usage Instructions:"
echo "1. Run the complete interactive demo:"
echo "   ./run-demo.sh"
echo
echo "2. Or run individual scripts:"
echo "   ./scripts/setup.sh"
echo "   export INSTANCE_ID=your-instance-id"
echo "   ./scripts/view-attributes.sh"
echo "   # ... other scripts"
echo
echo "3. For batch operations:"
echo "   ./scripts/batch-operations.sh --help"
echo
echo "✅ Script verification complete!"
