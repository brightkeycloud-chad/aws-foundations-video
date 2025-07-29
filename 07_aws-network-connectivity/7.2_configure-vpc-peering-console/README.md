# VPC Peering Configuration Demonstration (Console)

## Overview
This 5-minute demonstration shows how to configure VPC peering connections using the AWS Management Console. VPC peering allows you to connect two VPCs privately, enabling resources in different VPCs to communicate as if they were within the same network.

## Learning Objectives
By the end of this demonstration, participants will understand:
- What VPC peering is and when to use it
- How to create a VPC peering connection
- How to configure route tables for peered VPCs
- How to test connectivity between peered VPCs

## Infrastructure Setup

### Option 1: Terraform (Recommended)
The `terraform/` directory contains a complete infrastructure setup that creates:
- Two VPCs with non-overlapping CIDR blocks (10.0.0.0/16 and 10.1.0.0/16)
- Public and private subnets in each VPC
- NAT Gateways for internet access from private subnets
- EC2 instances in private subnets for testing
- Security groups configured for cross-VPC communication
- Automatic AMI selection (latest Amazon Linux 2023 ARM64 for any region)
- IAM roles for SSM Session Manager access (via NAT Gateway)

**Quick Start with Terraform:**
```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Optionally modify aws_region in terraform.tfvars (defaults to us-west-2)
terraform init
terraform apply
```

See the [Terraform README](terraform/README.md) for detailed instructions.

### Option 2: Manual Setup
If not using Terraform, ensure you have:
- Two VPCs with non-overlapping CIDR blocks
- At least one EC2 instance in each VPC
- Security groups configured to allow ICMP (ping) traffic
- Basic understanding of VPC concepts

## Prerequisites
- AWS account with appropriate permissions
- Two existing VPCs with non-overlapping CIDR blocks (if not using Terraform)
- At least one EC2 instance in each VPC for testing (if not using Terraform)
- Basic understanding of VPC concepts

## Demonstration Script (5 minutes)

### Introduction (30 seconds)
"Today we'll demonstrate how to create a VPC peering connection using the AWS Console. VPC peering enables private communication between two VPCs, whether they're in the same region or different regions, and in the same account or different accounts."

### Step 1: Create VPC Peering Connection (2 minutes)

1. **Navigate to VPC Console**
   - Open the AWS Management Console
   - Navigate to VPC service
   - In the left navigation pane, click **Peering connections**

2. **Create Peering Connection**
   - Click **Create peering connection**
   - Enter a **Name** (e.g., "Demo-VPC-Peering")
   - For **VPC ID (Requester)**, select your first VPC
   - Under **Select another VPC to peer with**:
     - Keep **My account** selected
     - Keep **This Region** selected
     - For **VPC ID (Accepter)**, select your second VPC
   - Click **Create peering connection**

3. **Accept Peering Connection**
   - The connection will be in "Pending Acceptance" state
   - Select the peering connection
   - Click **Actions** → **Accept request**
   - Click **Accept request** to confirm

### Step 2: Configure Route Tables (2 minutes)

1. **Update First VPC Route Table**
   - Navigate to **Route Tables** in the VPC console
   - Select the route table associated with your first VPC's subnet
   - Click the **Routes** tab
   - Click **Edit routes**
   - Click **Add route**
   - For **Destination**, enter the CIDR block of the second VPC (e.g., 10.1.0.0/16)
   - For **Target**, select **Peering Connection** and choose your peering connection
   - Click **Save changes**

2. **Update Second VPC Route Table**
   - Select the route table associated with your second VPC's subnet
   - Click the **Routes** tab
   - Click **Edit routes**
   - Click **Add route**
   - For **Destination**, enter the CIDR block of the first VPC (e.g., 10.0.0.0/16)
   - For **Target**, select **Peering Connection** and choose your peering connection
   - Click **Save changes**

### Step 3: Test Connectivity (30 seconds)

1. **Test Connection**
   - Connect to an EC2 instance in the first VPC using SSM Session Manager
   - Ping the private IP address of an instance in the second VPC
   - Demonstrate successful connectivity

**If using Terraform infrastructure:**
```bash
# Get instance IPs
terraform output vpc_a_instance_private_ip
terraform output vpc_b_instance_private_ip

# Connect to instances via SSM Session Manager
make connect-a  # or make connect-b

# Check SSM connectivity status
make ssm-status
```

### Wrap-up (30 seconds)
"We've successfully created a VPC peering connection and configured routing to enable private communication between two VPCs. This setup allows resources in both VPCs to communicate securely without traversing the public internet."

## Key Points to Emphasize

- **CIDR Block Requirements**: VPCs must have non-overlapping CIDR blocks
- **Bidirectional Routing**: Route tables must be updated in both VPCs
- **Security Groups**: Ensure security groups allow the required traffic
- **Regional Considerations**: Peering can work across regions with additional considerations
- **Cost**: VPC peering has no additional charges for same-region connections

## Common Issues and Troubleshooting

1. **Connection Fails**: Check for overlapping CIDR blocks
2. **No Connectivity**: Verify route tables are configured correctly in both VPCs
3. **Partial Connectivity**: Check security group rules and NACLs
4. **DNS Resolution**: Enable DNS resolution for VPC peering if needed

## Cleanup Instructions

1. Delete routes from both VPC route tables
2. Delete the VPC peering connection
3. Terminate any test EC2 instances if no longer needed

## Additional Resources

For more detailed information, refer to the official AWS documentation:

- [Create a VPC peering connection](https://docs.aws.amazon.com/vpc/latest/peering/create-vpc-peering-connection.html)
- [Update your route tables for a VPC peering connection](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-routing.html)
- [What is VPC peering?](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html)
- [How VPC peering connections work](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html)

## Citations

1. Amazon Web Services. (2024). *Create a VPC peering connection - Amazon Virtual Private Cloud*. Retrieved from https://docs.aws.amazon.com/vpc/latest/peering/create-vpc-peering-connection.html

2. Amazon Web Services. (2024). *Update your route tables for a VPC peering connection - Amazon Virtual Private Cloud*. Retrieved from https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-routing.html

3. Amazon Web Services. (2024). *What is VPC peering? - Amazon Virtual Private Cloud*. Retrieved from https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html

4. Amazon Web Services. (2024). *How VPC peering connections work - Amazon Virtual Private Cloud*. Retrieved from https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html
