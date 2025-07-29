# Demo 13.3: Create EFS File System Using Console

## Overview
This 5-minute demonstration shows how to create an Amazon Elastic File System (EFS) file system using the AWS Management Console. You'll learn about EFS configuration options and create a file system with recommended settings.

## Prerequisites
- AWS account with appropriate IAM permissions
- Access to AWS Management Console
- Basic understanding of VPC and subnets
- Default VPC available in your AWS region

## Demonstration Steps

### Step 1: Navigate to Amazon EFS Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **Services** → **Storage** → **EFS**
3. Click **Create file system**

### Step 2: Choose Creation Method (30 seconds)
You have two options:
- **Quick create**: Uses recommended settings (we'll use this for the demo)
- **Customize**: Allows you to configure all settings manually

Click **Quick create** for this demonstration.

### Step 3: Configure Basic Settings (2 minutes)
1. **Name**: Enter a descriptive name (e.g., "demo-efs-filesystem")
2. **VPC**: Select your default VPC (pre-selected)
3. **Availability and Durability**: 
   - **Regional** (recommended) - stores data across multiple AZs
   - **One Zone** - stores data in single AZ (lower cost)
4. Review the automatically configured settings:
   - **Performance mode**: General Purpose (lowest latency)
   - **Throughput mode**: Elastic (scales automatically)
   - **Encryption**: Enabled by default
   - **Lifecycle management**: 30 days to IA, 90 days to Archive

### Step 4: Review Network Settings (1 minute)
1. **Mount targets**: Automatically created in each Availability Zone
2. **Security groups**: Default security group is selected
3. **Subnets**: Default subnets are selected for each AZ
4. Note the **File system DNS name** that will be generated

### Step 5: Create the File System (1 minute)
1. Review all settings in the summary
2. Click **Create**
3. Wait for the file system to become **Available** (usually 1-2 minutes)
4. Note the **File system ID** (fs-xxxxxxxxx format)

### Step 6: Verify Creation and Explore Options (30 seconds)
1. Click on the newly created file system
2. Review the **Details** tab:
   - File system state
   - DNS name
   - Mount targets
   - Performance metrics
3. Explore other tabs:
   - **Network** - Mount target details
   - **Access points** - For fine-grained access control
   - **Replication** - For cross-region replication

## Key Configuration Options Explained

### File System Types
- **Regional**: Data stored across multiple AZs (higher availability)
- **One Zone**: Data stored in single AZ (lower cost, less availability)

### Performance Modes
- **General Purpose**: Lowest latency, recommended for most use cases
- **Max I/O**: Higher latency but supports more concurrent operations

### Throughput Modes
- **Elastic**: Automatically scales throughput (recommended)
- **Provisioned**: Fixed throughput amount
- **Bursting**: Throughput scales with file system size

### Encryption
- **At rest**: Encrypts stored data using AWS KMS
- **In transit**: Encrypts data during transfer (configured during mounting)

## Next Steps
After creating the file system, you can:
1. Mount it to EC2 instances
2. Configure access points for fine-grained access
3. Set up backup policies
4. Monitor performance metrics

## Cleanup Instructions
To avoid charges:
1. Unmount the file system from any EC2 instances
2. Delete any access points
3. In the EFS console, select the file system
4. Choose **Actions** → **Delete file system**
5. Type the file system ID to confirm deletion

## Estimated Costs
- EFS Standard storage: ~$0.30 per GB per month
- EFS Infrequent Access: ~$0.025 per GB per month
- EFS Archive: ~$0.0045 per GB per month
- Request charges apply for IA and Archive storage classes

## Documentation References
- [Getting started with Amazon EFS](https://docs.aws.amazon.com/efs/latest/ug/getting-started.html)
- [Creating EFS file systems](https://docs.aws.amazon.com/efs/latest/ug/creating-using-create-fs.html)
- [Amazon EFS performance specifications](https://docs.aws.amazon.com/efs/latest/ug/performance.html)
- [Amazon EFS pricing](https://aws.amazon.com/efs/pricing/)
