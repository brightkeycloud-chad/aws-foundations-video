# Connect to EC2 Instance - Console Demonstration

## Overview
This 5-minute demonstration shows how to connect to an Amazon EC2 instance using AWS Systems Manager Session Manager through the AWS Management Console. This method provides secure, browser-based access without requiring SSH keys or open inbound ports.

## Duration
5 minutes

## Prerequisites
- Running EC2 instance with SSM agent installed (Amazon Linux 2023 has it by default)
- EC2 instance with IAM instance profile containing `AmazonSSMManagedInstanceCore` policy
- Access to AWS Management Console
- Instance must be in a VPC with internet access or VPC endpoints for SSM

## Learning Objectives
By the end of this demonstration, you will:
- Understand AWS Systems Manager Session Manager
- Learn how to connect to EC2 instances without SSH
- Know the security benefits of Session Manager
- Understand prerequisites for Session Manager connectivity

## Step-by-Step Instructions

### Step 1: Verify Prerequisites (1 minute)
1. Navigate to **EC2 Console** → **Instances**
2. Select your running instance
3. In the **Details** tab, verify:
   - **Instance state**: Running
   - **IAM Role**: Shows an attached role with SSM permissions
   - **VPC**: Instance is in a VPC (not EC2-Classic)

### Step 2: Access Session Manager (30 seconds)
1. With your instance selected, click **Connect**
2. The **Connect to instance** dialog opens
3. You'll see multiple connection options:
   - EC2 Instance Connect
   - Session Manager
   - SSH client
   - RDP client (for Windows)

### Step 3: Connect via Session Manager (1 minute)
1. Click the **Session Manager** tab
2. Review the connection details:
   - Instance ID is pre-populated
   - User will be `ssm-user` by default
3. Click **Connect**
4. A new browser tab opens with a terminal session
5. You should see a command prompt like: `sh-5.2$ `

### Step 4: Test the Connection (2 minutes)
1. Run basic commands to verify connectivity:
   ```bash
   whoami
   # Should show: ssm-user
   
   pwd
   # Should show: /home/ssm-user
   
   sudo su -
   # Switch to root user
   
   whoami
   # Should show: root
   ```

2. Test AWS CLI access (if instance has IAM role):
   ```bash
   aws sts get-caller-identity
   # Shows the assumed role identity
   
   aws s3 ls
   # Lists S3 buckets (if role has S3 permissions)
   ```

3. Check system information:
   ```bash
   cat /etc/os-release
   # Shows OS information
   
   df -h
   # Shows disk usage
   
   free -m
   # Shows memory usage
   ```

### Step 5: Session Management (30 seconds)
1. The session remains active as long as the browser tab is open
2. Sessions automatically terminate after 20 minutes of inactivity
3. To end the session: Close the browser tab or type `exit`
4. Multiple users can have concurrent sessions to the same instance

## Key Concepts Explained

### AWS Systems Manager Session Manager
- Fully managed service for secure instance access
- No need for bastion hosts, SSH keys, or open inbound ports
- All session activity is logged to CloudTrail and CloudWatch
- Supports both Linux and Windows instances

### Security Benefits
- **No SSH keys required**: Eliminates key management overhead
- **No open inbound ports**: Reduces attack surface
- **Centralized access control**: Uses IAM for authentication and authorization
- **Session logging**: All commands and output can be logged
- **Encryption in transit**: All session data is encrypted

### Prerequisites Deep Dive
1. **SSM Agent**: Must be installed and running (default on Amazon Linux 2023)
2. **IAM Instance Profile**: Must include `AmazonSSMManagedInstanceCore` policy
3. **Network connectivity**: Instance needs internet access or VPC endpoints
4. **User permissions**: IAM user needs `ssm:StartSession` permission

## Connection Methods Comparison

| Method | Pros | Cons | Use Case |
|--------|------|------|----------|
| Session Manager | No keys, secure, auditable | Requires SSM setup | Production environments |
| EC2 Instance Connect | Browser-based SSH | Requires key pair | Development |
| SSH Client | Full SSH features | Requires keys and open ports | Advanced users |

## Troubleshooting Common Issues

### "Unable to start session"
- **Check IAM role**: Ensure instance has `AmazonSSMManagedInstanceCore` policy
- **Verify SSM agent**: Agent must be running on the instance
- **Network connectivity**: Instance needs internet or VPC endpoints

### Session Manager tab not available
- **Instance state**: Must be in "running" state
- **SSM registration**: Instance must be registered with Systems Manager
- **Region consistency**: Ensure you're in the correct AWS region

### Permission denied errors
- **User permissions**: IAM user needs Session Manager permissions
- **Instance profile**: Role must trust EC2 service
- **Policy attachment**: Verify policies are properly attached

## Advanced Features

### Session Preferences
- Configure session timeout duration
- Enable session logging to S3 or CloudWatch
- Set up session encryption with KMS keys
- Configure shell preferences

### Port Forwarding
- Forward local ports through Session Manager
- Access applications running on private instances
- Useful for database connections and web applications

## Security Best Practices
- Enable session logging for audit trails
- Use IAM conditions to restrict session access
- Implement session timeout policies
- Monitor session activity through CloudTrail
- Use VPC endpoints to avoid internet traffic

## Cost Considerations
- Session Manager usage is free
- Standard data transfer charges apply
- CloudWatch Logs charges for session logging
- VPC endpoint charges if used

## Next Steps
- Configure session logging to CloudWatch or S3
- Set up port forwarding for application access
- Explore Session Manager API for automation
- Implement session recording for compliance

## Citations and Documentation

1. **Connect to your Amazon EC2 instance using Session Manager** - Amazon EC2 User Guide  
   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-with-systems-manager-session-manager.html

2. **AWS Systems Manager Session Manager** - AWS Systems Manager User Guide  
   https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html

3. **Setting up Session Manager** - AWS Systems Manager User Guide  
   https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started.html

4. **Start a session** - AWS Systems Manager User Guide  
   https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html

## Additional Resources
- Session Manager Troubleshooting: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-troubleshooting.html
- IAM Policies for Session Manager: https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-restrict-access-quickstart.html
