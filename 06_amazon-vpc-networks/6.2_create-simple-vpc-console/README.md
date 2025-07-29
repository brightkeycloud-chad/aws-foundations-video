# Create a Simple VPC Using AWS Console

## Demonstration Overview
This 5-minute demonstration shows how to create a simple Virtual Private Cloud (VPC) using the AWS Management Console. You'll learn to set up a basic VPC with public and private subnets, internet gateway, and NAT gateway for a typical web application architecture.

## Prerequisites
- AWS account with appropriate permissions to create VPC resources
- Access to AWS Management Console
- Basic understanding of networking concepts (CIDR blocks, subnets)

## Demonstration Steps

### Step 1: Access the VPC Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to the VPC service by:
   - Searching for "VPC" in the services search bar, OR
   - Going to **Services** > **Networking & Content Delivery** > **VPC**
3. Ensure you're in the correct AWS region (check top-right corner)

### Step 2: Initiate VPC Creation (30 seconds)
1. On the VPC dashboard, click **Create VPC**
2. Select **VPC and more** (this creates a VPC with additional resources)
3. Keep **Name tag auto-generation** selected for automatic naming

### Step 3: Configure Basic VPC Settings (1 minute)
1. **IPv4 CIDR block**: Enter `10.0.0.0/16`
   - This provides 65,536 IP addresses for your VPC
2. **IPv6 CIDR block**: Leave as "No IPv6 CIDR block" for simplicity
3. **Tenancy**: Keep as "Default" (shared hardware)

### Step 4: Configure Availability Zones and Subnets (1.5 minutes)
1. **Number of Availability Zones**: Select **2** (recommended for production)
2. **Number of public subnets**: Select **2**
3. **Number of private subnets**: Select **2**
4. Leave subnet CIDR blocks as default:
   - Public subnets: `10.0.1.0/24` and `10.0.2.0/24`
   - Private subnets: `10.0.3.0/24` and `10.0.4.0/24`

### Step 5: Configure Internet Access (1 minute)
1. **NAT gateways**: Select **1 per AZ** (for high availability)
   - This allows private subnet resources to access the internet
2. **VPC endpoints**: Select **S3 Gateway** if you plan to use S3
   - This provides direct access to S3 without internet routing
3. **DNS options**: Keep both options enabled:
   - Enable DNS hostnames
   - Enable DNS resolution

### Step 6: Review and Create (1 minute)
1. Review the **Preview** pane showing your VPC architecture
   - Solid lines show resource relationships
   - Dotted lines show network traffic paths
2. Optionally add tags under **Additional tags**
3. Click **Create VPC**
4. Wait for creation to complete (typically 2-3 minutes)

### Step 7: Verify Creation (30 seconds)
1. Once complete, click **View VPC** to see your new VPC
2. Navigate to **Resource map** tab to visualize your VPC resources
3. Note the automatically created resources:
   - Internet Gateway
   - Route Tables (public and private)
   - NAT Gateways
   - Subnets in multiple AZs

## Key Learning Points
- **VPC CIDR Planning**: Choose non-overlapping CIDR blocks for future connectivity
- **Multi-AZ Design**: Always use multiple Availability Zones for high availability
- **Public vs Private Subnets**: Public subnets have direct internet access, private subnets use NAT gateways
- **Cost Considerations**: NAT gateways incur hourly charges and data processing fees

## Next Steps
After creating your VPC, you can:
- Launch EC2 instances in the subnets
- Configure security groups and NACLs
- Set up VPC peering or VPN connections
- Create additional VPC endpoints for other AWS services

## Troubleshooting
- **CIDR Overlap Error**: Ensure your CIDR block doesn't overlap with existing VPCs
- **Resource Limits**: Check your account limits if creation fails
- **Permission Issues**: Verify you have the necessary IAM permissions for VPC creation

## Cost Estimate
- VPC itself: Free
- NAT Gateway: ~$45/month per gateway + data processing charges
- VPC Endpoints: ~$7.20/month per endpoint + data processing charges

## Citations and Documentation

This demonstration is based on the following AWS documentation:

1. **Configure a virtual private cloud** - AWS VPC User Guide  
   https://docs.aws.amazon.com/vpc/latest/userguide/configure-your-vpc.html

2. **Create a VPC** - AWS VPC User Guide  
   https://docs.aws.amazon.com/vpc/latest/userguide/create-vpc.html

3. **VPC Tutorials** - AWS VPC User Guide  
   https://docs.aws.amazon.com/vpc/latest/userguide/vpc-tutorials-intro.html

4. **What is Amazon VPC?** - AWS VPC User Guide  
   https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html

For the most current information and detailed technical specifications, always refer to the official AWS documentation at https://docs.aws.amazon.com/vpc/.
