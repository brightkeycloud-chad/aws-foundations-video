# Modify EC2 Instance Attributes - Terminal Demonstration

## Overview
This 5-minute demonstration shows how to modify various Amazon EC2 instance attributes using the AWS CLI from the terminal. You'll learn to change instance properties like termination protection, source/destination checking, and user data using command-line tools.

## Duration
5 minutes

## Prerequisites
- AWS CLI installed and configured with appropriate credentials
- Running EC2 instance to modify
- Terminal or command prompt access
- IAM permissions for EC2 instance modification
- Basic familiarity with command-line interfaces

## Learning Objectives
By the end of this demonstration, you will:
- Understand various EC2 instance attributes that can be modified
- Learn AWS CLI commands for instance attribute modification
- Know when instances need to be stopped vs running for changes
- Understand security implications of attribute changes

## Step-by-Step Instructions

### Step 1: Setup and Verification (1 minute)
1. Open your terminal or command prompt
2. Verify AWS CLI is configured:
   ```bash
   aws sts get-caller-identity
   ```
3. List your EC2 instances to get the instance ID:
   ```bash
   aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table
   ```
4. Set environment variable for convenience (replace with your instance ID):
   ```bash
   export INSTANCE_ID=i-1234567890abcdef0
   ```

### Step 2: View Current Instance Attributes (1 minute)
1. Check current instance attributes:
   ```bash
   # View instance details
   aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].[InstanceId,InstanceType,State.Name]' --output table
   
   # Check termination protection status
   aws ec2 describe-instance-attribute --instance-id $INSTANCE_ID --attribute disableApiTermination
   
   # Check source/destination check status
   aws ec2 describe-instance-attribute --instance-id $INSTANCE_ID --attribute sourceDestCheck
   ```

### Step 3: Modify Termination Protection (1 minute)
1. Enable termination protection:
   ```bash
   aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --disable-api-termination
   ```
2. Verify the change:
   ```bash
   aws ec2 describe-instance-attribute --instance-id $INSTANCE_ID --attribute disableApiTermination
   ```
3. Disable termination protection (for cleanup):
   ```bash
   aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --no-disable-api-termination
   ```

### Step 4: Modify Source/Destination Check (1 minute)
1. Disable source/destination checking (useful for NAT instances):
   ```bash
   aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --source-dest-check "{\"Value\": false}"
   ```
2. Verify the change:
   ```bash
   aws ec2 describe-instance-attribute --instance-id $INSTANCE_ID --attribute sourceDestCheck
   ```
3. Re-enable source/destination checking:
   ```bash
   aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --source-dest-check "{\"Value\": true}"
   ```

### Step 5: Modify Instance Type (1 minute)
**Note**: Instance must be stopped for this operation
1. Stop the instance:
   ```bash
   aws ec2 stop-instances --instance-ids $INSTANCE_ID
   aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID
   ```
2. Change instance type:
   ```bash
   aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --instance-type "{\"Value\": \"t3.small\"}"
   ```
3. Start the instance:
   ```bash
   aws ec2 start-instances --instance-ids $INSTANCE_ID
   aws ec2 wait instance-running --instance-ids $INSTANCE_ID
   ```

## Key Instance Attributes You Can Modify

### Runtime Modifiable (Instance Running)
- **Termination Protection**: Prevents accidental termination
- **Source/Destination Check**: For NAT instances and routing
- **Security Groups**: Change firewall rules
- **User Data**: Modify startup scripts (takes effect on next boot)

### Stop Required (Instance Must Be Stopped)
- **Instance Type**: Change compute resources
- **Kernel**: Change kernel ID (for PV instances)
- **RAM Disk**: Change RAM disk ID (for PV instances)
- **EBS Optimization**: Enable/disable EBS optimization

### Advanced Attributes
- **Enhanced Networking**: Enable SR-IOV
- **Instance Initiated Shutdown Behavior**: Stop vs terminate
- **Block Device Mappings**: Modify EBS volume settings

## Common Use Cases

### Security Hardening
```bash
# Enable termination protection for critical instances
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --disable-api-termination

# Modify security groups
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --groups sg-12345678 sg-87654321
```

### NAT Instance Configuration
```bash
# Disable source/destination check for NAT functionality
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --source-dest-check "{\"Value\": false}"
```

### Performance Optimization
```bash
# Enable EBS optimization (instance must be stopped)
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --ebs-optimized "{\"Value\": true}"

# Enable enhanced networking
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --sriov-net-support simple
```

## Error Handling and Validation

### Check Command Success
```bash
# Store command result and check exit code
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --disable-api-termination
if [ $? -eq 0 ]; then
    echo "Successfully enabled termination protection"
else
    echo "Failed to modify instance attribute"
fi
```

### Validate Changes
```bash
# Always verify changes took effect
aws ec2 describe-instance-attribute --instance-id $INSTANCE_ID --attribute disableApiTermination --query 'DisableApiTermination.Value'
```

## Batch Operations

### Modify Multiple Instances
```bash
# Get list of instance IDs
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=tag:Environment,Values=Development" --query 'Reservations[*].Instances[*].InstanceId' --output text)

# Apply changes to all instances
for instance in $INSTANCE_IDS; do
    echo "Modifying instance: $instance"
    aws ec2 modify-instance-attribute --instance-id $instance --disable-api-termination
done
```

## Security Considerations

### Termination Protection
- **Enable** for production instances to prevent accidental deletion
- **Disable** for temporary or development instances
- Remember to disable before legitimate termination

### Source/Destination Check
- **Disable** only for NAT instances or custom routing scenarios
- **Keep enabled** for regular instances for security
- Disabling allows instance to forward traffic

### Security Group Changes
- Changes take effect immediately
- Test connectivity after modifications
- Follow principle of least privilege

## Monitoring and Logging

### CloudTrail Events
All `modify-instance-attribute` calls are logged in CloudTrail:
```bash
# View recent API calls
aws logs filter-log-events --log-group-name CloudTrail/EC2 --filter-pattern "ModifyInstanceAttribute"
```

### CloudWatch Metrics
Monitor instance performance after attribute changes:
```bash
# Get CPU utilization after instance type change
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=$INSTANCE_ID --start-time 2024-01-01T00:00:00Z --end-time 2024-01-01T23:59:59Z --period 3600 --statistics Average
```

## Troubleshooting Common Issues

### Permission Denied
```bash
# Check IAM permissions
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::123456789012:user/username --action-names ec2:ModifyInstanceAttribute --resource-arns arn:aws:ec2:us-east-1:123456789012:instance/$INSTANCE_ID
```

### Instance State Issues
```bash
# Some modifications require specific instance states
aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].State.Name'
```

### Incompatible Instance Types
```bash
# Check available instance types in your AZ
aws ec2 describe-instance-type-offerings --location-type availability-zone --filters Name=location,Values=us-east-1a --query 'InstanceTypeOfferings[*].InstanceType'
```

## Best Practices
- Always verify changes after modification
- Use scripts for consistent batch operations
- Test attribute changes in development first
- Document all production instance modifications
- Use tags to identify instances requiring specific attributes
- Monitor performance after instance type changes

## Cleanup Commands
```bash
# Reset demonstration changes
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --no-disable-api-termination
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --source-dest-check "{\"Value\": true}"
```

## Next Steps
- Explore AWS Systems Manager for advanced instance management
- Set up CloudWatch alarms for instance monitoring
- Implement Infrastructure as Code with CloudFormation or Terraform
- Learn about EC2 Auto Scaling for dynamic attribute management

## Citations and Documentation

1. **Use ModifyInstanceAttribute with a CLI** - Amazon EC2 Developer Guide  
   https://docs.aws.amazon.com/ec2/latest/devguide/example_ec2_ModifyInstanceAttribute_section.html

2. **Using Amazon EC2 in the AWS CLI** - AWS CLI User Guide  
   https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2.html

3. **Launching, listing, and deleting Amazon EC2 instances in the AWS CLI** - AWS CLI User Guide  
   https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-instances.html

4. **modify-instance-attribute** - AWS CLI Command Reference  
   https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/modify-instance-attribute.html

## Additional Resources
- AWS CLI Installation Guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- EC2 Instance Attributes: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-attributes.html
- AWS CLI Configuration: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
