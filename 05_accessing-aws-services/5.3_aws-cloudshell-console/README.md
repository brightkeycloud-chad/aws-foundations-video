# AWS CloudShell Console Demonstration

## Overview
This 5-minute demonstration shows how to access and use AWS CloudShell directly from the AWS Management Console. AWS CloudShell is a browser-based shell that provides a pre-configured environment with AWS CLI, development tools, and 1 GB of persistent storage.

## Prerequisites
- AWS account with appropriate permissions
- IAM user/role with `AWSCloudShellFullAccess` policy attached
- Basic S3 permissions (`s3:CreateBucket`, `s3:PutObject`) for the demonstration

## Demonstration Steps (5 minutes)

### Step 1: Access AWS CloudShell (1 minute)
1. Sign in to the AWS Management Console
2. In the top navigation bar, click the CloudShell icon (terminal icon) next to the search bar
3. Select your preferred AWS Region from the region selector
4. Wait for CloudShell to initialize (this may take 30-60 seconds on first launch)

### Step 2: Explore the CloudShell Environment (1 minute)
1. Once CloudShell loads, run basic commands to explore:
   ```bash
   pwd
   ls -la
   whoami
   aws --version
   ```
2. Show the pre-installed tools:
   ```bash
   python3 --version
   node --version
   git --version
   ```

### Step 3: Create and Work with Files (1.5 minutes)
1. Create a simple Python script:
   ```bash
   mkdir demo-folder
   cd demo-folder
   ```
2. Create a simple Python file using the built-in editor:
   ```bash
   cat > hello.py << 'EOF'
   import sys
   name = sys.argv[1] if len(sys.argv) > 1 else "World"
   print(f"Hello, {name}!")
   EOF
   ```
3. Run the Python script:
   ```bash
   python3 hello.py AWS
   ```

### Step 4: Use AWS CLI Commands (1.5 minutes)
1. Check your current AWS identity:
   ```bash
   aws sts get-caller-identity
   ```
2. List available S3 buckets:
   ```bash
   aws s3 ls
   ```
3. Create a new S3 bucket (use a unique name):
   ```bash
   aws s3 mb s3://cloudshell-demo-$(date +%s)
   ```
4. Upload the Python file to S3:
   ```bash
   aws s3 cp hello.py s3://cloudshell-demo-$(date +%s)/hello.py
   ```

### Step 5: Demonstrate Persistent Storage (30 seconds)
1. Show that files persist across sessions:
   ```bash
   echo "This file will persist" > persistent-file.txt
   ls -la
   ```
2. Explain that the home directory (1 GB) persists between CloudShell sessions
3. Mention that sessions timeout after 20 minutes of inactivity

## Key Features to Highlight
- **No Installation Required**: Runs directly in the browser
- **Pre-configured Environment**: AWS CLI, Python, Node.js, Git, and more
- **Persistent Storage**: 1 GB home directory that persists across sessions
- **Secure Access**: Uses your existing AWS credentials automatically
- **Multiple Regions**: Available in most AWS regions
- **File Upload/Download**: Easy file transfer between local machine and CloudShell

## Best Practices
- Use CloudShell for quick AWS CLI tasks and testing
- Remember the 1 GB storage limit for persistent files
- Sessions timeout after 20 minutes of inactivity
- Use for development and testing, not production workloads
- Take advantage of pre-installed development tools

## Troubleshooting Tips
- If CloudShell doesn't load, check your IAM permissions
- Ensure you're in a supported AWS region
- Clear browser cache if experiencing issues
- Use the refresh button in CloudShell if the session becomes unresponsive

## Documentation References
1. [Getting started with AWS CloudShell](https://docs.aws.amazon.com/cloudshell/latest/userguide/getting-started.html) - Official AWS CloudShell getting started guide
2. [AWS CloudShell Concepts](https://docs.aws.amazon.com/cloudshell/latest/userguide/working-with-aws-cloudshell.html) - Understanding CloudShell interface and concepts
3. [Running commands in CloudShell from AWS Service consoles](https://docs.aws.amazon.com/cloudshell/latest/userguide/cloudshell-commands.html) - Integration with other AWS services
4. [Troubleshooting AWS CloudShell](https://docs.aws.amazon.com/cloudshell/latest/userguide/troubleshooting.html) - Common issues and solutions

## Additional Resources
- [AWS CloudShell User Guide](https://docs.aws.amazon.com/cloudshell/latest/userguide/) - Complete documentation
- [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/) - AWS CLI commands available in CloudShell
