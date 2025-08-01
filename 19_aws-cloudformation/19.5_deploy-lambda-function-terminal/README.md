# Deploy Lambda Function with Python 3.12/3.13 using AWS CLI Terminal

## Demo Overview
This 5-minute demonstration shows how to deploy a Lambda function using the latest Python runtimes (3.12 or 3.13) with API Gateway using AWS CloudFormation via the AWS CLI in terminal.

## Prerequisites
- AWS CLI installed and configured
- Terminal/command line access
- Basic understanding of Lambda and API Gateway concepts
- Appropriate IAM permissions for Lambda, API Gateway, and CloudFormation

## Demo Script (5 minutes)

### Step 1: Verify AWS CLI Configuration (30 seconds)
```bash
# Check AWS CLI configuration
aws sts get-caller-identity

# Verify region setting
aws configure get region
```

### Step 2: Validate CloudFormation Template (30 seconds)
```bash
# Navigate to the demo directory
cd /path/to/19.5_deploy-lambda-function-terminal

# Validate the template syntax
aws cloudformation validate-template --template-body file://lambda-template.yaml
```

### Step 3: Deploy the Lambda Stack (2 minutes)
```bash
# Create the stack
aws cloudformation create-stack \
  --stack-name demo-lambda-stack \
  --template-body file://lambda-template.yaml \
  --parameters ParameterKey=FunctionName,ParameterValue=demo-hello-world \
               ParameterKey=Runtime,ParameterValue=python3.12 \
  --capabilities CAPABILITY_IAM \
  --tags Key=Environment,Value=Demo Key=Purpose,Value=Training
```

### Step 4: Monitor Stack Creation (1.5 minutes)
```bash
# Check stack status
aws cloudformation describe-stacks --stack-name demo-lambda-stack --query 'Stacks[0].StackStatus'

# Watch stack events
aws cloudformation describe-stack-events --stack-name demo-lambda-stack --query 'StackEvents[*].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId]' --output table

# Wait for stack completion
aws cloudformation wait stack-create-complete --stack-name demo-lambda-stack
```

### Step 5: Test the Lambda Function (1 minute)
```bash
# Get the API Gateway URL
API_URL=$(aws cloudformation describe-stacks --stack-name demo-lambda-stack --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' --output text)

echo "API Gateway URL: $API_URL"

# Test the Lambda function via API Gateway
curl -X GET $API_URL

# Test with pretty JSON formatting
curl -X GET $API_URL | python -m json.tool
```

### Step 6: Verify Lambda Function Directly (30 seconds)
```bash
# Invoke Lambda function directly
aws lambda invoke \
  --function-name demo-hello-world \
  --payload '{"test": "direct invocation"}' \
  response.json

# View the response
cat response.json | python -m json.tool

# Clean up response file
rm response.json
```

## Alternative Deployment Methods

### Using Parameter File
Create a `parameters.json` file:
```json
[
  {
    "ParameterKey": "FunctionName",
    "ParameterValue": "my-custom-function"
  },
  {
    "ParameterKey": "Runtime",
    "ParameterValue": "python3.12"
  }
]
```

Deploy using parameter file:
```bash
aws cloudformation create-stack \
  --stack-name demo-lambda-stack \
  --template-body file://lambda-template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_IAM
```

### Using Template from S3
```bash
# Upload template to S3
aws s3 cp lambda-template.yaml s3://your-bucket/templates/

# Deploy from S3
aws cloudformation create-stack \
  --stack-name demo-lambda-stack \
  --template-url https://your-bucket.s3.amazonaws.com/templates/lambda-template.yaml \
  --capabilities CAPABILITY_IAM
```

## Advanced Testing Commands

### View Lambda Logs
```bash
# Get log group name
LOG_GROUP="/aws/lambda/demo-hello-world"

# View recent logs
aws logs describe-log-streams --log-group-name $LOG_GROUP --order-by LastEventTime --descending --max-items 1

# Get latest log stream
LATEST_STREAM=$(aws logs describe-log-streams --log-group-name $LOG_GROUP --order-by LastEventTime --descending --max-items 1 --query 'logStreams[0].logStreamName' --output text)

# View log events
aws logs get-log-events --log-group-name $LOG_GROUP --log-stream-name $LATEST_STREAM
```

### Update Lambda Function Code
```bash
# Update function code inline
aws lambda update-function-code \
  --function-name demo-hello-world \
  --zip-file fileb://new-code.zip
```

### Test Different HTTP Methods
```bash
# Test with different methods (if configured)
curl -X POST $API_URL -d '{"key":"value"}' -H "Content-Type: application/json"
```

## Expected Results
After successful deployment, you will have:
- 1 Lambda function with Python 3.12 runtime (or 3.13 if specified)
- 1 IAM execution role for the Lambda function
- 1 API Gateway REST API with a `/hello` endpoint
- 1 CloudWatch Log Group for Lambda logs
- A publicly accessible HTTPS endpoint

## Cleanup
```bash
# Delete the stack
aws cloudformation delete-stack --stack-name demo-lambda-stack

# Wait for deletion to complete
aws cloudformation wait stack-delete-complete --stack-name demo-lambda-stack

# Verify deletion
aws cloudformation list-stacks --stack-status-filter DELETE_COMPLETE --query 'StackSummaries[?StackName==`demo-lambda-stack`]'
```

## Key Learning Points
- CloudFormation can create IAM roles and policies automatically
- Lambda functions can be deployed with inline code for simple demos
- API Gateway integration requires specific permissions and configurations
- The `CAPABILITY_IAM` flag is required when creating IAM resources
- Stack outputs provide easy access to created resource information
- CloudWatch logs are automatically created for Lambda functions
- **Python 3.12 and 3.13** provide the latest language features and performance improvements
- **Runtime selection** affects available libraries and language features

## Troubleshooting
- **CAPABILITY_IAM error**: Add `--capabilities CAPABILITY_IAM` to the create-stack command
- **Permission errors**: Ensure your AWS credentials have Lambda, API Gateway, and IAM permissions
- **Template validation errors**: Check YAML syntax and resource dependencies
- **Lambda timeout**: Increase timeout value in template if function takes longer to execute
- **API Gateway 502 errors**: Check Lambda function logs for runtime errors

## Python 3.12 and 3.13 Runtime Benefits

### **Python 3.12 Features:**
- **Performance improvements**: Up to 11% faster than Python 3.11
- **Better error messages**: More precise error locations and suggestions
- **Type system enhancements**: Improved type hints and annotations
- **f-string improvements**: More flexible string formatting
- **Pathlib enhancements**: Better file system operations

### **Python 3.13 Features:**
- **Free-threaded CPython**: Experimental support for true parallelism
- **Interactive interpreter improvements**: Better REPL experience
- **Performance optimizations**: Further speed improvements
- **Enhanced debugging**: Better stack traces and error reporting
- **Updated standard library**: Latest modules and functions

### **AWS Lambda Advantages:**
- **Latest security patches**: Most recent runtime security updates
- **Better cold start performance**: Optimized runtime initialization
- **Extended support lifecycle**: Longer maintenance window
- **Modern library compatibility**: Support for latest Python packages

### **Migration Considerations:**
```python
# Python 3.12+ syntax improvements
match response_code:
    case 200:
        return {"status": "success"}
    case 404:
        return {"status": "not_found"}
    case _:
        return {"status": "error"}

# Enhanced type hints
from typing import TypedDict

class ResponseDict(TypedDict):
    statusCode: int
    body: str
```

## Performance Monitoring
```bash
# Get Lambda function metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=demo-hello-world \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum

# Get API Gateway metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name Count \
  --dimensions Name=ApiName,Value=Demo-Lambda-API \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

## Documentation References
- [AWS Lambda template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-lambda.html)
- [AWS::Lambda::Function](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-lambda-function.html)
- [AWS::ApiGateway::RestApi](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-apigateway-restapi.html)
- [AWS::IAM::Role](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-iam-role.html)
- [Lambda CLI Commands](https://docs.aws.amazon.com/cli/latest/reference/lambda/)
- [API Gateway CLI Commands](https://docs.aws.amazon.com/cli/latest/reference/apigateway/)
