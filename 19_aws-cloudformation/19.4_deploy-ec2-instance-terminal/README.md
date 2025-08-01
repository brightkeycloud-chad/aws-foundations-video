# Deploy EC2 Instance with SSM Session Manager using AWS CLI Terminal

## Demo Overview
This 5-minute demonstration shows how to deploy an EC2 instance running Amazon Linux 2023 with a web server and SSM Session Manager access using AWS CloudFormation via the AWS CLI in terminal.

## Prerequisites
- AWS CLI installed and configured
- Terminal/command line access
- Basic understanding of EC2 and SSM concepts
- IAM permissions for EC2, CloudFormation, and SSM

## Demo Script (5 minutes)

### Step 1: Verify AWS CLI Configuration (30 seconds)
```bash
# Check AWS CLI configuration
aws sts get-caller-identity

# Verify SSM service availability
aws ssm describe-instance-information --query 'InstanceInformationList[0]' || echo "No managed instances yet"
```

### Step 2: Validate CloudFormation Template (30 seconds)
```bash
# Navigate to the demo directory
cd /path/to/19.4_deploy-ec2-instance-terminal

# Validate the template syntax
aws cloudformation validate-template --template-body file://ec2-template.yaml
```

### Step 3: Deploy the Stack (2 minutes)
```bash
# Create the stack with parameters
aws cloudformation create-stack \
  --stack-name demo-ec2-stack \
  --template-body file://ec2-template.yaml \
  --parameters ParameterKey=InstanceType,ParameterValue=t3.micro \
  --capabilities CAPABILITY_IAM \
  --tags Key=Environment,Value=Demo Key=Purpose,Value=Training
```

### Step 4: Monitor Stack Creation (1.5 minutes)
```bash
# Check stack status
aws cloudformation describe-stacks --stack-name demo-ec2-stack --query 'Stacks[0].StackStatus'

# Watch stack events in real-time
aws cloudformation describe-stack-events --stack-name demo-ec2-stack --query 'StackEvents[*].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId]' --output table

# Wait for stack completion (optional)
aws cloudformation wait stack-create-complete --stack-name demo-ec2-stack
```

### Step 5: Retrieve Stack Outputs (30 seconds)
```bash
# Get stack outputs
aws cloudformation describe-stacks --stack-name demo-ec2-stack --query 'Stacks[0].Outputs' --output table

# Get specific output values
aws cloudformation describe-stacks --stack-name demo-ec2-stack --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' --output text
```

### Step 6: Test the Deployed Resources (30 seconds)
```bash
# Get the website URL
WEBSITE_URL=$(aws cloudformation describe-stacks --stack-name demo-ec2-stack --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' --output text)

# Test the web server
curl $WEBSITE_URL

# Or open in browser (macOS)
open $WEBSITE_URL
```

### Step 7: Connect via SSM Session Manager (30 seconds)
```bash
# Get the instance ID
INSTANCE_ID=$(aws cloudformation describe-stacks --stack-name demo-ec2-stack --query 'Stacks[0].Outputs[?OutputKey==`InstanceId`].OutputValue' --output text)

# Connect to the instance using SSM Session Manager
aws ssm start-session --target $INSTANCE_ID

# Once connected, you can run commands like:
# sudo systemctl status httpd
# curl localhost
# exit
```

## Alternative Commands for Different Scenarios

### Using Parameter File
Create a `parameters.json` file:
```json
[
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t3.micro"
  }
]
```

Deploy using parameter file:
```bash
aws cloudformation create-stack \
  --stack-name demo-ec2-stack \
  --template-body file://ec2-template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_IAM \
  --tags Key=Environment,Value=Demo
```

### Using S3 Template URL
```bash
# Upload template to S3 first
aws s3 cp ec2-template.yaml s3://your-bucket/templates/

# Deploy from S3
aws cloudformation create-stack \
  --stack-name demo-ec2-stack \
  --template-url https://your-bucket.s3.amazonaws.com/templates/ec2-template.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=YOUR_KEY_PAIR_NAME
```

## Expected Results
After successful deployment, you will have:
- 1 EC2 instance running the latest Amazon Linux 2023
- 1 Security group allowing HTTP (port 80) access only
- 1 IAM role with SSM Session Manager permissions
- 1 Instance profile attached to the EC2 instance
- Apache web server installed and running
- Secure shell access via SSM Session Manager (no SSH keys required)
- A simple web page displaying instance metadata and OS information

## Cleanup
```bash
# Delete the stack
aws cloudformation delete-stack --stack-name demo-ec2-stack

# Wait for deletion to complete
aws cloudformation wait stack-delete-complete --stack-name demo-ec2-stack

# Verify deletion
aws cloudformation describe-stacks --stack-name demo-ec2-stack
```

## Key Learning Points
- AWS CLI provides programmatic access to CloudFormation
- Template validation catches syntax errors before deployment
- Stack events provide real-time deployment feedback
- Parameters allow template reuse across environments
- Outputs provide access to created resource information
- CLI commands can be scripted for automation
- **Dynamic AMI lookup** using Systems Manager Parameter Store ensures latest AMI versions
- **Amazon Linux 2023** uses `dnf` package manager instead of `yum`
- **SSM Session Manager** provides secure shell access without SSH keys or open ports
- **IAM roles and instance profiles** enable secure AWS service access from EC2 instances
- **CAPABILITY_IAM** flag is required when creating IAM resources
- **IMDSv2** (Instance Metadata Service v2) requires token-based authentication for security

## Troubleshooting
- **CAPABILITY_IAM error**: Add `--capabilities CAPABILITY_IAM` to the create-stack command
- **Template validation errors**: Check YAML syntax and resource properties
- **Permission errors**: Ensure AWS credentials have EC2, CloudFormation, IAM, and SSM permissions
- **SSM Session Manager connection fails**: Wait 2-3 minutes after instance launch for SSM agent to register
- **Instance not appearing in SSM**: Check that the IAM role has AmazonSSMManagedInstanceCore policy
- **Stack creation failures**: Check CloudFormation events for detailed error messages
- **Missing metadata on web page**: Check UserData execution logs (see debugging section below)

### Debugging UserData Issues
If the web page doesn't show instance metadata:

```bash
# Connect to instance via SSM
INSTANCE_ID=$(aws cloudformation describe-stacks --stack-name demo-ec2-stack --query 'Stacks[0].Outputs[?OutputKey==`InstanceId`].OutputValue' --output text)
aws ssm start-session --target $INSTANCE_ID

# Once connected, check UserData logs
sudo cat /var/log/user-data.log

# Check Apache status
sudo systemctl status httpd

# Check web page content
cat /var/www/html/index.html

# Test metadata access manually
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)
curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id
```

## Advanced Usage
```bash
# Update an existing stack
aws cloudformation update-stack \
  --stack-name demo-ec2-stack \
  --template-body file://ec2-template.yaml \
  --parameters ParameterKey=InstanceType,ParameterValue=t3.small

# Create change set for preview
aws cloudformation create-change-set \
  --stack-name demo-ec2-stack \
  --template-body file://ec2-template.yaml \
  --change-set-name demo-changeset \
  --parameters ParameterKey=InstanceType,ParameterValue=t3.small
```

## Dynamic AMI Lookup
This template uses AWS Systems Manager Parameter Store to automatically retrieve the latest Amazon Linux 2023 AMI ID:

```yaml
ImageId: !Sub '{{resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64}}'
```

**Benefits:**
- Always uses the latest AMI version
- No need to maintain region-specific AMI mappings
- Automatic security updates and patches
- Works across all AWS regions

**Alternative Parameter Store paths:**
```bash
# View available Amazon Linux AMI parameters
aws ssm get-parameters-by-path \
  --path "/aws/service/ami-amazon-linux-latest" \
  --query "Parameters[*].Name"

# Get current AMI ID directly
aws ssm get-parameter \
  --name "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" \
  --query "Parameter.Value" --output text
```

## Instance Metadata Service v2 (IMDSv2)
Amazon Linux 2023 enforces IMDSv2 by default for enhanced security. The UserData script handles this automatically:

**IMDSv2 Token-Based Access:**
```bash
# Get token first
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)

# Use token to access metadata
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  -s http://169.254.169.254/latest/meta-data/instance-id
```

**Security Benefits:**
- Prevents SSRF (Server-Side Request Forgery) attacks
- Requires intentional token request
- Token has configurable TTL (Time To Live)
- Backward compatibility with IMDSv1 as fallback

**Common Metadata Endpoints:**
- Instance ID: `/latest/meta-data/instance-id`
- Availability Zone: `/latest/meta-data/placement/availability-zone`
- Instance Type: `/latest/meta-data/instance-type`
- Public IP: `/latest/meta-data/public-ipv4`
- Security Groups: `/latest/meta-data/security-groups`

## SSM Session Manager Benefits
**Secure Access:**
- No SSH keys to manage or lose
- No need to open port 22 in security groups
- All session activity is logged in CloudTrail

**Network Security:**
- Works through NAT Gateways and private subnets
- No direct internet access required for the instance
- Encrypted communication channel

**Convenience:**
- Access from anywhere with AWS CLI
- No bastion hosts or VPN required
- Integrated with AWS IAM for access control

**Session Commands:**
```bash
# Start a session
aws ssm start-session --target i-1234567890abcdef0

# Run a single command
aws ssm send-command \
  --instance-ids i-1234567890abcdef0 \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["sudo systemctl status httpd"]'

# Copy files to/from instance (requires Session Manager plugin)
aws ssm start-session --target i-1234567890abcdef0 --document-name AWS-StartPortForwardingSession --parameters portNumber=22,localPortNumber=2222
```

## Documentation References
- [AWS CLI CloudFormation Commands](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/)
- [create-stack CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/create-stack.html)
- [AWS::EC2::Instance](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-ec2-instance.html)
- [AWS::EC2::SecurityGroup](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-ec2-security-group.html)
- [AWS::IAM::Role](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-iam-role.html)
- [AWS::IAM::InstanceProfile](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-iam-instanceprofile.html)
- [Amazon EC2 CloudFormation template snippets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-ec2.html)
- [Amazon Linux 2023 User Guide](https://docs.aws.amazon.com/linux/al2023/ug/what-is-amazon-linux.html)
- [Systems Manager Parameter Store for AMI IDs](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html)
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Session Manager Prerequisites](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-prerequisites.html)
