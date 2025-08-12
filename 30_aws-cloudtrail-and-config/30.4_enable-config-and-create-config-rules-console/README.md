# AWS Config and Config Rules Demonstration (Console)

## Overview
This 5-minute demonstration shows how to enable AWS Config and create Config Rules using the AWS Management Console. AWS Config provides configuration history, change notifications, and compliance monitoring for AWS resources.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- Some existing AWS resources (EC2 instances, S3 buckets, etc.) for Config to monitor
- Basic understanding of AWS services

## Pre-Demonstration Setup
Before starting the demonstration, run the setup check script to verify prerequisites:
```bash
./setup-check.sh
```

This script will:
- Verify AWS CLI configuration and credentials
- Check required permissions (Config, S3, SNS, IAM)
- Identify any existing Config configuration
- Check for AWS resources available to monitor
- Provide suggested resource names for the demo

## Demonstration Steps (5 minutes)

### Step 1: Navigate to AWS Config (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **Services** → **Management & Governance** → **Config**
3. Click on **Config** to open the service dashboard
4. If this is your first time, you'll see the "Get started" page

### Step 2: Set Up AWS Config (2 minutes)
1. Click **Get started** or **Settings** if Config is already partially configured
2. **Resource types to record**:
   - Select **Record all resources supported in this region**
   - Check **Include global resource types** (recommended)
3. **Amazon S3 bucket**:
   - Select **Create a bucket**
   - Bucket name will be auto-generated: `config-bucket-[account-id]-[region]`
4. **Amazon SNS topic** (optional):
   - Select **Create a topic**
   - Topic name: `config-topic`
5. **AWS Config role**:
   - Select **Create AWS Config service-linked role**

### Step 3: Review and Start Recording (30 seconds)
1. Review the configuration settings
2. Click **Next**
3. On the Rules page, click **Skip** for now (we'll add rules in the next step)
4. Click **Confirm** to start AWS Config
5. Wait for Config to initialize (shows "Setting up AWS Config...")

### Step 4: Create Config Rules (1.5 minutes)
1. Once Config is running, navigate to **Rules** in the left sidebar
2. Click **Add rule**
3. **Add your first rule**:
   - Search for `s3-bucket-public-access-prohibited`
   - Click on the rule to select it
   - Click **Next**
   - Leave default settings and click **Next**
   - Click **Add rule**
4. **Add a second rule**:
   - Click **Add rule** again
   - Search for `ec2-security-group-attached-to-eni`
   - Select the rule and click **Next**
   - Leave default settings and click **Next**
   - Click **Add rule**

### Step 5: View Configuration and Compliance (30 seconds)
1. Navigate to **Resources** to see discovered resources
2. Click on a resource to view its configuration timeline
3. Navigate to **Rules** to see compliance status
4. Show how rules evaluate resources and display compliance results
5. Demonstrate the **Dashboard** view showing overall compliance posture

## Post-Demonstration Validation
After completing the demonstration, validate that everything was configured correctly:
```bash
./validate-demo.sh
```

This script will:
- Verify the Config recorder exists and is recording
- Check delivery channel and S3 bucket configuration
- Validate Config rules are created and active
- Confirm resource discovery is working
- Check overall Config service status

## Key Features Demonstrated
- **Configuration Recording**: Tracks resource configurations and changes
- **Global Resource Types**: Monitors IAM users, roles, and policies
- **S3 Integration**: Stores configuration snapshots and history
- **Config Rules**: Automated compliance checking
- **Compliance Dashboard**: Visual representation of compliance status
- **Configuration Timeline**: Historical view of resource changes

## Expected Outcomes
- AWS Config successfully enabled and recording
- S3 bucket created for configuration storage
- Config rules created and evaluating resources
- Resources discovered and displayed in Config console
- Compliance status visible for monitored resources

## Config Rules Explained
- **s3-bucket-public-access-prohibited**: Checks that S3 buckets don't allow public access
- **ec2-security-group-attached-to-eni**: Verifies security groups are attached to network interfaces

## Troubleshooting
- **Permission errors**: Ensure your user has Config, S3, and IAM permissions
- **No resources showing**: Wait 10-15 minutes for initial discovery
- **Rules not evaluating**: Check that resources exist that match the rule scope
- **S3 bucket errors**: Ensure bucket names are globally unique

## Cost Considerations
- AWS Config charges per configuration item recorded
- S3 storage costs for configuration snapshots
- SNS charges for notifications (if enabled)
- See pricing details in documentation links below

## CLI Reference
For educational purposes, you can view the CLI equivalent commands:
```bash
./cli-reference.sh
```

This script shows the AWS CLI commands that would accomplish the same tasks as the console demonstration, useful for understanding the underlying API calls.

## Cleanup Instructions
After the demonstration, run the cleanup script to remove created resources:
```bash
./cleanup.sh
```

This script automatically removes all resources created during the demonstration without requiring user input.

## Available Scripts
- **setup-check.sh**: Pre-demonstration prerequisite verification
- **validate-demo.sh**: Post-demonstration validation and verification
- **cli-reference.sh**: Educational CLI command reference
- **cleanup.sh**: Automated resource cleanup

## Documentation References
- [AWS Config User Guide](https://docs.aws.amazon.com/config/latest/developerguide/)
- [Setting Up AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/gs-console.html)
- [AWS Config Rules](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config.html)
- [AWS Config Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)
- [Config Rule Examples](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)

## Additional Resources
- [AWS Config Pricing](https://aws.amazon.com/config/pricing/)
- [Config Best Practices](https://docs.aws.amazon.com/config/latest/developerguide/best-practices.html)
- [Config FAQ](https://aws.amazon.com/config/faq/)
- [Compliance by Config Rules](https://docs.aws.amazon.com/config/latest/developerguide/compliance-by-config-rules.html)
