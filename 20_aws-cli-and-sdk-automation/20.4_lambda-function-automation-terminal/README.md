# Lambda Function Automation Terminal Demonstration

## Overview
This 5-minute demonstration showcases AWS Lambda function automation using both AWS CLI and Python SDK (Boto3). Participants will learn to create, deploy, invoke, and manage Lambda functions programmatically, including automated deployment pipelines and monitoring.

## Prerequisites
- AWS CLI v2 installed and configured
- Python 3.8+ installed
- Boto3 library installed (`pip install boto3`)
- AWS account with Lambda execution permissions
- IAM role for Lambda execution
- Basic understanding of serverless computing

## Setup Instructions
```bash
# Install required packages
pip install boto3 requests

# Verify AWS CLI and Python setup
aws --version
python --version
python -c "import boto3; print('Boto3 version:', boto3.__version__)"
```

## Demonstration Files
This demonstration includes the following executable files:
- `lambda_function.py` - Sample Lambda function code with multiple event handlers
- `lambda_automation.py` - Python-based Lambda deployment and management automation
- `lambda_cli_demo.sh` - CLI-based Lambda function deployment demonstration
- `advanced_lambda_features.sh` - Advanced Lambda features and service exploration
- `trust-policy.json` - IAM trust policy for Lambda execution role
- `test-payload.json` - Sample JSON payload for Lambda function testing
- `cleanup.sh` - Comprehensive cleanup script for all demonstration resources

## Demonstration Script (5 minutes)

### Part 1: Python-Based Lambda Automation (2.5 minutes)

The main Python automation script (`lambda_automation.py`) demonstrates:
- **IAM role creation** with proper Lambda execution permissions
- **Deployment package creation** with ZIP file handling
- **Function deployment** with environment variables and tags
- **Function testing** with multiple event types
- **Monitoring and logging** integration
- **Function updates** and configuration changes
- **Resource cleanup** automation

```bash
# Run the Python Lambda automation
python lambda_automation.py
```

Key features demonstrated:
1. **Automated IAM role creation** - Creates execution role with necessary permissions
2. **ZIP package creation** - Packages Lambda function code automatically
3. **Function deployment** - Deploys with proper configuration and tags
4. **Multi-event testing** - Tests different invocation patterns
5. **CloudWatch integration** - Retrieves and displays function logs
6. **Configuration updates** - Demonstrates function modification
7. **Complete cleanup** - Removes all created resources

### Part 2: CLI-Based Lambda Operations (1.5 minutes)

The CLI demonstration script (`lambda_cli_demo.sh`) shows:
- **Simple function creation** using AWS CLI commands
- **Role and policy management** via CLI
- **Function invocation** and response handling
- **Function listing** and configuration display
- **Resource cleanup** with proper error handling

```bash
# Run the CLI Lambda demonstration
./lambda_cli_demo.sh
```

This script demonstrates:
1. **IAM role creation** using CLI commands
2. **Policy attachment** for Lambda execution
3. **Function deployment** from ZIP file
4. **Function invocation** with payload
5. **Function listing** and filtering
6. **Configuration inspection** with formatted output

### Part 3: Execute Complete Demonstration (1 minute)

```bash
# Run Python automation first
echo "=== Python Lambda Automation ==="
python lambda_automation.py

echo
echo "=== CLI Lambda Demo ==="
./lambda_cli_demo.sh

echo
echo "=== Advanced Features ==="
./advanced_lambda_features.sh
```

## Lambda Function Features

### Sample Lambda Function (`lambda_function.py`)
The demonstration Lambda function includes:
- **Multiple event handlers** for different trigger types:
  - S3 event processing
  - API Gateway request handling
  - Direct invocation processing
- **Business logic simulation** with data processing
- **Health check functionality** for monitoring
- **Comprehensive logging** throughout execution
- **Error handling** with proper HTTP responses

### Event Types Supported
1. **S3 Events** - Processes S3 bucket notifications
2. **API Gateway Events** - Handles HTTP requests with CORS
3. **Direct Invocations** - Processes custom event payloads
4. **Health Checks** - Provides system status information

## Key Learning Points
1. **Lambda Deployment**: Automated function creation and deployment
2. **IAM Integration**: Proper role creation and permission management
3. **Function Testing**: Automated testing with different event types
4. **Monitoring**: Log analysis and function metrics
5. **Version Management**: Function updates and configuration changes
6. **Resource Cleanup**: Automated cleanup to prevent charges
7. **CLI vs SDK**: Comparison of different automation approaches

## Automation Features Demonstrated
- **IAM role automation** with trust policies and permission attachment
- **Deployment package creation** with ZIP file handling
- **Function configuration** with environment variables and tags
- **Multi-event testing** with different payload types
- **Log monitoring** with CloudWatch integration
- **Function updates** and configuration management
- **Resource cleanup** with comprehensive error handling

## AWS Services Integration
- **AWS Lambda**: Core serverless compute service
- **IAM**: Role and permission management for function execution
- **CloudWatch Logs**: Function logging and monitoring
- **S3**: Event-driven processing capabilities (demonstrated)
- **API Gateway**: HTTP event handling (demonstrated)

## Best Practices Shown
- Always create dedicated IAM roles for Lambda functions
- Use environment variables for configuration management
- Implement comprehensive logging for debugging and monitoring
- Tag resources for better organization and cost tracking
- Test functions with multiple event types during development
- Implement proper error handling and response formatting
- Clean up resources after demonstrations to avoid charges
- Use deployment packages for code organization

## Resource Cleanup

### Comprehensive Cleanup Script
The demonstration includes a comprehensive cleanup script (`cleanup.sh`) that can remove all resources created during the demonstrations:

```bash
# Clean up all demo resources (recommended after demonstrations)
./cleanup.sh

# Clean up resources in a specific region
./cleanup.sh --region us-west-2

# Dry run to see what would be deleted without actually deleting
./cleanup.sh --dry-run

# Clean up only specific resource types
./cleanup.sh --functions    # Lambda functions only
./cleanup.sh --iam         # IAM roles only
./cleanup.sh --local       # Local files only

# Show help and all options
./cleanup.sh --help
```

### What the Cleanup Script Removes
- **Lambda functions** with 'demo-lambda-function' or 'cli-demo-function' in the name
- **IAM roles** with 'demo-lambda-role' or 'cli-demo-role' in the name
- **Attached IAM policies** from demo roles
- **CloudWatch log groups** for demo Lambda functions
- **Local temporary files** created during demonstrations (ZIP files, response files, etc.)

### Safety Features
- **Confirmation prompt** before deletion (unless using --dry-run)
- **Dry run mode** to preview what would be deleted
- **Selective cleanup** options for specific resource types
- **Error handling** with informative messages
- **Resource verification** after cleanup completion

## Usage Instructions

### Running the Demonstrations
1. Ensure all prerequisites are met
2. Navigate to the demonstration directory
3. Run the scripts in the suggested order:
   ```bash
   # Python automation (comprehensive)
   python lambda_automation.py
   
   # CLI demonstration (alternative approach)
   ./lambda_cli_demo.sh
   
   # Advanced features exploration
   ./advanced_lambda_features.sh
   ```

### Customizing the Demonstrations
- Modify the Lambda function code in `lambda_function.py` for different use cases
- Adjust the `REGION` variable in scripts for different AWS regions
- Customize function names and configurations in the automation scripts
- Add additional test events or modify existing ones
- Extend the monitoring capabilities with additional CloudWatch metrics

## Troubleshooting Tips
- Ensure AWS credentials have necessary Lambda and IAM permissions
- Wait for IAM role propagation (scripts include appropriate delays)
- Check CloudWatch logs if function invocations fail
- Verify that the deployment package contains all necessary files
- **Use the cleanup script (`./cleanup.sh`) to remove resources if demonstrations fail**
- **Run `./cleanup.sh --dry-run` to see what resources exist before cleanup**
- Check AWS service limits if function creation fails

## Additional Resources and Citations

### AWS Lambda Documentation
1. **AWS Lambda Developer Guide**: https://docs.aws.amazon.com/lambda/latest/dg/
2. **Lambda Python Handler**: https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
3. **Lambda Function Versions**: https://docs.aws.amazon.com/lambda/latest/dg/configuration-versions.html
4. **Lambda CLI Examples**: https://docs.aws.amazon.com/cli/v1/userguide/cli_lambda_code_examples.html

### AWS SDK and CLI References
5. **Boto3 Lambda Documentation**: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/lambda.html
6. **AWS CLI Lambda Commands**: https://docs.aws.amazon.com/cli/latest/reference/lambda/
7. **Lambda Code Examples**: https://docs.aws.amazon.com/code-library/latest/ug/python_3_lambda_code_examples.html

### Best Practices and Security
8. **Lambda Best Practices**: https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html
9. **Lambda Security**: https://docs.aws.amazon.com/lambda/latest/dg/lambda-security.html
10. **IAM Roles for Lambda**: https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html

### Monitoring and Troubleshooting
11. **Lambda Monitoring**: https://docs.aws.amazon.com/lambda/latest/dg/lambda-monitoring.html
12. **CloudWatch Logs**: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/
13. **Lambda Troubleshooting**: https://docs.aws.amazon.com/lambda/latest/dg/lambda-troubleshooting.html

---
*This demonstration showcases comprehensive Lambda automation capabilities using both CLI and SDK approaches. Always follow security best practices and test thoroughly in development environments before production deployment.*
