# 12.3 Create EBS Volume - Console Demonstration

## Overview
This 5-minute demonstration shows how to create an Amazon Elastic Block Store (EBS) volume using the AWS Management Console. You'll learn about volume types, configuration options, and best practices for EBS volume creation.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- Basic understanding of AWS regions and Availability Zones

## Demonstration Script (5 minutes)

### Introduction (30 seconds)
"Today we'll create an Amazon EBS volume using the AWS Console. EBS provides persistent block storage for EC2 instances, and we'll walk through the key configuration options you need to understand."

### Step 1: Navigate to EBS Volumes (1 minute)
1. **Open the Amazon EC2 console** at https://console.aws.amazon.com/ec2/
2. **In the navigation pane**, choose **Volumes** under the "Elastic Block Store" section
3. **Click "Create volume"** button
4. **Point out** the current region and explain that volumes must be in the same AZ as the instance they'll attach to

### Step 2: Configure Volume Settings (2.5 minutes)
1. **Volume Type Selection**:
   - Show the default `gp3` (General Purpose SSD) selection
   - Briefly explain the different types: `gp3`, `gp2`, `io1`, `io2`, `st1`, `sc1`
   - Recommend `gp3` for most use cases due to better price-performance

2. **Size Configuration**:
   - Set size to **20 GiB** for demonstration
   - Mention the range: 1 GiB to 64 TiB depending on volume type
   - Explain cost implications of size selection

3. **IOPS and Throughput** (for gp3):
   - Show default IOPS (3,000) and throughput (125 MiB/s)
   - Explain these can be adjusted independently from size
   - Mention the 3:1 IOPS to GiB ratio baseline

4. **Availability Zone**:
   - Select an AZ (e.g., `us-east-1a`)
   - Emphasize this must match your target EC2 instance's AZ

5. **Snapshot Selection**:
   - Keep default "Don't create volume from a snapshot"
   - Briefly explain snapshot restore option

### Step 3: Security and Advanced Options (1 minute)
1. **Encryption**:
   - Show encryption toggle
   - Explain AWS managed keys vs. customer managed keys
   - Recommend enabling encryption for sensitive data

2. **Tags**:
   - Add a tag: Key=`Name`, Value=`Demo-EBS-Volume`
   - Add a tag: Key=`Environment`, Value=`Training`
   - Explain importance of tagging for cost management

3. **Multi-Attach** (if applicable):
   - Briefly mention this advanced feature for `io1`/`io2` volumes
   - Note it's not available for `gp3`

### Step 4: Create and Verify (1 minute)
1. **Review configuration** summary
2. **Click "Create volume"**
3. **Show the volume** in "creating" state, then "available" state
4. **Point out key information**:
   - Volume ID
   - State
   - Size and type
   - Availability Zone
   - Attachment information (currently "Not attached")

### Conclusion (30 seconds)
"We've successfully created an EBS volume. Next steps would be to attach this to an EC2 instance in the same Availability Zone. Remember that you're charged for EBS storage even when volumes aren't attached to instances."

## Key Learning Points
- EBS volumes must be created in the same AZ as target EC2 instances
- `gp3` is the recommended volume type for most workloads
- Encryption should be enabled for sensitive data
- Proper tagging helps with cost management and organization
- Volumes incur charges even when not attached

## Common Troubleshooting
- **Volume creation fails**: Check IAM permissions and service limits
- **Can't attach to instance**: Verify both are in the same Availability Zone
- **Performance issues**: Consider volume type and IOPS configuration

## Next Steps
After creating a volume, you would typically:
1. Attach the volume to an EC2 instance
2. Format the volume (if new)
3. Mount the volume to make it available for use

## Documentation References
- [Create an Amazon EBS volume](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-creating-volume.html)
- [Amazon EBS volume types](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html)
- [Amazon EBS volume constraints](https://docs.aws.amazon.com/ebs/latest/userguide/volume_constraints.html)
- [Amazon EBS encryption](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-encryption.html)
