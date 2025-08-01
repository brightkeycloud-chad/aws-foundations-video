# Deploy an Auto Scaling Group - Console Demonstration

## Overview
This 5-minute demonstration shows how to create an Amazon EC2 Auto Scaling Group using the AWS Management Console with pre-configured infrastructure. The focus is on creating the Auto Scaling Group itself and testing its functionality with an Application Load Balancer.

## Prerequisites
- AWS account with appropriate permissions
- Terraform installed (for infrastructure setup)
- AWS CLI configured
- Basic understanding of EC2 instances and Auto Scaling

## Infrastructure Setup (Pre-Demonstration)

### 1. Deploy Supporting Infrastructure
Before the demonstration, deploy the required infrastructure using Terraform:

```bash
# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Deploy the infrastructure
terraform apply
```

This creates:
- **Launch Template**: Pre-configured with Amazon Linux 2023 (x86_64)
- **Application Load Balancer**: Public-facing ALB with HTTP listener
- **Target Group**: Health checks configured for `/health` endpoint
- **Security Groups**: Properly configured for ALB and EC2 communication
- **IAM Roles**: SSM Session Manager access for instances

### 2. Note Key Information
After deployment, Terraform outputs will provide:
- Launch Template name
- Target Group ARN
- ALB DNS name for testing

## Demonstration Outline (5 minutes)

### Phase 1: Create Auto Scaling Group (3 minutes)

1. **Navigate to Auto Scaling Groups**
   - Open AWS Management Console
   - Go to EC2 service
   - Select "Auto Scaling Groups" from the left navigation pane
   - Click "Create an Auto Scaling group"

2. **Configure Auto Scaling Group**
   - **Step 1: Choose launch template**
     - **Name**: `demo-web-server-asg`
     - **Launch Template**: Select `asg-demo-launch-template` (created by Terraform)
     - **Version**: Latest
     - Click "Next"

   - **Step 2: Choose instance launch options**
     - **VPC**: Default VPC (automatically selected)
     - **Availability Zones**: Select 2-3 availability zones
     - **Subnets**: Choose public subnets in selected AZs
     - Click "Next"

   - **Step 3: Configure advanced options**
     - **Load Balancing**: 
       - ✅ Attach to an existing load balancer
       - Choose from your load balancer target groups
       - Select `asg-demo-tg` target group
     - **Health Checks**: 
       - ✅ Turn on Elastic Load Balancing health checks
       - **Health Check Grace Period**: 300 seconds
     - Click "Next"

   - **Step 4: Configure group size and scaling**
     - **Desired Capacity**: 2
     - **Minimum Capacity**: 1
     - **Maximum Capacity**: 4
     - **Automatic Scaling**: Create target tracking scaling policy
       - **Metric Type**: Average CPU Utilization
       - **Target Value**: 70%
     - **Instance Warmup**: 300 seconds
     - Click "Next"

   - **Step 5: Add notifications** (Skip)
     - Click "Next"

   - **Step 6: Add tags**
     - Add tag: `Name` = `Demo-ASG-Instance`
     - Add tag: `Environment` = `Demo`
     - Click "Next"

   - **Step 7: Review and create**
     - Review configuration
     - Click "Create Auto Scaling group"

### Phase 2: Test and Verify (2 minutes)

1. **Monitor Instance Launch**
   - Watch Auto Scaling Group activity tab
   - Verify 2 instances are launching
   - Check instances are distributed across AZs
   - Monitor target group health in EC2 → Load Balancers → Target Groups

2. **Test Application**
   - Access the ALB DNS name (from Terraform output)
   - Verify web application loads showing instance information
   - Refresh page to see load balancing between instances
   - Test health check endpoint: `http://[ALB-DNS]/health`

3. **Demonstrate Auto Scaling (Optional)**
   - If time permits, show scaling policies
   - Explain how CPU-based scaling works
   - Mention load testing capabilities built into instances

## Key Learning Points
- Auto Scaling Groups work with launch templates for consistent configuration
- Integration with Application Load Balancers provides health checking
- Multi-AZ deployment improves availability and fault tolerance
- Target tracking scaling policies automatically adjust capacity
- Health checks ensure only healthy instances receive traffic

## Testing Load Balancing
The deployed web application shows:
- Instance ID and metadata
- Availability Zone information
- Health check status
- Auto-refresh every 30 seconds

Each instance includes a load generation script at `/home/ec2-user/generate-load.sh` for testing scaling behavior.

## Cleanup Instructions

### 1. Delete Auto Scaling Group
```bash
# From AWS Console:
# 1. Select the Auto Scaling Group
# 2. Actions → Delete
# 3. Type "delete" to confirm
```

### 2. Destroy Terraform Infrastructure
```bash
# Remove all Terraform-created resources
terraform destroy
```

This will clean up:
- Launch Template
- Application Load Balancer
- Target Group
- Security Groups
- IAM Roles and Policies

## Troubleshooting Tips
- **Instances not launching**: Check launch template configuration and subnet settings
- **Health check failures**: Verify security group allows ALB to reach instances on port 80
- **Load balancer not accessible**: Ensure ALB security group allows inbound port 80
- **Scaling not working**: Check CloudWatch metrics and scaling policy configuration
- **Target group unhealthy**: Wait for health check grace period, verify `/health` endpoint

## Architecture Overview
```
Internet → ALB (Port 80) → Target Group → Auto Scaling Group → EC2 Instances (Multi-AZ)
                                                            ↓
                                                    Launch Template
                                                    (Amazon Linux 2023)
```

## Advanced Features Demonstrated
- **Health Checks**: ELB health checks with custom `/health` endpoint
- **Load Balancing**: Round-robin distribution across instances
- **Auto Scaling**: CPU-based target tracking scaling policy
- **Multi-AZ**: Automatic distribution across availability zones
- **Session Manager**: SSM access without SSH keys
- **Monitoring**: Built-in CloudWatch integration

## Citations and Documentation

This demonstration is based on the following AWS documentation:

1. **Create a launch template for an Auto Scaling group**  
   https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-launch-template.html

2. **Create an Auto Scaling group using a launch template**  
   https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-launch-template.html

3. **Create Auto Scaling groups using launch templates**  
   https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-auto-scaling-groups-launch-template.html

4. **Auto Scaling groups - Amazon EC2 Auto Scaling**  
   https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html

5. **What is Amazon EC2 Auto Scaling?**  
   https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html

6. **Elastic Load Balancing and Amazon EC2 Auto Scaling**  
   https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-load-balancer.html

---

*Last updated: July 2025*  
*AWS Documentation version: Current as of demonstration creation*  
*Terraform version: >= 1.0*
