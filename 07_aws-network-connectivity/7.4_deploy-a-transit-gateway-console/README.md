# AWS Transit Gateway Deployment Demonstration (Console)

## Overview
This 5-minute demonstration shows how to deploy and configure an AWS Transit Gateway using the AWS Management Console. Transit Gateway acts as a cloud router that simplifies network connectivity by providing a single gateway to connect multiple VPCs and on-premises networks.

## Learning Objectives
By the end of this demonstration, participants will understand:
- What AWS Transit Gateway is and its benefits
- How to create a Transit Gateway
- How to attach VPCs to a Transit Gateway
- How to configure routing for Transit Gateway connectivity
- How to test connectivity through the Transit Gateway

## Prerequisites
- AWS account with appropriate permissions
- Two existing VPCs with non-overlapping CIDR blocks
- At least one EC2 instance in each VPC for testing
- Basic understanding of VPC and routing concepts

## Demonstration Script (5 minutes)

### Introduction (30 seconds)
"Today we'll demonstrate how to deploy an AWS Transit Gateway using the console. Transit Gateway simplifies network architecture by acting as a hub that connects multiple VPCs, eliminating the need for complex peering relationships and providing centralized connectivity management."

### Step 1: Create Transit Gateway (1.5 minutes)

1. **Navigate to Transit Gateway Console**
   - Open the AWS Management Console
   - Navigate to VPC service
   - In the left navigation pane, click **Transit Gateways**

2. **Create Transit Gateway**
   - Click **Create transit gateway**
   - Enter a **Name tag** (e.g., "Demo-Transit-Gateway")
   - Enter a **Description** (e.g., "Demo Transit Gateway for VPC connectivity")
   - In **Configure the transit gateway** section:
     - Keep default **Amazon side ASN** (64512)
     - Ensure **DNS support** is enabled
     - Keep **Default route table association** enabled
     - Keep **Default route table propagation** enabled
   - Leave other settings as default
   - Click **Create transit gateway**

3. **Wait for Availability**
   - The Transit Gateway will show as "Pending" initially
   - Wait for the state to change to "Available" (this may take a few minutes)

### Step 2: Attach VPCs to Transit Gateway (2 minutes)

1. **Create First VPC Attachment**
   - Navigate to **Transit Gateway Attachments**
   - Click **Create transit gateway attachment**
   - Enter a **Name tag** (e.g., "VPC-A-Attachment")
   - For **Transit gateway ID**, select your Transit Gateway
   - For **Attachment type**, select **VPC**
   - Enable **DNS support**
   - For **VPC ID**, select your first VPC
   - For **Subnet IDs**, select one subnet from the VPC (preferably in different AZs)
   - Click **Create transit gateway attachment**

2. **Create Second VPC Attachment**
   - Click **Create transit gateway attachment** again
   - Enter a **Name tag** (e.g., "VPC-B-Attachment")
   - For **Transit gateway ID**, select your Transit Gateway
   - For **Attachment type**, select **VPC**
   - Enable **DNS support**
   - For **VPC ID**, select your second VPC
   - For **Subnet IDs**, select one subnet from the VPC
   - Click **Create transit gateway attachment**

3. **Verify Attachments**
   - Both attachments should show as "Available" status
   - Note the attachment IDs for routing configuration

### Step 3: Configure VPC Route Tables (1 minute)

1. **Update First VPC Route Table**
   - Navigate to **Route Tables**
   - Select the route table associated with your first VPC's subnet
   - Click the **Routes** tab
   - Click **Edit routes**
   - Click **Add route**
   - For **Destination**, enter the CIDR block of the second VPC (e.g., 10.1.0.0/16)
   - For **Target**, select **Transit Gateway** and choose your Transit Gateway
   - Click **Save changes**

2. **Update Second VPC Route Table**
   - Select the route table associated with your second VPC's subnet
   - Click the **Routes** tab
   - Click **Edit routes**
   - Click **Add route**
   - For **Destination**, enter the CIDR block of the first VPC (e.g., 10.0.0.0/16)
   - For **Target**, select **Transit Gateway** and choose your Transit Gateway
   - Click **Save changes**

### Step 4: Test Connectivity (30 seconds)

1. **Test Connection**
   - Connect to an EC2 instance in the first VPC
   - Ping the private IP address of an instance in the second VPC
   - Demonstrate successful connectivity through the Transit Gateway

### Wrap-up (30 seconds)
"We've successfully deployed a Transit Gateway and connected two VPCs through it. This centralized approach scales much better than VPC peering as you add more VPCs, and provides a single point of management for your network connectivity."

## Key Points to Emphasize

- **Scalability**: Transit Gateway scales better than VPC peering for multiple VPC connections
- **Centralized Management**: Single point of control for routing policies
- **Route Propagation**: Automatic route propagation simplifies management
- **Cross-Region Support**: Can connect VPCs across different AWS regions
- **On-Premises Integration**: Supports VPN and Direct Connect attachments
- **Cost Considerations**: Transit Gateway has hourly charges and data processing fees

## Architecture Benefits

- **Hub and Spoke Model**: Eliminates the need for full mesh VPC peering
- **Simplified Routing**: Centralized route tables reduce complexity
- **Security**: Granular control over inter-VPC communication
- **Monitoring**: Centralized monitoring and logging capabilities

## Common Issues and Troubleshooting

1. **Attachment Fails**: Check VPC subnet selection and availability zones
2. **No Connectivity**: Verify route tables in both VPCs point to Transit Gateway
3. **Partial Connectivity**: Check security group rules and NACLs
4. **Route Conflicts**: Ensure no conflicting routes in Transit Gateway route tables
5. **DNS Issues**: Verify DNS support is enabled on attachments

## Advanced Configuration Options

- **Custom Route Tables**: Create separate route tables for different traffic patterns
- **Route Propagation Control**: Disable automatic propagation for custom routing
- **Cross-Account Sharing**: Share Transit Gateway across AWS accounts
- **Multicast Support**: Enable multicast for specialized applications

## Cleanup Instructions

1. Delete routes from VPC route tables that point to Transit Gateway
2. Delete Transit Gateway attachments
3. Delete the Transit Gateway
4. Terminate any test EC2 instances if no longer needed

## Cost Optimization Tips

- Use Transit Gateway for 3+ VPC connections (more cost-effective than peering)
- Monitor data processing charges
- Consider regional placement to minimize cross-AZ charges
- Use resource sharing for multi-account scenarios

## Additional Resources

For more detailed information, refer to the official AWS documentation:

- [Tutorial: Create an AWS Transit Gateway using the Amazon VPC Console](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-getting-started-console.html)
- [What is a transit gateway?](https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html)
- [How transit gateways work](https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html)
- [Transit gateway route tables](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html)

## Citations

1. Amazon Web Services. (2024). *Tutorial: Create an AWS Transit Gateway using the Amazon VPC Console - Amazon VPC*. Retrieved from https://docs.aws.amazon.com/vpc/latest/tgw/tgw-getting-started-console.html

2. Amazon Web Services. (2024). *What is a transit gateway? - Amazon VPC*. Retrieved from https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html

3. Amazon Web Services. (2024). *How transit gateways work - Amazon VPC*. Retrieved from https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html

4. Amazon Web Services. (2024). *Building a Scalable and Secure Multi-VPC AWS Network Infrastructure - AWS Transit Gateway*. Retrieved from https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/transit-gateway.html
