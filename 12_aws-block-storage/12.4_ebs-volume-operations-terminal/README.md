# 12.4 EBS Volume Operations - Terminal Demonstration

## Overview
This 5-minute demonstration shows how to perform essential Amazon EBS volume operations using the AWS CLI. You'll learn to create, attach, detach, and manage EBS volumes from the command line, which is essential for automation and scripting.

## Prerequisites
- AWS CLI installed and configured with appropriate credentials
- An existing EC2 instance in a known Availability Zone
- Basic familiarity with command line operations
- `jq` utility for JSON parsing (optional but recommended)
- `bc` utility for cost calculations (optional)

## Available Scripts

### Individual Operation Scripts
1. **`01-create-volume.sh`** - Creates an EBS volume with proper tagging
2. **`02a-attach-volume.sh`** - Attaches volume to an EC2 instance
3. **`02b-modify-volume.sh`** - Modifies volume properties (size, IOPS, etc.)
4. **`02c-detach-volume.sh`** - Safely detaches volume from instance
5. **`03-cleanup.sh`** - Cleans up all created resources
6. **`run-demo.sh`** - Master script that runs the complete demonstration

### Script Usage

#### Quick Start (Complete Demo)
```bash
# Set your instance ID (required for volume operations)
export INSTANCE_ID="i-1234567890abcdef0"

# Run the complete demonstration
./run-demo.sh
```

#### Individual Script Usage

**Create Volume:**
```bash
# Basic usage (uses defaults)
./01-create-volume.sh

# With custom configuration
export AWS_REGION="us-west-2"
export AVAILABILITY_ZONE="us-west-2a"
export VOLUME_SIZE="20"
export VOLUME_TYPE="gp3"
./01-create-volume.sh
```

**Attach Volume:**
```bash
# Requires INSTANCE_ID environment variable
export INSTANCE_ID="i-1234567890abcdef0"
./02a-attach-volume.sh

# With custom device name
export DEVICE_NAME="/dev/sdg"
./02a-attach-volume.sh
```

**Modify Volume:**
```bash
# Basic usage (increases size by 5 GiB)
./02b-modify-volume.sh

# Custom size increase
export SIZE_INCREASE="10"
./02b-modify-volume.sh
```

**Detach Volume:**
```bash
# Interactive detachment (with safety prompts)
./02c-detach-volume.sh

# Force detachment (skip safety prompts)
export FORCE_DETACH="true"
./02c-detach-volume.sh
```

**Cleanup:**
```bash
# Interactive cleanup (prompts for confirmation)
./03-cleanup.sh

# Force cleanup (no prompts)
export FORCE_DELETE="true"
./03-cleanup.sh
```

## Demonstration Script (5 minutes)

### Introduction (30 seconds)
"Today we'll demonstrate EBS volume operations using the AWS CLI. This approach is essential for automation, scripting, and DevOps workflows. We'll create a volume, attach it to an instance, modify it, and then detach it using individual scripts for each operation."

### Step 1: Volume Creation (1 minute)
1. **Set environment variables** for reusability:
   ```bash
   export AWS_REGION="us-east-1"
   export AVAILABILITY_ZONE="us-east-1a"
   export INSTANCE_ID="i-1234567890abcdef0"  # Replace with actual instance ID
   ```

2. **Run the volume creation script**:
   ```bash
   ./01-create-volume.sh
   ```

3. **Explain what the script does**:
   - Validates AWS CLI configuration and credentials
   - Verifies the availability zone exists
   - Creates a 10GB gp3 volume with comprehensive tags
   - Waits for the volume to become available
   - Saves the volume ID for subsequent scripts

### Step 2: Volume Attachment (1 minute)
1. **Run the volume attachment script**:
   ```bash
   ./02a-attach-volume.sh
   ```

2. **Explain the attachment process**:
   - Validates instance exists and is in the same AZ
   - Checks for device name conflicts
   - Attaches volume to the specified instance
   - Waits for attachment to complete
   - Shows updated block device mappings

### Step 3: Volume Modification (1.5 minutes)
1. **Run the volume modification script**:
   ```bash
   ./02b-modify-volume.sh
   ```

2. **Explain the modification process**:
   - Checks current volume properties
   - Calculates new size and cost implications
   - Initiates volume expansion (10GB → 15GB)
   - Monitors modification progress
   - Explains filesystem extension requirements

### Step 4: Volume Detachment (1 minute)
1. **Run the volume detachment script**:
   ```bash
   ./02c-detach-volume.sh
   ```

2. **Explain the detachment process**:
   - Checks if volume is safely detachable
   - Provides unmounting instructions
   - Safely detaches volume from instance
   - Waits for volume to become available
   - Shows final status

### Step 5: Cleanup (30 seconds)
1. **Run the cleanup script**:
   ```bash
   ./03-cleanup.sh
   ```

2. **Explain cleanup importance**:
   - Prevents unnecessary AWS charges
   - Optionally creates snapshots before deletion
   - Removes temporary files
   - Confirms all resources are cleaned up

### Conclusion (30 seconds)
"We've demonstrated the complete EBS volume lifecycle using modular AWS CLI scripts. Each script handles a specific operation, making them perfect for automation, troubleshooting, and educational purposes."

## Script Features

### Modular Design
- Each script performs a single, well-defined operation
- Scripts can be run independently or as part of a workflow
- Clear dependencies and prerequisites for each script
- Consistent interface and error handling across all scripts

### Error Handling
- All scripts use `set -e` for immediate error exit
- Comprehensive validation of prerequisites
- Graceful handling of common error conditions
- Clear error messages with suggested solutions

### User Experience
- Colored output for better readability
- Progress indicators for long-running operations
- Confirmation prompts for destructive operations
- Detailed status reporting and next steps

### Safety Features
- Automatic validation of AZ compatibility
- Device name conflict detection
- Root volume protection
- Optional snapshot creation before deletion
- Force operation flags for automation

### Automation Support
- Environment variable configuration
- Non-interactive modes available
- Structured output for parsing
- Exit codes for script chaining

## Configuration Options

### Environment Variables
```bash
# AWS Configuration
export AWS_REGION="us-east-1"              # AWS region
export AVAILABILITY_ZONE="us-east-1a"      # Target AZ

# Volume Configuration
export VOLUME_SIZE="10"                     # Size in GiB
export VOLUME_TYPE="gp3"                    # Volume type
export SIZE_INCREASE="5"                    # Size increase for modification

# Instance Configuration
export INSTANCE_ID="i-1234567890abcdef0"   # Target instance
export DEVICE_NAME="/dev/sdf"              # Device name

# Script Behavior
export DEMO_MODE="interactive"              # interactive or auto
export FORCE_DELETE="false"                # Skip confirmations
export FORCE_DETACH="false"                # Force volume detachment
```

## Workflow Examples

### Complete Workflow
```bash
# Set up environment
export INSTANCE_ID="i-1234567890abcdef0"
export AWS_REGION="us-east-1"

# Run complete demonstration
./run-demo.sh
```

### Custom Workflow
```bash
# Create a larger volume
export VOLUME_SIZE="50"
export VOLUME_TYPE="gp3"
./01-create-volume.sh

# Attach to specific device
export DEVICE_NAME="/dev/sdh"
./02a-attach-volume.sh

# Expand by 20 GiB
export SIZE_INCREASE="20"
./02b-modify-volume.sh

# Safely detach
./02c-detach-volume.sh

# Clean up
./03-cleanup.sh
```

### Automation Workflow
```bash
#!/bin/bash
# Automated EBS operations for CI/CD

export DEMO_MODE="auto"
export FORCE_DELETE="true"
export FORCE_DETACH="true"

# Create temporary storage
./01-create-volume.sh

# Attach for testing
export INSTANCE_ID="$TEST_INSTANCE_ID"
./02a-attach-volume.sh

# Run tests here...

# Clean up automatically
./02c-detach-volume.sh
./03-cleanup.sh
```

## Key CLI Commands Reference

### Essential Volume Operations
```bash
# Create volume
aws ec2 create-volume --volume-type gp3 --size 10 --availability-zone us-east-1a

# Attach volume
aws ec2 attach-volume --volume-id vol-xxx --instance-id i-xxx --device /dev/sdf

# Modify volume
aws ec2 modify-volume --volume-id vol-xxx --size 20

# Detach volume
aws ec2 detach-volume --volume-id vol-xxx

# Delete volume
aws ec2 delete-volume --volume-id vol-xxx
```

### Monitoring Commands
```bash
# Check volume status
aws ec2 describe-volumes --volume-ids vol-xxx

# Monitor modification progress
aws ec2 describe-volumes-modifications --volume-ids vol-xxx

# Wait for volume states
aws ec2 wait volume-available --volume-ids vol-xxx
aws ec2 wait volume-in-use --volume-ids vol-xxx
```

## Best Practices
- Always verify Availability Zone compatibility before attaching volumes
- Use tags for better organization and cost tracking
- Monitor volume modifications as they can take time to complete
- Unmount filesystems before detaching volumes
- Consider encryption for sensitive data
- Use appropriate volume types based on performance requirements
- Test scripts in non-production environments first

## Common Troubleshooting

### Script Issues
- **Permission denied**: Run `chmod +x *.sh` to make scripts executable
- **AWS CLI not found**: Install AWS CLI v2
- **Credentials error**: Run `aws configure` or set up IAM roles
- **Instance not found**: Verify instance ID and region
- **AZ mismatch**: Ensure volume and instance are in same AZ

### Volume Operation Issues
```bash
# Check volume limits
aws service-quotas get-service-quota \
    --service-code ec2 \
    --quota-code L-D18FCD1D

# Verify instance state
aws ec2 describe-instances --instance-ids i-xxx \
    --query 'Reservations[0].Instances[0].[State.Name,Placement.AvailabilityZone]'

# Check device mappings
aws ec2 describe-instances --instance-ids i-xxx \
    --query 'Reservations[0].Instances[0].BlockDeviceMappings[].[DeviceName,Ebs.VolumeId]'
```

### Recovery Procedures
```bash
# Force detach stuck volume
export FORCE_DETACH="true"
./02c-detach-volume.sh

# Clean up orphaned resources
aws ec2 describe-volumes \
    --filters "Name=tag:CreatedBy,Values=DemoScript" \
    --query 'Volumes[].[VolumeId,State]'
```

## Security Considerations
- Use IAM roles instead of access keys when possible
- Implement least privilege access for EBS operations
- Enable encryption for sensitive data
- Use AWS CloudTrail to audit volume operations
- Validate all user inputs in production scripts

## Cost Management
- Volumes incur charges even when not attached
- Use the cleanup script to avoid unnecessary costs
- Monitor volume modifications as they may affect pricing
- Consider snapshot costs when using backup features
- Use appropriate volume types for your performance needs

## Integration Examples

### CI/CD Pipeline Integration
```bash
#!/bin/bash
# Example CI/CD integration
export DEMO_MODE="auto"
export FORCE_DELETE="true"

# Create test storage
./01-create-volume.sh
./02a-attach-volume.sh

# Run application tests
run_tests_with_storage.sh

# Clean up automatically
./02c-detach-volume.sh
./03-cleanup.sh
```

### Monitoring Integration
```bash
#!/bin/bash
# Example monitoring script
VOLUME_ID=$(cat volume-id.txt)

# Check volume health
aws cloudwatch get-metric-statistics \
    --namespace AWS/EBS \
    --metric-name VolumeReadOps \
    --dimensions Name=VolumeId,Value=$VOLUME_ID \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Sum
```

## Documentation References
- [AWS CLI EC2 Commands](https://docs.aws.amazon.com/cli/latest/reference/ec2/)
- [create-volume CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-volume.html)
- [attach-volume CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/attach-volume.html)
- [modify-volume CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/modify-volume.html)
- [detach-volume CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/detach-volume.html)
- [Attach an Amazon EBS volume to an Amazon EC2 instance](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-attaching-volume.html)
- [Detach an Amazon EBS volume from an Amazon EC2 instance](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-detaching-volume.html)
- [Create an Amazon EBS volume](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-creating-volume.html)
- [Modify an Amazon EBS volume](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-modify-volume.html)
