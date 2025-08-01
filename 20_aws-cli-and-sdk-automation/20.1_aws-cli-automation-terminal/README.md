# AWS CLI Automation Terminal Demonstration

## Overview
This 5-minute demonstration showcases essential AWS CLI automation capabilities, including S3 bucket management, EC2 instance operations, and IAM user management. Participants will learn how to use AWS CLI commands for common cloud infrastructure tasks.

## Prerequisites
- AWS CLI v2 installed and configured
- AWS account with appropriate permissions
- Terminal/command line access
- Valid AWS credentials configured (`aws configure`)

## Demonstration Script (5 minutes)

### Part 1: Setup and Verification (1 minute)
```bash
# Verify AWS CLI installation and configuration
aws --version
aws sts get-caller-identity

# Set variables for the demo
DEMO_BUCKET="aws-cli-demo-$(date +%s)"
DEMO_REGION="us-east-1"
```

### Part 2: S3 Bucket Operations (2 minutes)
```bash
# Create an S3 bucket
aws s3 mb s3://$DEMO_BUCKET --region $DEMO_REGION

# List all buckets
aws s3 ls

# Create a sample file and upload it
echo "Hello AWS CLI Demo!" > demo-file.txt
aws s3 cp demo-file.txt s3://$DEMO_BUCKET/

# List bucket contents
aws s3 ls s3://$DEMO_BUCKET/

# Download the file with a new name
aws s3 cp s3://$DEMO_BUCKET/demo-file.txt downloaded-file.txt

# Sync a directory (create sample directory first)
mkdir sample-dir
echo "File 1" > sample-dir/file1.txt
echo "File 2" > sample-dir/file2.txt
aws s3 sync sample-dir/ s3://$DEMO_BUCKET/sample-dir/
```

### Part 3: EC2 Instance Management (1.5 minutes)
```bash
# List available AMIs (Amazon Linux 2023)
aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=al2023-ami-*" \
    --query 'Images[0].ImageId' \
    --output text

# Get default VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=is-default,Values=true" \
    --query 'Vpcs[0].VpcId' \
    --output text)

# List EC2 instances
aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' \
    --output table

# Create a security group (optional - for demo purposes)
aws ec2 create-security-group \
    --group-name demo-sg \
    --description "Demo security group" \
    --vpc-id $VPC_ID
```

### Part 4: IAM Operations (0.5 minutes)
```bash
# List IAM users
aws iam list-users --query 'Users[*].[UserName,CreateDate]' --output table

# List IAM roles
aws iam list-roles --query 'Roles[*].[RoleName,CreateDate]' --output table
```

### Part 5: Cleanup and Advanced Features Demo
```bash
# Show AWS CLI help
aws s3 help

# Use JMESPath queries for filtering
aws ec2 describe-instances \
    --query 'Reservations[*].Instances[?State.Name==`running`].[InstanceId,InstanceType]' \
    --output table

# Cleanup - Remove S3 bucket and contents
aws s3 rm s3://$DEMO_BUCKET --recursive
aws s3 rb s3://$DEMO_BUCKET

# Remove local files
rm -f demo-file.txt downloaded-file.txt
rm -rf sample-dir/

# Remove security group (if created)
aws ec2 delete-security-group --group-name demo-sg
```

## Key Learning Points
1. **AWS CLI Configuration**: Proper setup and credential management
2. **S3 Operations**: Bucket creation, file upload/download, and synchronization
3. **EC2 Management**: Instance listing and basic operations
4. **Output Formatting**: Using `--query` and `--output` for customized results
5. **Cleanup**: Proper resource cleanup to avoid charges

## Common Commands Reference
```bash
# Configuration
aws configure                    # Configure AWS CLI
aws sts get-caller-identity     # Verify current user/role

# S3 Commands
aws s3 ls                       # List buckets
aws s3 mb s3://bucket-name      # Create bucket
aws s3 cp file.txt s3://bucket/ # Upload file
aws s3 sync ./dir s3://bucket/  # Sync directory

# EC2 Commands
aws ec2 describe-instances      # List instances
aws ec2 describe-images         # List AMIs
aws ec2 run-instances          # Launch instance

# IAM Commands
aws iam list-users             # List users
aws iam list-roles             # List roles
```

## Troubleshooting Tips
- Ensure AWS credentials are properly configured
- Check region settings if resources aren't appearing
- Use `--dry-run` flag for testing commands safely
- Use `aws logs` commands to debug issues

## Additional Resources and Citations

### AWS Documentation References
1. **AWS CLI Getting Started Guide**: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
2. **Using Amazon S3 in the AWS CLI**: https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3.html
3. **AWS CLI Command Reference**: https://docs.aws.amazon.com/cli/latest/reference/
4. **AWS CLI Configuration Guide**: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
5. **AWS CLI Output Formatting**: https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output-format.html

### Best Practices Documentation
- **AWS CLI Best Practices**: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-using.html
- **AWS Security Best Practices**: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html

---
*This demonstration is designed for educational purposes. Always follow your organization's AWS usage policies and clean up resources after demonstrations to avoid unnecessary charges.*
