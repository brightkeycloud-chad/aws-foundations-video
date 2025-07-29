# AWS CLI Installation and Configuration Demonstration

## Overview
This 5-minute demonstration shows how to install the AWS CLI version 2 and configure it for first-time use. The AWS CLI is a unified tool to manage AWS services from the command line.

## Prerequisites
- Terminal access (macOS Terminal, Linux shell, or Windows PowerShell/Command Prompt)
- Internet connection for downloading the installer
- AWS account with programmatic access credentials
- Administrator/sudo privileges for installation

## Demonstration Steps (5 minutes)

### Step 1: Check Current Installation (30 seconds)
1. Check if AWS CLI is already installed:
   ```bash
   aws --version
   ```
2. If installed, note the version. AWS CLI v2 is recommended.

### Step 2: Install AWS CLI v2 (2 minutes)

#### For macOS:
```bash
# Download the installer
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"

# Install using the GUI installer (double-click) or command line:
sudo installer -pkg AWSCLIV2.pkg -target /
```

#### For Linux (x86_64):
```bash
# Download and install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### For Windows:
```powershell
# Download the MSI installer from:
# https://awscli.amazonaws.com/AWSCLIV2.msi
# Run the installer with administrative privileges
```

### Step 3: Verify Installation (30 seconds)
1. Verify the installation:
   ```bash
   aws --version
   ```
2. Check the installation path:
   ```bash
   which aws
   ```

### Step 4: Configure AWS CLI (2 minutes)
1. Start the configuration process:
   ```bash
   aws configure
   ```

2. Enter your AWS credentials when prompted:
   ```
   AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
   AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
   Default region name [None]: us-east-1
   Default output format [None]: json
   ```

3. Verify the configuration:
   ```bash
   aws configure list
   ```

### Step 5: Test the Configuration (1 minute)
1. Test with a simple AWS command:
   ```bash
   aws sts get-caller-identity
   ```

2. List S3 buckets (if you have S3 permissions):
   ```bash
   aws s3 ls
   ```

3. Show configuration files location:
   ```bash
   # On macOS/Linux
   ls -la ~/.aws/
   cat ~/.aws/config
   cat ~/.aws/credentials
   
   # On Windows
   dir %USERPROFILE%\.aws
   ```

## Configuration Methods Explained

### Method 1: Interactive Configuration
- Use `aws configure` for basic setup
- Stores credentials in `~/.aws/credentials`
- Stores configuration in `~/.aws/config`

### Method 2: Environment Variables
```bash
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=us-east-1
export AWS_DEFAULT_OUTPUT=json
```

### Method 3: Configuration Files
Create files manually:
```bash
# ~/.aws/credentials
[default]
aws_access_key_id = your-access-key
aws_secret_access_key = your-secret-key

# ~/.aws/config
[default]
region = us-east-1
output = json
```

## Key Configuration Options

### Output Formats
- `json` (default) - JSON format
- `yaml` - YAML format  
- `yaml-stream` - YAML stream format
- `text` - Tab-delimited text
- `table` - ASCII table format

### Common Regions
- `us-east-1` - US East (N. Virginia)
- `us-west-2` - US West (Oregon)
- `eu-west-1` - Europe (Ireland)
- `ap-southeast-1` - Asia Pacific (Singapore)

## Security Best Practices
- Never share your access keys
- Use IAM roles when possible (especially for EC2 instances)
- Rotate access keys regularly
- Use least privilege principle for IAM policies
- Consider using AWS IAM Identity Center (SSO) for multiple accounts
- Store credentials securely, never in code repositories

## Troubleshooting Common Issues

### Permission Denied Errors
```bash
# Check your credentials
aws sts get-caller-identity

# Verify IAM permissions in AWS Console
```

### Region-Related Errors
```bash
# Set region explicitly
aws s3 ls --region us-east-1

# Or configure default region
aws configure set region us-east-1
```

### SSL Certificate Errors
```bash
# For corporate networks with proxy
aws configure set ca_bundle /path/to/certificate.pem
```

## Advanced Configuration

### Multiple Profiles
```bash
# Configure additional profile
aws configure --profile production

# Use specific profile
aws s3 ls --profile production
```

### Named Profiles in Config Files
```bash
# ~/.aws/config
[profile production]
region = us-west-2
output = table

[profile development]  
region = us-east-1
output = json
```

## Verification Commands
```bash
# Check configuration
aws configure list
aws configure list --profile production

# Test connectivity
aws sts get-caller-identity
aws ec2 describe-regions --output table

# Check available services
aws help
```

## Documentation References
1. [Installing or updating to the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - Official installation guide
2. [Getting started with the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) - Complete getting started guide
3. [Configuring settings for the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) - Configuration options and methods
4. [Authentication and access credentials for the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html) - Credential management
5. [Using named profiles with the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) - Multiple profile configuration

## Additional Resources
- [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/) - Complete command documentation
- [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/) - Comprehensive user guide
- [AWS CLI GitHub Repository](https://github.com/aws/aws-cli) - Source code and issues
- [AWS CLI Changelog](https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst) - Version history and updates
