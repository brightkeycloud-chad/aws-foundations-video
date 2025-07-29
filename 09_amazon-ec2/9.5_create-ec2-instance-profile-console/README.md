# Create EC2 Instance Profile - Console Demonstration

## Overview
This 5-minute demonstration shows how to create an IAM instance profile for EC2 instances using the AWS Management Console. An instance profile allows EC2 instances to assume IAM roles and access AWS services securely.

## Duration
5 minutes

## Prerequisites
- AWS account with administrative access
- Access to AWS Management Console
- Basic understanding of IAM concepts

## Learning Objectives
By the end of this demonstration, you will:
- Understand what an EC2 instance profile is
- Know how to create an IAM role for EC2
- Learn how to attach policies to the role
- Understand how instance profiles work with EC2

## Step-by-Step Instructions

### Step 1: Navigate to IAM Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to the IAM service by:
   - Typing "IAM" in the search bar, or
   - Going to Services → Security, Identity, & Compliance → IAM

### Step 2: Create IAM Role for EC2 (2 minutes)
1. In the IAM console, click **Roles** in the left navigation pane
2. Click **Create role**
3. Select **AWS service** as the trusted entity type
4. Choose **EC2** from the service list
5. Select **EC2** use case (this allows EC2 instances to call AWS services)
6. Click **Next**

### Step 3: Attach Policies (1.5 minutes)
1. In the permissions policies section, search for and select appropriate policies:
   - For demonstration: `AmazonS3ReadOnlyAccess` (allows read access to S3)
   - For Systems Manager access: `AmazonSSMManagedInstanceCore`
2. You can attach multiple policies as needed
3. Click **Next**

### Step 4: Configure Role Details (1 minute)
1. Enter a **Role name**: `EC2-Demo-Role`
2. Add a **Description**: "Demo role for EC2 instances to access AWS services"
3. Review the trusted entities (should show ec2.amazonaws.com)
4. Review attached policies
5. Click **Create role**

### Step 5: Verify Instance Profile Creation (30 seconds)
1. The console automatically creates an instance profile with the same name as the role
2. Navigate to the role you just created
3. Note the **Instance profiles** section shows the associated instance profile
4. The instance profile ARN will be displayed

## Key Concepts Explained

### What is an Instance Profile?
- A container for an IAM role that can be attached to EC2 instances
- Provides temporary credentials to applications running on the instance
- Automatically created when you create a role for EC2 in the console

### Security Benefits
- No need to store AWS credentials on EC2 instances
- Credentials are automatically rotated
- Fine-grained permissions through IAM policies

### Best Practices
- Follow principle of least privilege
- Use specific policies rather than broad permissions
- Regularly review and audit role permissions

## Verification Steps
1. The role appears in the IAM Roles list
2. The role shows "EC2" as a trusted entity
3. An instance profile with the same name is automatically created
4. The role can be selected when launching EC2 instances

## Next Steps
- Use this instance profile when launching EC2 instances
- Test the permissions by connecting to an instance and using AWS CLI
- Monitor usage through CloudTrail logs

## Troubleshooting
- **Role not appearing in EC2 launch wizard**: Wait a few minutes for propagation
- **Permission denied errors**: Verify the attached policies provide necessary permissions
- **Cannot assume role**: Check the trust relationship allows ec2.amazonaws.com

## Citations and Documentation

1. **Use instance profiles** - AWS IAM User Guide  
   https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html

2. **IAM roles for Amazon EC2** - Amazon EC2 User Guide  
   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html

3. **Use an IAM role to grant permissions to applications running on Amazon EC2 instances** - AWS IAM User Guide  
   https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html

## Additional Resources
- AWS IAM Best Practices: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
- AWS Security Best Practices: https://aws.amazon.com/architecture/security-identity-compliance/
