# VPC Peering Demo - Terraform Infrastructure

This Terraform configuration creates the infrastructure needed for the VPC peering demonstration, including two VPCs with public and private subnets, NAT gateways, and EC2 instances for testing connectivity.

## Architecture Overview

The infrastructure includes:
- **VPC A**: 10.0.0.0/16 CIDR block
- **VPC B**: 10.1.0.0/16 CIDR block
- Each VPC has:
  - 2 public subnets (in different AZs)
  - 2 private subnets (in different AZs)
  - 1 NAT Gateway (in primary AZ)
  - 1 Internet Gateway
  - Route tables configured for public/private subnet routing
- **EC2 Instances**:
  - 1 instance in each VPC's private subnet
  - Amazon Linux 2023 ARM64 architecture
  - t4g.micro instance type
  - Security groups configured to allow traffic from the other VPC

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **AWS permissions** to create VPCs, subnets, EC2 instances, security groups, etc.

## Quick Start

1. **Clone and navigate to the terraform directory**:
   ```bash
   cd terraform
   ```

2. **Copy the example variables file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit terraform.tfvars** if needed (optional):
   ```bash
   # Modify region, CIDR blocks, or other settings as needed
   vim terraform.tfvars
   ```

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Plan the deployment**:
   ```bash
   terraform plan
   ```

6. **Apply the configuration**:
   ```bash
   terraform apply
   ```

7. **Note the outputs** - you'll need the VPC IDs and instance IPs for the demo

## Configuration Details

### Region Configuration

The configuration defaults to **us-west-2** but can be deployed in any AWS region by modifying the `aws_region` variable in your `terraform.tfvars` file.

### AMI Selection

The configuration automatically selects the latest Amazon Linux 2023 ARM64 AMI for the specified region using a data source. This ensures compatibility across all AWS regions without hardcoding AMI IDs.

### VPC Module Configuration

The configuration uses the official [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) module with the following settings:

- **DNS support and hostnames**: Enabled for proper name resolution
- **NAT Gateway**: Single NAT Gateway per VPC (cost-optimized for demo)
- **Subnets**: Automatically calculated using `cidrsubnet()` function
- **Availability Zones**: Uses first 2 AZs in the region

### Security Groups

Each EC2 instance has a security group that allows:
- **All traffic** (TCP, UDP, ICMP) from the other VPC's CIDR block
- **SSH access** from within the same VPC
- **All outbound traffic**

### EC2 Instances

- **AMI**: Automatically selected latest Amazon Linux 2023 ARM64 for the region
- **Instance Type**: t4g.micro (ARM-based, free tier eligible)
- **Placement**: Private subnets for security
- **IAM Role**: Configured with SSM Session Manager permissions
- **User Data**: Installs networking tools and creates a simple web server
- **Internet Access**: Uses NAT Gateway for outbound connectivity (including SSM)

### SSM Session Manager Setup

The configuration includes:
- **IAM Role**: EC2 instances have the `AmazonSSMManagedInstanceCore` policy
- **NAT Gateway**: Provides internet access for SSM service communication
- **No VPC Endpoints**: Instances use NAT Gateway for cost optimization

## Outputs

After deployment, Terraform provides useful outputs including:

```bash
# View all outputs
terraform output

# View specific output
terraform output demo_information
```

Key outputs include:
- VPC IDs for both VPCs
- CIDR blocks
- Instance private IP addresses
- Security group IDs
- Next steps for the VPC peering demo

## Testing the Infrastructure

### 1. Verify Instances are Running

```bash
# Get instance IDs
terraform output vpc_a_instance_id
terraform output vpc_b_instance_id

# Check instance status
aws ec2 describe-instances --instance-ids $(terraform output -raw vpc_a_instance_id)
```

### 2. Connect to Instances

```bash
# Connect via Session Manager (recommended - no SSH keys needed)
make connect-a  # Connect to VPC A instance
make connect-b  # Connect to VPC B instance

# Or use AWS CLI directly
aws ssm start-session --target $(terraform output -raw vpc_a_instance_id)

# Check SSM connectivity status
make ssm-status
```

### 3. Test Initial Connectivity (should fail before peering)

From VPC A instance:
```bash
ping $(terraform output -raw vpc_b_instance_private_ip)
# This should fail - no route to VPC B
```

## VPC Peering Demo Steps

After the infrastructure is deployed, follow these steps for the demonstration:

### 1. Create VPC Peering Connection
- Use the VPC IDs from terraform outputs
- Create peering connection in AWS Console
- Accept the peering connection

### 2. Update Route Tables
- Add routes in both VPCs pointing to the peering connection
- Use the CIDR blocks and route table IDs from terraform outputs

### 3. Test Connectivity
- Ping between instances using the private IP addresses
- Test the web server on port 8080

## Useful Commands

```bash
# Get demo information
terraform output demo_information

# Get AMI information
make ami-info
terraform output ami_id
terraform output ami_name

# Get instance private IPs
terraform output vpc_a_instance_private_ip
terraform output vpc_b_instance_private_ip

# Get VPC information
terraform output vpc_a_id
terraform output vpc_b_id

# Refresh outputs after changes
terraform refresh
```

## Cost Considerations

This infrastructure includes:
- **2 NAT Gateways**: ~$45/month each
- **2 t4g.micro instances**: Free tier eligible
- **Data transfer**: Minimal for demo purposes

**Total estimated cost**: ~$90/month if left running

**Cost optimization**: Uses NAT Gateway for SSM connectivity instead of VPC endpoints, reducing costs while maintaining functionality.

## Cleanup

To avoid ongoing charges, destroy the infrastructure when done:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **AMI not found**: The configuration automatically finds the latest AMI, but ensure Amazon Linux 2023 is available in your region
2. **Instance launch fails**: Check if t4g.micro is available in your region
3. **SSM connection fails**: Wait a few minutes after deployment for instances to register with SSM via NAT Gateway
4. **Permission denied**: Ensure your AWS credentials have sufficient permissions
5. **Resource limits**: Check AWS service quotas for VPCs, instances, etc.

### SSM Troubleshooting

```bash
# Check SSM connectivity status
make ssm-status

# Verify NAT Gateway is working
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$(terraform output -raw vpc_a_id)"

# Check instance SSM agent status (from within the instance)
sudo systemctl status amazon-ssm-agent
```

### Getting AMI Information

```bash
# Show AMI information used by Terraform
make ami-info

# Get latest AMI information directly from AWS
make get-ami
```

## File Structure

```
terraform/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── user_data.sh              # EC2 user data script
├── terraform.tfvars.example  # Example variables file
└── README.md                 # This file
```

## Security Notes

- Instances are placed in private subnets for security
- Security groups allow broad access between VPCs for demo purposes
- In production, use more restrictive security group rules
- Consider using AWS Systems Manager Session Manager for secure access
- The simple web server is for demo purposes only

## Next Steps

After deploying this infrastructure:
1. Follow the main VPC peering demonstration guide
2. Use the AWS Console to create and configure VPC peering
3. Test connectivity between the instances
4. Clean up resources when finished

For the complete demonstration guide, see the main README.md in the parent directory.
