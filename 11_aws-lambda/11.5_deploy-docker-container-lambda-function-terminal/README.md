# Deploy Docker Container Lambda Function (Terminal)

## Demonstration Overview
**Duration:** 5 minutes  
**Tools:** Terminal/CLI, Docker, AWS CLI  
**Objective:** Deploy a Lambda function using a Docker container image with data processing libraries

This demonstration shows how to package a Lambda function as a Docker container, push it to Amazon ECR, and deploy it to Lambda. The function uses pandas and numpy for data analytics, showcasing the benefits of container deployment for complex dependencies.

## Prerequisites
- AWS account with Lambda, ECR, and S3 permissions
- AWS CLI configured with appropriate credentials
- Docker installed and running
- Terminal/command line access
- jq (for JSON processing in tests)

## Step-by-Step Instructions

### Step 1: Verify Prerequisites (30 seconds)

1. **Check Docker Installation**
   ```bash
   docker --version
   docker info
   ```

2. **Verify AWS CLI Configuration**
   ```bash
   aws sts get-caller-identity
   aws ecr describe-repositories --region us-east-1 || echo "ECR access confirmed"
   ```

3. **Create S3 Bucket for Output**
   ```bash
   # Replace with unique bucket name
   BUCKET_NAME="analytics-demo-bucket-$(date +%s)"
   aws s3 mb s3://$BUCKET_NAME
   echo "Created bucket: $BUCKET_NAME"
   ```

### Step 2: Test Container Locally (1 minute)

1. **Run Local Test** (optional but recommended)
   ```bash
   ./test-local.sh
   ```
   
   This script:
   - Builds the Docker image locally
   - Runs the container on port 9000
   - Tests both sales and inventory data processing
   - Shows the function output without AWS deployment

2. **Manual Local Testing** (alternative):
   ```bash
   # Build image
   docker build -t lambda-analytics-processor:latest .
   
   # Run container
   docker run -p 9000:8080 lambda-analytics-processor:latest &
   
   # Test function
   curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
     -d '{"data_type": "sales", "output_bucket": "test-bucket"}' \
     -H "Content-Type: application/json"
   ```

### Step 3: Deploy to AWS (2.5 minutes)

1. **Run Deployment Script**
   ```bash
   ./deploy-container.sh
   ```
   
   The script will:
   - Create ECR repository if needed
   - Build and tag Docker image
   - Push image to ECR
   - Create/update Lambda function
   - Set up IAM role with necessary permissions

2. **Monitor Deployment Progress**
   - Watch for ECR repository creation
   - Observe Docker build process
   - Confirm image push to ECR
   - Verify Lambda function creation/update

### Step 4: Test Deployed Function (1 minute)

1. **Test Sales Analytics**
   ```bash
   aws lambda invoke \
     --function-name AnalyticsProcessorFunction \
     --payload '{"data_type":"sales","output_bucket":"'$BUCKET_NAME'"}' \
     --region us-east-1 \
     response-sales.json
   
   cat response-sales.json | jq .
   ```

2. **Test Inventory Analytics**
   ```bash
   aws lambda invoke \
     --function-name AnalyticsProcessorFunction \
     --payload '{"data_type":"inventory","output_bucket":"'$BUCKET_NAME'"}' \
     --region us-east-1 \
     response-inventory.json
   
   cat response-inventory.json | jq .
   ```

3. **Verify S3 Output**
   ```bash
   # List generated files
   aws s3 ls s3://$BUCKET_NAME/analytics/ --recursive
   
   # Download and view results
   aws s3 cp s3://$BUCKET_NAME/analytics/sales/ ./sales-results/ --recursive
   aws s3 cp s3://$BUCKET_NAME/analytics/inventory/ ./inventory-results/ --recursive
   ```

## Key Learning Points

- **Container Benefits**: Support for complex dependencies like pandas/numpy
- **ECR Integration**: Container images stored in Amazon Elastic Container Registry
- **Base Images**: AWS provides optimized base images for Lambda
- **Local Testing**: Containers can be tested locally before deployment
- **Deployment Automation**: Scripts can automate the entire deployment pipeline

## Understanding the Architecture

**Container Components:**
- **Base Image**: `public.ecr.aws/lambda/python:3.13`
- **Dependencies**: pandas, numpy, boto3 installed via pip
- **Function Code**: `app.py` with analytics logic
- **Handler**: `app.lambda_handler`

**Data Processing Flow:**
1. Generate sample data (sales or inventory)
2. Create pandas DataFrame
3. Perform statistical analysis
4. Save raw data and results to S3
5. Return summary analytics

## Advanced Features Demonstrated

- **Data Generation**: Realistic sample data creation
- **Statistical Analysis**: Using pandas for groupby operations
- **Error Handling**: Comprehensive exception management
- **Logging**: Structured logging for debugging
- **S3 Integration**: File storage and retrieval
- **JSON Serialization**: Handling datetime and numpy types

## Troubleshooting

**Common Issues:**

1. **Architecture Mismatch Error (`Runtime.InvalidEntrypoint`)**
   
   If you see an error like "fork/exec /lambda-entrypoint.sh: exec format error", this indicates an architecture mismatch.
   
   **Solution**: The Dockerfile now includes `--platform=linux/amd64` to ensure x86_64 compatibility:
   ```dockerfile
   FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.13
   ```
   
   **For Apple Silicon Macs**: The build process will automatically cross-compile for x86_64.

2. **Docker Build Failures with pandas/numpy**
   
   If you encounter compilation errors with pandas/numpy (missing C compilers), try these solutions:
   
   **Option A: Use Python 3.12 base image**
   ```bash
   # Rename current Dockerfile and use the alternative
   mv Dockerfile Dockerfile.original
   mv Dockerfile.alt Dockerfile
   
   # Then run deployment
   ./deploy-container.sh
   ```
   
   **Option B: Use simplified version without pandas/numpy**
   ```bash
   # Use simplified requirements and app
   cp requirements-simple.txt requirements.txt
   cp app-simple.py app.py
   
   # Then run deployment
   ./deploy-container.sh
   ```
   
   **Option C: Force binary wheels only**
   ```bash
   # Edit Dockerfile to use --only-binary=all flag
   # This prevents compilation and forces pre-built wheels
   ```

2. **ECR Push Errors**
   ```bash
   # Re-authenticate with ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [account-id].dkr.ecr.us-east-1.amazonaws.com
   ```

3. **Lambda Function Errors**
   ```bash
   # Check function logs
   aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/AnalyticsProcessorFunction"
   
   # View recent logs
   aws logs tail /aws/lambda/AnalyticsProcessorFunction --follow
   ```

4. **Memory/Timeout Issues**
   ```bash
   # Increase function memory and timeout
   aws lambda update-function-configuration \
     --function-name AnalyticsProcessorFunction \
     --memory-size 1024 \
     --timeout 120
   ```

## Performance Considerations

- **Memory**: 512MB allocated for pandas operations
- **Timeout**: 60 seconds for data processing
- **Cold Start**: Container images have longer cold start times
- **Image Size**: Optimize Dockerfile for smaller images

## Cleanup

**Automated Cleanup Script:**

Use the provided cleanup script to remove all AWS resources:

```bash
./cleanup.sh
```

The script will remove:
- Lambda function (`AnalyticsProcessorFunction`)
- ECR repository (`lambda-analytics-processor`) and all images
- IAM role (`AnalyticsProcessorFunctionRole`) and attached policies
- CloudWatch log groups
- Local Docker images and containers
- Local build files

**S3 Bucket Cleanup:**
The script will detect S3 buckets used in demonstrations and ask for confirmation before deletion.

**Manual Cleanup (if needed):**

```bash
# Delete Lambda function
aws lambda delete-function --function-name AnalyticsProcessorFunction

# Delete ECR repository
aws ecr delete-repository --repository-name lambda-analytics-processor --force

# Delete IAM role
aws iam detach-role-policy --role-name AnalyticsProcessorFunctionRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam detach-role-policy --role-name AnalyticsProcessorFunctionRole --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam delete-role --role-name AnalyticsProcessorFunctionRole

# Delete S3 bucket
aws s3 rm s3://$BUCKET_NAME --recursive
aws s3 rb s3://$BUCKET_NAME

# Clean local files
rm -f response-*.json
rm -rf sales-results/ inventory-results/
docker rmi lambda-analytics-processor:latest
```

## Documentation References

- [Create a Lambda function using a container image - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html)
- [Deploy Python Lambda functions with container images - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/python-image.html)
- [Amazon ECR User Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/)
- [AWS Lambda base images for Python](https://gallery.ecr.aws/lambda/python)
