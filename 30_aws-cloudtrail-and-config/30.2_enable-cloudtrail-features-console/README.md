# AWS CloudTrail Features Demonstration (Console)

## Overview
This 5-minute demonstration shows how to enable AWS CloudTrail and configure its key features using the AWS Management Console. CloudTrail provides governance, compliance, and operational auditing of your AWS account by recording AWS API calls.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- Basic understanding of AWS services

## Pre-Demonstration Setup
Before starting the demonstration, run the setup check script to verify prerequisites:
```bash
./setup-check.sh
```

This script will:
- Verify AWS CLI configuration and credentials
- Check required permissions (CloudTrail, S3, IAM, CloudWatch)
- Identify any existing CloudTrail configuration
- Provide suggested resource names for the demo

## Demonstration Steps (5 minutes)

### Step 1: Navigate to CloudTrail (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **Services** → **Management & Governance** → **CloudTrail**
3. Click on **CloudTrail** to open the service dashboard

### Step 2: Create a New Trail (2 minutes)
1. Click **Create trail** button
2. Configure trail settings:
   - **Trail name**: `demo-cloudtrail-trail`
   - **Apply trail to all regions**: Select **Yes** (recommended)
   - **Management events**: Select **All** (Read and Write)
   - **Data events**: Leave unchecked for this demo (optional)
   - **Insight events**: Leave unchecked for this demo (optional)

### Step 3: Configure Storage Location (1.5 minutes)
1. **S3 bucket**: 
   - Select **Create new S3 bucket**
   - **S3 bucket name**: `cloudtrail-logs-demo-[your-account-id]-[random-suffix]`
   - **Log file prefix**: `cloudtrail-logs/`
2. **Log file encryption**: 
   - Check **Encrypt log files with SSE-S3**
3. **Log file validation**: 
   - Check **Enable log file validation** (recommended)

### Step 4: Configure CloudWatch Logs (Optional - 30 seconds)
1. **CloudWatch Logs**: 
   - Check **Send CloudTrail events to CloudWatch Logs**
   - **Log group**: `CloudTrail/demo-trail`
   - **IAM Role**: Select **New** and use default name

### Step 5: Review and Create (30 seconds)
1. Review all settings
2. Click **Create trail**
3. Verify trail is created and logging is enabled
4. Show the trail dashboard with recent events

## Post-Demonstration Validation
After completing the demonstration, validate that everything was configured correctly:
```bash
./validate-demo.sh
```

This script will:
- Verify the CloudTrail trail exists and is logging
- Check S3 bucket configuration and log files
- Validate CloudWatch Logs integration (if configured)
- Confirm recent events are being captured

## Key Features Demonstrated
- **Multi-region logging**: Captures events from all AWS regions
- **Management events**: Records control plane operations
- **S3 integration**: Stores logs in S3 bucket for long-term retention
- **Log file validation**: Ensures log integrity
- **Encryption**: Protects log files at rest

## Expected Outcomes
- CloudTrail trail successfully created and active
- S3 bucket created for log storage
- Events begin appearing in CloudTrail console within 15 minutes
- Log files delivered to S3 bucket

## Troubleshooting
- **Permission errors**: Ensure your user has CloudTrail and S3 permissions
- **S3 bucket name conflicts**: Use a unique suffix if bucket name is taken
- **No events showing**: Wait 15 minutes for first events to appear

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
- [AWS CloudTrail User Guide](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/)
- [Creating a Trail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-create-and-update-a-trail.html)
- [CloudTrail Log File Examples](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-examples.html)
- [CloudTrail Supported Services](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-aws-service-specific-topics.html)

## Additional Resources
- [CloudTrail Pricing](https://aws.amazon.com/cloudtrail/pricing/)
- [CloudTrail Best Practices](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/best-practices-security.html)
- [CloudTrail FAQ](https://aws.amazon.com/cloudtrail/faqs/)
