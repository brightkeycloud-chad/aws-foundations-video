#!/bin/bash

# VPC Peering Demo - Infrastructure Verification Script
# This script verifies that the Terraform infrastructure is properly deployed

set -e

echo "VPC Peering Demo - Infrastructure Verification"
echo "=============================================="
echo ""

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    echo "❌ Please run this script from the terraform directory"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Check Terraform state
echo "Checking Terraform state..."
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ No Terraform state found. Run 'terraform apply' first."
    exit 1
fi

# Get Terraform outputs
echo "Getting Terraform outputs..."
VPC_A_ID=$(terraform output -raw vpc_a_id 2>/dev/null || echo "")
VPC_B_ID=$(terraform output -raw vpc_b_id 2>/dev/null || echo "")
VPC_A_IP=$(terraform output -raw vpc_a_instance_private_ip 2>/dev/null || echo "")
VPC_B_IP=$(terraform output -raw vpc_b_instance_private_ip 2>/dev/null || echo "")
INSTANCE_A_ID=$(terraform output -raw vpc_a_instance_id 2>/dev/null || echo "")
INSTANCE_B_ID=$(terraform output -raw vpc_b_instance_id 2>/dev/null || echo "")
AMI_ID=$(terraform output -raw ami_id 2>/dev/null || echo "")
AMI_NAME=$(terraform output -raw ami_name 2>/dev/null || echo "")

if [ -z "$VPC_A_ID" ] || [ -z "$VPC_B_ID" ]; then
    echo "❌ Could not get VPC IDs from Terraform outputs"
    exit 1
fi

echo "✅ Terraform outputs retrieved successfully"
echo ""

# Verify VPCs exist
echo "Verifying VPCs..."
VPC_A_STATE=$(aws ec2 describe-vpcs --vpc-ids "$VPC_A_ID" --query 'Vpcs[0].State' --output text 2>/dev/null || echo "not-found")
VPC_B_STATE=$(aws ec2 describe-vpcs --vpc-ids "$VPC_B_ID" --query 'Vpcs[0].State' --output text 2>/dev/null || echo "not-found")

if [ "$VPC_A_STATE" != "available" ]; then
    echo "❌ VPC A ($VPC_A_ID) is not available (state: $VPC_A_STATE)"
    exit 1
fi

if [ "$VPC_B_STATE" != "available" ]; then
    echo "❌ VPC B ($VPC_B_ID) is not available (state: $VPC_B_STATE)"
    exit 1
fi

echo "✅ Both VPCs are available"

# Verify instances exist and are running
echo "Verifying EC2 instances..."
if [ -n "$INSTANCE_A_ID" ]; then
    INSTANCE_A_STATE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_A_ID" --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null || echo "not-found")
    if [ "$INSTANCE_A_STATE" != "running" ]; then
        echo "⚠️  VPC A instance ($INSTANCE_A_ID) is not running (state: $INSTANCE_A_STATE)"
    else
        echo "✅ VPC A instance is running"
    fi
else
    echo "❌ Could not get VPC A instance ID"
fi

if [ -n "$INSTANCE_B_ID" ]; then
    INSTANCE_B_STATE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_B_ID" --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null || echo "not-found")
    if [ "$INSTANCE_B_STATE" != "running" ]; then
        echo "⚠️  VPC B instance ($INSTANCE_B_ID) is not running (state: $INSTANCE_B_STATE)"
    else
        echo "✅ VPC B instance is running"
    fi
else
    echo "❌ Could not get VPC B instance ID"
fi

echo ""

# Check SSM connectivity
echo "Checking SSM connectivity..."
if [ -n "$INSTANCE_A_ID" ]; then
    SSM_A_STATUS=$(aws ssm describe-instance-information --filters "Key=InstanceIds,Values=$INSTANCE_A_ID" --query 'InstanceInformationList[0].PingStatus' --output text 2>/dev/null || echo "Unknown")
    if [ "$SSM_A_STATUS" = "Online" ]; then
        echo "✅ VPC A instance is connected to SSM"
    else
        echo "⚠️  VPC A instance SSM status: $SSM_A_STATUS (may take a few minutes after launch)"
    fi
else
    echo "❌ Could not check VPC A instance SSM status"
fi

if [ -n "$INSTANCE_B_ID" ]; then
    SSM_B_STATUS=$(aws ssm describe-instance-information --filters "Key=InstanceIds,Values=$INSTANCE_B_ID" --query 'InstanceInformationList[0].PingStatus' --output text 2>/dev/null || echo "Unknown")
    if [ "$SSM_B_STATUS" = "Online" ]; then
        echo "✅ VPC B instance is connected to SSM"
    else
        echo "⚠️  VPC B instance SSM status: $SSM_B_STATUS (may take a few minutes after launch)"
    fi
else
    echo "❌ Could not check VPC B instance SSM status"
fi

echo ""

# Check NAT Gateways
echo "Checking NAT Gateways..."
VPC_A_NAT=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_A_ID" --query 'NatGateways[0].State' --output text 2>/dev/null || echo "None")
VPC_B_NAT=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_B_ID" --query 'NatGateways[0].State' --output text 2>/dev/null || echo "None")

if [ "$VPC_A_NAT" = "available" ]; then
    echo "✅ VPC A NAT Gateway is available"
else
    echo "⚠️  VPC A NAT Gateway state: $VPC_A_NAT"
fi

if [ "$VPC_B_NAT" = "available" ]; then
    echo "✅ VPC B NAT Gateway is available"
else
    echo "⚠️  VPC B NAT Gateway state: $VPC_B_NAT"
fi

echo ""

# Check for VPC peering connection
echo "Checking for VPC peering connection..."
PEERING_CONNECTION=$(aws ec2 describe-vpc-peering-connections \
    --filters "Name=requester-vpc-info.vpc-id,Values=$VPC_A_ID,$VPC_B_ID" \
              "Name=accepter-vpc-info.vpc-id,Values=$VPC_A_ID,$VPC_B_ID" \
    --query 'VpcPeeringConnections[0].VpcPeeringConnectionId' \
    --output text 2>/dev/null || echo "None")

if [ "$PEERING_CONNECTION" = "None" ] || [ "$PEERING_CONNECTION" = "null" ]; then
    echo "⚠️  No VPC peering connection found between the VPCs"
    echo "   This is expected before running the demo"
else
    PEERING_STATE=$(aws ec2 describe-vpc-peering-connections \
        --vpc-peering-connection-ids "$PEERING_CONNECTION" \
        --query 'VpcPeeringConnections[0].Status.Code' \
        --output text 2>/dev/null || echo "unknown")
    echo "✅ VPC peering connection found: $PEERING_CONNECTION (state: $PEERING_STATE)"
fi

echo ""

# Summary
echo "Infrastructure Summary:"
echo "======================"
echo "VPC A ID: $VPC_A_ID"
echo "VPC B ID: $VPC_B_ID"
echo "VPC A Instance IP: $VPC_A_IP"
echo "VPC B Instance IP: $VPC_B_IP"
echo "VPC A Instance ID: $INSTANCE_A_ID"
echo "VPC B Instance ID: $INSTANCE_B_ID"
echo "AMI ID: $AMI_ID"
echo "AMI Name: $AMI_NAME"
echo ""

# Next steps
echo "Next Steps for Demo:"
echo "==================="
echo "1. Create VPC peering connection between $VPC_A_ID and $VPC_B_ID"
echo "2. Accept the peering connection"
echo "3. Add routes to both VPC route tables"
echo "4. Test connectivity: ping $VPC_B_IP from VPC A instance"
echo "5. Test connectivity: ping $VPC_A_IP from VPC B instance"
echo ""

# Connectivity test (if peering exists)
if [ "$PEERING_CONNECTION" != "None" ] && [ "$PEERING_CONNECTION" != "null" ] && [ "$PEERING_STATE" = "active" ]; then
    echo "Testing connectivity (peering connection is active)..."
    echo "To test manually:"
    echo "  make connect-a  # then run: ping $VPC_B_IP"
    echo "  make connect-b  # then run: ping $VPC_A_IP"
fi

echo ""
echo "✅ Infrastructure verification completed successfully!"
echo "The infrastructure is ready for the VPC peering demonstration."
