# Launch EC2 Instance - Console Demonstration

## Overview
This 5-minute demonstration shows how to launch your first Amazon EC2 instance using the AWS Management Console. You'll learn the essential steps to get a virtual server running in the AWS cloud.

## Duration
5 minutes

## Prerequisites
- AWS account with EC2 permissions
- Access to AWS Management Console
- Basic understanding of cloud computing concepts

## Learning Objectives
By the end of this demonstration, you will:
- Understand the EC2 launch process
- Know how to configure basic instance settings
- Learn about instance types and AMIs
- Understand security groups and key pairs

## Step-by-Step Instructions

### Step 1: Navigate to EC2 Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to EC2 by:
   - Typing "EC2" in the search bar, or
   - Going to Services → Compute → EC2
3. Click **Launch instance** from the EC2 dashboard

### Step 2: Configure Instance Details (2 minutes)
1. **Name and tags**:
   - Enter instance name: `My-First-EC2-Instance`
   - Tags help identify and organize resources

2. **Application and OS Images (Amazon Machine Image)**:
   - Select **Amazon Linux 2023 AMI** (Free tier eligible)
   - Note the AMI ID and description

3. **Instance type**:
   - Select **t3.micro** (Free tier eligible)
   - Shows 1 vCPU and 1 GiB Memory

### Step 3: Configure Key Pair and Security (1.5 minutes)
1. **Key pair (login)**:
   - For demonstration: Select **Proceed without a key pair**
   - In production: Create or select an existing key pair for SSH access

2. **Network settings**:
   - Keep default VPC and subnet
   - **Security groups**: Create new security group
   - Name: `demo-security-group`
   - Description: `Security group for demo instance`
   - Keep default SSH rule (port 22) - but note it's open to 0.0.0.0/0

### Step 4: Configure Storage and Advanced Settings (1 minute)
1. **Configure storage**:
   - Keep default 8 GiB gp3 root volume
   - Note encryption options available

2. **Advanced details** (optional):
   - **IAM instance profile**: Select the profile created in previous demo
   - **User data**: Leave blank for this demo
   - Keep other defaults

### Step 5: Launch Instance (1 minute)
1. Review the **Summary** panel on the right
2. Note the estimated costs
3. Click **Launch instance**
4. Success page appears with instance ID
5. Click **View all instances** to see your running instance

## Key Concepts Explained

### Amazon Machine Image (AMI)
- Pre-configured template containing OS and software
- AWS provides many public AMIs
- You can create custom AMIs

### Instance Types
- Different combinations of CPU, memory, storage, and networking
- T3.micro is burstable performance for variable workloads
- Choose based on application requirements

### Security Groups
- Virtual firewall controlling inbound and outbound traffic
- Stateful - return traffic automatically allowed
- Default denies all inbound, allows all outbound

### Key Pairs
- Used for secure SSH access to Linux instances
- AWS stores public key, you keep private key
- Essential for production instances

## Verification Steps
1. Instance appears in EC2 console with "Running" state
2. Instance has public and private IP addresses
3. Security group shows configured rules
4. Instance profile is attached (if configured)

## Instance States
- **Pending**: Instance is starting up
- **Running**: Instance is active and ready
- **Stopping**: Instance is shutting down
- **Stopped**: Instance is shut down but not terminated
- **Terminated**: Instance is permanently deleted

## Cost Considerations
- Charges begin when instance enters "running" state
- Free tier includes 750 hours of t3.micro per month
- Stop instances when not needed to save costs
- Terminated instances cannot be recovered

## Security Best Practices
- Use key pairs for SSH access
- Restrict security group rules to necessary ports and sources
- Use IAM instance profiles instead of storing credentials
- Enable detailed monitoring and logging

## Next Steps
- Connect to your instance using Session Manager or SSH
- Install software and configure applications
- Create AMIs from configured instances
- Set up monitoring and alerting

## Troubleshooting
- **Instance fails to launch**: Check service limits and quotas
- **Cannot connect**: Verify security group rules and key pair
- **Performance issues**: Consider different instance type
- **Billing concerns**: Monitor usage in AWS Cost Explorer

## Citations and Documentation

1. **Tutorial: Launch my very first Amazon EC2 instance** - Amazon EC2 User Guide  
   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/tutorial-launch-my-first-ec2-instance.html

2. **Tutorials for launching EC2 instances** - Amazon EC2 User Guide  
   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-launch-tutorials.html

3. **Amazon Machine Images (AMI)** - Amazon EC2 User Guide  
   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html

4. **Amazon EC2 instance types** - Amazon EC2 User Guide  
   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html

## Additional Resources
- AWS Free Tier: https://aws.amazon.com/free/
- EC2 Pricing: https://aws.amazon.com/ec2/pricing/
- AWS Well-Architected Framework: https://aws.amazon.com/architecture/well-architected/
