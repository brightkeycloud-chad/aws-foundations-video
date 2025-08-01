# Deploy VPC with NAT Gateway using AWS CloudFormation Console

## Demo Overview
This 5-minute demonstration shows how to deploy a Virtual Private Cloud (VPC) with public and private subnets, including a NAT Gateway for secure internet access from private resources, using the AWS CloudFormation console interface.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- Basic understanding of VPC concepts

## Demo Script (5 minutes)

### Step 1: Access CloudFormation Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **CloudFormation** service
3. Click **Create stack** → **With new resources (standard)**

### Step 2: Upload Template (1 minute)
1. Select **Upload a template file**
2. Click **Choose file** and select `vpc-template.yaml`
3. Click **Next**

### Step 3: Configure Stack Parameters (1.5 minutes)
1. **Stack name**: Enter `demo-vpc-stack`
2. **Parameters**:
   - VpcCidr: `10.0.0.0/16` (default)
   - PublicSubnetCidr: `10.0.1.0/24` (default)
   - PrivateSubnetCidr: `10.0.2.0/24` (default)
3. Click **Next**

### Step 4: Configure Stack Options (30 seconds)
1. **Tags** (optional): Add `Environment: Demo`
2. **Permissions**: Leave default (use current role)
3. **Advanced options**: Leave defaults
4. Click **Next**

### Step 5: Review and Deploy (1 minute)
1. Review stack configuration
2. Scroll to bottom and check **I acknowledge that AWS CloudFormation might create IAM resources**
3. Click **Submit**

### Step 6: Monitor Deployment (30 seconds)
1. Watch the **Events** tab for real-time updates
2. Observe resource creation progress
3. Stack status will change from `CREATE_IN_PROGRESS` to `CREATE_COMPLETE`

### Step 7: Verify Resources (30 seconds)
1. Click **Resources** tab to see created resources
2. Click **Outputs** tab to see exported values including NAT Gateway EIP
3. Navigate to **VPC console** to verify:
   - Created VPC and subnets
   - NAT Gateway in the public subnet
   - Route tables with appropriate routes (0.0.0.0/0 → IGW for public, 0.0.0.0/0 → NAT for private)

## Expected Results
After successful deployment, you will have:
- 1 VPC with DNS resolution enabled
- 1 Public subnet with internet gateway access
- 1 Private subnet with NAT Gateway access for outbound internet traffic
- 1 Internet Gateway for public subnet internet access
- 1 NAT Gateway in the public subnet for private subnet internet access
- 1 Elastic IP address attached to the NAT Gateway
- Route tables properly configured for both subnets
- All resources tagged appropriately

## Cleanup
To avoid charges, delete the stack:
1. Select the stack in CloudFormation console
2. Click **Delete**
3. Confirm deletion

## Key Learning Points
- CloudFormation console provides a user-friendly interface for infrastructure deployment
- Parameters allow template customization without code changes
- Stack outputs can be used by other stacks
- Real-time monitoring shows deployment progress
- All resources are managed as a single unit
- NAT Gateways enable secure outbound internet access for private subnets
- Elastic IP addresses provide static public IP addresses for NAT Gateways
- Resource dependencies ensure proper creation order (EIP → NAT Gateway → Route)

## Troubleshooting
- **Template validation errors**: Check YAML syntax and resource properties
- **Permission errors**: Ensure your IAM user/role has CloudFormation and EC2 permissions
- **Resource limits**: Verify you haven't exceeded VPC limits in your region
- **NAT Gateway creation failures**: Ensure the public subnet and internet gateway are created first
- **Elastic IP allocation errors**: Check if you've reached the EIP limit in your region

## Cost Considerations
**Important**: This demo creates a NAT Gateway which incurs hourly charges (~$0.045/hour) plus data processing charges. Delete the stack immediately after the demo to minimize costs.

- **VPC, subnets, route tables**: No charges
- **Internet Gateway**: No charges
- **NAT Gateway**: Hourly charges apply (~$0.045/hour + data processing)
- **Elastic IP**: No charges while attached to NAT Gateway

## Documentation References
- [Configure Amazon VPC resources with CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-ec2-vpc.html)
- [AWS::EC2::VPC](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-ec2-vpc.html)
- [AWS::EC2::Subnet](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-ec2-subnet.html)
- [AWS::EC2::InternetGateway](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-ec2-internetgateway.html)
- [AWS::EC2::NatGateway](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-ec2-natgateway.html)
- [AWS::EC2::EIP](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-ec2-eip.html)
- [AWS::EC2::RouteTable](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-ec2-routetable.html)
