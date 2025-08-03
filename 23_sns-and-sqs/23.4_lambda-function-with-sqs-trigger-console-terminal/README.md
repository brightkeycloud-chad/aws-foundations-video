# Demo 23.4: Lambda Function with SQS Trigger (Console + Terminal)

## Overview
This 5-minute demonstration shows how to create an AWS Lambda function that is triggered by messages in an Amazon SQS queue. You'll use a shell script to provision the Lambda function, then use the AWS Management Console to create the SQS queue and configure the trigger, and finally test with the terminal/CLI.

## Prerequisites
- AWS account with appropriate permissions
- AWS CLI configured with credentials
- Access to AWS Management Console
- Terminal/command line access
- Bash shell environment

## Pre-Demo Setup (Run Before Demo)

### Provision Lambda Function
Run the provisioning script to create the Lambda function and IAM role:

```bash
./provision_lambda.sh
```

This script will:
- Create an IAM execution role with appropriate permissions
- Package and deploy the Lambda function
- Set up all necessary policies for SQS integration

**Optional parameters:**
```bash
./provision_lambda.sh [function-name] [region]
# Example: ./provision_lambda.sh my-sqs-processor us-west-2
```

## Demo Steps (5 minutes)

### Step 1: Create an SQS Queue (1.5 minutes)

1. **Navigate to SQS Console**
   - Open the [Amazon SQS console](https://console.aws.amazon.com/sqs/)
   - Choose **Create queue**

2. **Configure Queue**
   - For **Type**, select **Standard**
   - Enter **Name**: `demo-lambda-trigger-queue`
   - Leave default settings (explain key parameters like visibility timeout)
   - Click **Create queue**
   - Note the queue URL for later use

### Step 2: Review Pre-Provisioned Lambda Function (1 minute)

1. **Navigate to Lambda Console**
   - Open the [Lambda console](https://console.aws.amazon.com/lambda/)
   - Find the function: `demo-sqs-processor`

2. **Review Function Details**
   - Show the function code (already deployed)
   - Explain the message processing logic
   - Point out the logging and error handling

### Step 3: Configure SQS Trigger (1.5 minutes)

1. **Add Trigger**
   - In the Lambda function page, click **Add trigger**
   - Select **SQS** as the trigger source
   - Choose the queue created earlier: `demo-lambda-trigger-queue`
   - Leave **Batch size** as 10 (explain this setting)
   - Click **Add**

2. **Verify Configuration**
   - Confirm the trigger appears in the function overview
   - Explain that Lambda will now poll the SQS queue automatically

### Step 4: Test the Integration (1 minute)

1. **Send Test Messages via CLI**
   ```bash
   # Use the provided test script
   ./send_test_messages.sh demo-lambda-trigger-queue
   ```

2. **Monitor Execution**
   - Return to Lambda console
   - Click on **Monitor** tab
   - View **CloudWatch Logs** to see function execution
   - Explain the log entries showing message processing

## Key Learning Points

- **Event-Driven Architecture**: Lambda functions can be triggered by SQS messages
- **Automatic Scaling**: Lambda scales automatically based on queue depth
- **Message Processing**: Each invocation can process multiple messages (batch processing)
- **Error Handling**: Failed messages can be sent to dead letter queues
- **Monitoring**: CloudWatch provides comprehensive logging and metrics
- **Infrastructure Automation**: Using scripts to provision AWS resources consistently

## Advanced Configuration Options

- **Batch Size**: Control how many messages Lambda processes per invocation (1-10 for standard queues)
- **Maximum Batching Window**: Wait time to collect messages before invoking (0-300 seconds)
- **Dead Letter Queue**: Handle messages that fail processing after retries
- **Visibility Timeout**: Ensure adequate time for Lambda processing (recommended: 6x function timeout)
- **Reserved Concurrency**: Limit concurrent executions to control costs

## File Structure

```
23.4_lambda-function-with-sqs-trigger-console-terminal/
├── README.md (this file)
├── lambda_function.py (Lambda function source code)
├── provision_lambda.sh (Automated setup script)
├── cleanup_lambda.sh (Resource cleanup script)
└── send_test_messages.sh (Message testing script)
```

## Cleanup

To avoid ongoing costs, run the cleanup script after the demo:

```bash
./cleanup_lambda.sh
```

This will remove:
- Lambda function (`demo-sqs-processor`)
- IAM execution role (`demo-sqs-lambda-execution-role`)
- Associated IAM policies

**Manual cleanup required:**
- SQS queues (delete via console or CLI)
- CloudWatch log groups (automatically expire based on retention settings)

## Troubleshooting Tips

- **Provision Script Fails**: Ensure AWS CLI is configured with appropriate permissions
- **Function Not Triggering**: Verify the SQS trigger was added correctly in the console
- **Messages Not Being Deleted**: Check that the Lambda function completes successfully
- **Permission Errors**: The provision script creates all necessary IAM permissions automatically
- **Timeout Issues**: Default function timeout is 30 seconds; adjust if needed
- **No Log Output**: Check CloudWatch Logs under `/aws/lambda/demo-sqs-processor`

## Script Usage Reference

```bash
# Setup (run before demo)
./provision_lambda.sh [function-name] [region]
# Example: ./provision_lambda.sh my-processor us-west-2

# Testing (during demo)
./send_test_messages.sh [queue-name] [region]
# Example: ./send_test_messages.sh my-queue us-west-2

# Cleanup (after demo)
./cleanup_lambda.sh [function-name] [region]
# Example: ./cleanup_lambda.sh my-processor us-west-2

# Useful AWS CLI commands for monitoring
aws sqs list-queues --region us-east-1
aws lambda list-functions --region us-east-1
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/"
```

## Demo Flow Summary

| Phase | Duration | Activity | Tool |
|-------|----------|----------|------|
| **Pre-demo** | 2-3 min | Run `./provision_lambda.sh` | Terminal |
| **Step 1** | 1.5 min | Create SQS queue | Console |
| **Step 2** | 1 min | Review Lambda function | Console |
| **Step 3** | 1.5 min | Configure SQS trigger | Console |
| **Step 4** | 1 min | Test and monitor | Terminal + Console |
| **Post-demo** | 1 min | Run `./cleanup_lambda.sh` | Terminal |

## What the Provision Script Creates

The `provision_lambda.sh` script automatically creates:

1. **IAM Execution Role** (`demo-sqs-lambda-execution-role`)
   - Basic Lambda execution permissions
   - SQS message processing permissions (`ReceiveMessage`, `DeleteMessage`, `GetQueueAttributes`)

2. **Lambda Function** (`demo-sqs-processor`)
   - Python 3.13 runtime
   - 30-second timeout
   - 128 MB memory allocation
   - Comprehensive message processing and logging

3. **Deployment Package**
   - Packages the `lambda_function.py` code
   - Creates and uploads ZIP file to Lambda

This automation ensures consistent setup and allows the demo to focus on the integration concepts rather than manual configuration.

## Citations

This demonstration is based on the following AWS documentation:

1. [Creating an Amazon SQS standard queue - Amazon Simple Queue Service](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/creating-sqs-standard-queues.html)
2. [Create your first Lambda function - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html)
3. [Configuring an Amazon SQS queue to trigger an AWS Lambda function - Amazon Simple Queue Service](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-configure-lambda-function-trigger.html)
4. [Using Lambda with Amazon SQS - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html)
5. [Creating and configuring an Amazon SQS event source mapping - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-configure.html)

---
*Demo Duration: 5 minutes*  
*Tools Used: Shell Script, AWS Management Console, Terminal/AWS CLI*  
*Services: Amazon SQS, AWS Lambda, Amazon CloudWatch, AWS IAM*
