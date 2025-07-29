#!/bin/bash

# Test SSM connectivity for VPC peering demo instances
# This script checks if instances are ready for SSM Session Manager connections

set -e

echo "Testing SSM Connectivity for VPC Peering Demo"
echo "=============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    echo "❌ Please run this script from the terraform directory"
    exit 1
fi

# Check if infrastructure is deployed
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ No Terraform state found. Run 'terraform apply' first."
    exit 1
fi

# Get instance IDs
VPC_A_ID=$(terraform output -raw vpc_a_instance_id 2>/dev/null || echo "")
VPC_B_ID=$(terraform output -raw vpc_b_instance_id 2>/dev/null || echo "")

if [ -z "$VPC_A_ID" ] || [ -z "$VPC_B_ID" ]; then
    echo "❌ Could not get instance IDs from Terraform outputs"
    exit 1
fi

echo "Instance IDs:"
echo "VPC A: $VPC_A_ID"
echo "VPC B: $VPC_B_ID"
echo ""

# Function to check SSM connectivity
check_ssm_connectivity() {
    local instance_id=$1
    local vpc_name=$2
    
    echo "Checking $vpc_name instance ($instance_id)..."
    
    # Check if instance is registered with SSM
    local ssm_info=$(aws ssm describe-instance-information \
        --filters "Key=InstanceIds,Values=$instance_id" \
        --query 'InstanceInformationList[0]' \
        --output json 2>/dev/null || echo "null")
    
    if [ "$ssm_info" = "null" ]; then
        echo "  ❌ Instance not registered with SSM"
        return 1
    fi
    
    # Extract status information
    local ping_status=$(echo "$ssm_info" | jq -r '.PingStatus // "Unknown"')
    local last_ping=$(echo "$ssm_info" | jq -r '.LastPingDateTime // "Never"')
    local agent_version=$(echo "$ssm_info" | jq -r '.AgentVersion // "Unknown"')
    
    echo "  Status: $ping_status"
    echo "  Last Ping: $last_ping"
    echo "  Agent Version: $agent_version"
    
    if [ "$ping_status" = "Online" ]; then
        echo "  ✅ Ready for Session Manager connection"
        return 0
    else
        echo "  ⚠️  Not ready for Session Manager connection"
        return 1
    fi
}

# Check both instances
echo "SSM Connectivity Status:"
echo "========================"

vpc_a_ready=false
vpc_b_ready=false

if check_ssm_connectivity "$VPC_A_ID" "VPC A"; then
    vpc_a_ready=true
fi

echo ""

if check_ssm_connectivity "$VPC_B_ID" "VPC B"; then
    vpc_b_ready=true
fi

echo ""

# Summary and next steps
echo "Summary:"
echo "========"

if [ "$vpc_a_ready" = true ] && [ "$vpc_b_ready" = true ]; then
    echo "✅ Both instances are ready for SSM Session Manager connections!"
    echo ""
    echo "You can now connect using:"
    echo "  make connect-a  # Connect to VPC A instance"
    echo "  make connect-b  # Connect to VPC B instance"
    echo ""
    echo "Or use AWS CLI directly:"
    echo "  aws ssm start-session --target $VPC_A_ID"
    echo "  aws ssm start-session --target $VPC_B_ID"
elif [ "$vpc_a_ready" = true ] || [ "$vpc_b_ready" = true ]; then
    echo "⚠️  Some instances are ready, others may need more time"
    echo "Wait a few minutes and run this script again"
else
    echo "❌ No instances are ready for SSM connections yet"
    echo ""
    echo "This is normal immediately after deployment. Please wait 2-5 minutes"
    echo "for the instances to boot up and register with SSM, then try again."
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Verify instances are running: aws ec2 describe-instances --instance-ids $VPC_A_ID $VPC_B_ID"
    echo "2. Check NAT Gateways are available: aws ec2 describe-nat-gateways"
    echo "3. Verify IAM role permissions: terraform output iam_role_arn"
    echo "4. Check internet connectivity from instances via NAT Gateway"
fi

echo ""
echo "For more detailed status, run: make ssm-status"
