# Create IAM Role for EC2 with SSM and CloudWatch Agent (5 minutes)

## Overview
This demonstration shows how to create an IAM role that enables EC2 instances to use AWS Systems Manager (SSM) and CloudWatch Agent functionality. This role allows for secure remote management, monitoring, and log collection from EC2 instances without requiring SSH access or hardcoded credentials.

## Learning Objectives
By the end of this demonstration, participants will understand:
- How to create an IAM role for EC2 instances with SSM capabilities
- What permissions are needed for CloudWatch Agent functionality
- How SSM enables secure instance management without SSH
- The benefits of using managed policies for common use cases

## Prerequisites
- AWS account with administrator access
- Access to the AWS Management Console
- Understanding of IAM concepts and EC2 basics
- Basic knowledge of Systems Manager and CloudWatch concepts

## Demonstration Steps (5 minutes)

### Step 1: Navigate to IAM Service (30 seconds)
1. Sign in to the [AWS Management Console](https://console.aws.amazon.com/)
2. In the search bar, type "IAM" and select "IAM" from the results
3. Click on "Roles" in the left navigation pane

### Step 2: Create New IAM Role (1 minute)
1. Click the "Create role" button
2. **Select trusted entity type:**
   - Choose "AWS service" (default selection)
   - This allows AWS services to assume this role
3. **Choose a service:**
   - Select "EC2" from the list of services
   - This allows EC2 instances to assume this role
4. Click "Next"

### Step 3: Attach SSM and CloudWatch Policies (2 minutes)
1. **Add Systems Manager core functionality:**
   - In the search box, type "AmazonSSMManagedInstanceCore"
   - Check the box next to "AmazonSSMManagedInstanceCore"
   - This enables core SSM functionality including Session Manager
2. **Add CloudWatch Agent permissions:**
   - Search for "CloudWatchAgentServerPolicy"
   - Check the box next to "CloudWatchAgentServerPolicy"
   - This allows the CloudWatch agent to send metrics and logs
3. **Review selected policies:**
   - Verify both policies are selected
   - Note the policy descriptions in the summary
   - Click "Next"

### Step 4: Configure Role Details (1 minute)
1. **Role name and description:**
   - Enter **Role name**: `EC2-SSM-CloudWatch-Role`
   - Enter **Description**: "Role for EC2 instances with SSM management and CloudWatch monitoring"
2. **Review trusted entities:**
   - Verify "ec2.amazonaws.com" is listed as trusted entity
3. **Review permissions:**
   - Confirm both policies are attached:
     - AmazonSSMManagedInstanceCore
     - CloudWatchAgentServerPolicy
4. Click "Create role"

### Step 5: Verify Role Creation and Capabilities (30 seconds)
1. **Find your new role:**
   - Search for "EC2-SSM-CloudWatch-Role" in the roles list
   - Click on the role name to view details
2. **Review role configuration:**
   - **Trust relationships**: Shows EC2 service can assume this role
   - **Permissions**: Shows both attached policies
   - **ARN**: Note the role ARN for future reference

## Key Concepts Covered

### AWS Systems Manager (SSM) Capabilities
- **Session Manager**: Secure shell access without SSH keys or bastion hosts
- **Patch Manager**: Automated patching of operating systems and applications
- **Inventory**: Collect metadata about instances and installed software
- **Run Command**: Execute commands remotely across multiple instances
- **Parameter Store**: Secure storage and retrieval of configuration data

### CloudWatch Agent Functionality
- **Custom Metrics**: Collect system-level metrics (memory, disk usage, etc.)
- **Log Collection**: Send application and system logs to CloudWatch Logs
- **Performance Monitoring**: Detailed monitoring of instance performance
- **Centralized Logging**: Aggregate logs from multiple instances

### IAM Role Benefits for EC2
- **No SSH Required**: Access instances securely through Session Manager
- **Temporary Credentials**: Automatically rotated, no long-term keys
- **Centralized Management**: Manage instances from AWS console
- **Audit Trail**: All actions logged in CloudTrail

## What This Role Enables

### AmazonSSMManagedInstanceCore Policy Provides:
- **Session Manager access**: Connect to instances via browser or CLI
- **Systems Manager Agent**: Core SSM functionality
- **Document execution**: Run SSM documents and automation
- **Inventory collection**: Gather instance metadata
- **Patch management**: Apply and track patches

### CloudWatchAgentServerPolicy Provides:
- **Metric publishing**: Send custom metrics to CloudWatch
- **Log streaming**: Send logs to CloudWatch Logs
- **EC2 metadata access**: Retrieve instance information for tagging
- **Parameter Store access**: Read CloudWatch agent configuration

## Practical Usage Examples

### Session Manager Access:
```bash
# Connect to instance without SSH
aws ssm start-session --target i-1234567890abcdef0
```

### CloudWatch Agent Configuration:
```bash
# Agent can read configuration from Parameter Store
# and send metrics/logs to CloudWatch automatically
```

### Remote Command Execution:
```bash
# Run commands on multiple instances
aws ssm send-command --document-name "AWS-RunShellScript" \
  --parameters 'commands=["df -h"]' --targets "Key=tag:Environment,Values=Production"
```

## Important Notes
- **SSM Agent required**: Instances need SSM Agent installed (pre-installed on Amazon Linux, Windows)
- **Internet connectivity**: Instances need internet access or VPC endpoints for SSM
- **CloudWatch Agent**: Must be installed and configured separately on instances
- **Regional service**: SSM and CloudWatch are region-specific services
- **No inbound ports**: Session Manager works without opening SSH/RDP ports

## Security Benefits Demonstrated
1. **No SSH keys**: Eliminate SSH key management and security risks
2. **Centralized access**: Control instance access through IAM policies
3. **Session logging**: All Session Manager sessions can be logged
4. **Temporary credentials**: Role provides rotating, temporary access
5. **Least privilege**: Policies grant only necessary permissions

## Troubleshooting
- **Instance not appearing in SSM**: Check SSM Agent status and internet connectivity
- **Session Manager fails**: Verify role is attached and policies are correct
- **CloudWatch metrics missing**: Ensure CloudWatch Agent is installed and configured
- **Permission denied**: Check if both required policies are attached to the role

## Next Steps
After creating and attaching this role:
1. **Launch EC2 instance** with this role attached
2. **Test Session Manager** access from the console
3. **Install CloudWatch Agent** on the instance
4. **Configure CloudWatch Agent** to collect desired metrics and logs
5. **Set up CloudWatch dashboards** to visualize the collected data
6. **Create CloudWatch alarms** for monitoring and alerting

## Testing the Role
### Verify SSM Functionality:
1. Launch an EC2 instance with this role
2. Go to Systems Manager → Session Manager
3. Start a session with your instance
4. Run commands without SSH access

### Verify CloudWatch Agent:
1. Install CloudWatch Agent on the instance
2. Configure it to collect system metrics
3. Check CloudWatch console for custom metrics
4. Verify logs are being sent to CloudWatch Logs

## Documentation References
- [AmazonSSMManagedInstanceCore Policy](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonSSMManagedInstanceCore.html)
- [CloudWatchAgentServerPolicy](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/CloudWatchAgentServerPolicy.html)
- [Configure Instance Permissions for Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-permissions.html)
- [Session Manager Getting Started](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-instance-profile.html)
- [Installing CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance.html)

---
*This demonstration is part of the AWS Foundations training series focusing on AWS Identity and Access Management (IAM) fundamentals.*
