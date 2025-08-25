# Modify EC2 Instance Attributes - Terminal Demonstration

## Overview
This 5-minute demonstration shows how to modify various Amazon EC2 instance attributes using the AWS CLI from the terminal. You'll learn to change instance properties like termination protection, source/destination checking, and user data using automated shell scripts and command-line tools.

## Duration
5 minutes

## Prerequisites
- AWS CLI installed and configured with appropriate credentials
- Running EC2 instance to modify
- Terminal or command prompt access
- IAM permissions for EC2 instance modification
- Basic familiarity with command-line interfaces
- Optional: `jq` for enhanced IMDS settings display (install with `brew install jq` on macOS or `apt-get install jq` on Ubuntu)

## Learning Objectives
By the end of this demonstration, you will:
- Understand various EC2 instance attributes that can be modified
- Learn AWS CLI commands for instance attribute modification through automated scripts
- Know when instances need to be stopped vs running for changes
- Understand security implications of attribute changes

## Quick Start

### Option 1: Run Complete Interactive Demo
```bash
./run-demo.sh
```
This master script will guide you through the entire demonstration with prompts and explanations.

### Option 2: Run Individual Scripts
1. **Setup and list instances:**
   ```bash
   ./scripts/setup.sh
   ```

2. **Set your instance ID:**
   ```bash
   export INSTANCE_ID=i-1234567890abcdef0  # Replace with your instance ID
   ```

3. **Run individual demonstration scripts:**
   ```bash
   ./scripts/view-attributes.sh
   ./scripts/modify-termination-protection.sh
   ./scripts/modify-source-dest-check.sh
   ./scripts/modify-imds-settings.sh
   ./scripts/modify-instance-type.sh        # Optional - stops/starts instance
   ./scripts/cleanup.sh
   ```

### Option 3: Batch Operations
```bash
# Modify multiple instances by tag
./scripts/batch-operations.sh --tag-filter Environment=Development --enable-protection

# Modify specific instances
./scripts/batch-operations.sh --instance-ids i-123,i-456 --disable-protection
```

## Script Descriptions

### Core Demo Scripts

| Script | Purpose | Instance State Required |
|--------|---------|------------------------|
| `setup.sh` | Verify AWS CLI and list instances | Any |
| `view-attributes.sh` | Display current instance attributes | Any |
| `modify-termination-protection.sh` | Enable/disable termination protection | Running or Stopped |
| `modify-source-dest-check.sh` | Modify source/destination checking | Running or Stopped |
| `modify-imds-settings.sh` | Configure IMDS security settings | Running or Stopped |
| `modify-instance-type.sh` | Change instance type | Stopped (script handles this) |
| `cleanup.sh` | Reset all changes to safe defaults | Any |

### Additional Scripts

| Script | Purpose | Description |
|--------|---------|-------------|
| `run-demo.sh` | Master interactive demo | Runs complete demonstration with user guidance |
| `batch-operations.sh` | Bulk operations | Modify multiple instances simultaneously |

## Detailed Step-by-Step Instructions

### Step 1: Setup and Verification (1 minute)
Run the setup script to verify your environment:
```bash
./scripts/setup.sh
```

This script will:
- Verify AWS CLI installation and configuration
- Display your current AWS identity
- List available EC2 instances
- Provide instructions for setting the INSTANCE_ID environment variable

### Step 2: Set Instance ID
After reviewing the available instances, set your target instance:
```bash
export INSTANCE_ID=i-1234567890abcdef0  # Replace with your actual instance ID
```

### Step 3: View Current Instance Attributes (1 minute)
```bash
./scripts/view-attributes.sh
```

This script displays:
- Instance details (ID, type, state, IP addresses)
- Termination protection status
- Source/destination check status
- Security groups
- EBS optimization status

### Step 4: Modify Termination Protection (1 minute)
```bash
./scripts/modify-termination-protection.sh
```

This interactive script will:
- Show current termination protection status
- Enable termination protection
- Verify the change
- Prompt before disabling (for demo cleanup)
- Provide educational information about the feature

### Step 5: Modify Source/Destination Check (1 minute)
```bash
./scripts/modify-source-dest-check.sh
```

This interactive script will:
- Show current source/destination check status
- Disable the check (for NAT instance scenarios)
- Verify the change
- Prompt before re-enabling (security best practice)
- Explain when to use this feature

### Step 6: Modify IMDS Settings (1 minute)
```bash
./scripts/modify-imds-settings.sh
```

This interactive script will:
- Show current IMDS (Instance Metadata Service) configuration
- Demonstrate security hardening by requiring IMDSv2
- Test IMDS access methods (IMDSv1 vs IMDSv2)
- Explain security implications of different IMDS settings
- Optionally revert to less restrictive settings

### Step 7: Modify Instance Type (1 minute) - Optional
```bash
./scripts/modify-instance-type.sh
```

**⚠️ Warning**: This script will stop and restart your instance!

This script will:
- Display current instance type and state
- Warn about service interruption
- Stop the instance if running
- Change the instance type
- Optionally restart the instance
- Provide guidance on instance type selection

### Step 8: Cleanup
```bash
./scripts/cleanup.sh
```

This script resets all demonstration changes:
- Disables termination protection
- Enables source/destination check
- Configures IMDS to secure defaults (IMDSv2 required)
- Shows final attribute status
- Provides summary of changes

## Key Instance Attributes You Can Modify

### Runtime Modifiable (Instance Running)
- **Termination Protection**: Prevents accidental termination
- **Source/Destination Check**: For NAT instances and routing
- **Security Groups**: Change firewall rules
- **User Data**: Modify startup scripts (takes effect on next boot)
- **IMDS Settings**: Configure Instance Metadata Service security

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

### IMDS Security Configuration
```bash
# Configure IMDS to require tokens (IMDSv2 only) - more secure
aws ec2 modify-instance-metadata-options --instance-id $INSTANCE_ID --http-tokens required --http-put-response-hop-limit 1 --http-endpoint enabled

# Allow both IMDSv1 and IMDSv2 (less secure)
aws ec2 modify-instance-metadata-options --instance-id $INSTANCE_ID --http-tokens optional --http-put-response-hop-limit 2 --http-endpoint enabled

# Disable IMDS entirely
aws ec2 modify-instance-metadata-options --instance-id $INSTANCE_ID --http-endpoint disabled

# Check current IMDS settings
aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].MetadataOptions'
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
