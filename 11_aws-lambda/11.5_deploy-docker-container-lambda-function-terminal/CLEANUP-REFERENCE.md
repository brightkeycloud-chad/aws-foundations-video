# Demo 11.5 Cleanup Reference

## Quick Cleanup
```bash
./cleanup.sh
```

## Resources That Will Be Removed

### AWS Resources
- **Lambda Function**: `AnalyticsProcessorFunction`
- **ECR Repository**: `lambda-analytics-processor` (and all container images)
- **IAM Role**: `AnalyticsProcessorFunctionRole`
- **IAM Policies**: 
  - `AWSLambdaBasicExecutionRole` (detached)
  - `AmazonS3FullAccess` (detached)
- **CloudWatch Logs**: `/aws/lambda/AnalyticsProcessorFunction`
- **S3 Buckets**: Demo buckets (with user confirmation)

### Local Resources
- **Docker Images**: `lambda-analytics-processor:latest`
- **Docker Containers**: Any stopped containers from the image
- **Build Files**: 
  - `deployment-package.zip`
  - `response*.json`
  - `trust-policy.json`

## Safety Features
- ✅ Confirms before proceeding
- ✅ Asks permission before deleting S3 buckets
- ✅ Handles missing resources gracefully
- ✅ Provides detailed status messages
- ✅ Color-coded output for clarity

## Manual Verification
After cleanup, verify resources are removed:

```bash
# Check Lambda function
aws lambda get-function --function-name AnalyticsProcessorFunction

# Check ECR repository
aws ecr describe-repositories --repository-names lambda-analytics-processor

# Check IAM role
aws iam get-role --role-name AnalyticsProcessorFunctionRole

# Check local Docker images
docker images | grep lambda-analytics-processor
```

All commands should return "not found" or similar errors.

## Troubleshooting

**Permission Errors**: Ensure your AWS credentials have sufficient permissions for:
- Lambda (delete functions)
- ECR (delete repositories)
- IAM (delete roles and detach policies)
- CloudWatch Logs (delete log groups)
- S3 (delete buckets and objects)

**Partial Cleanup**: If cleanup fails partway through, you can:
1. Run the script again (it handles already-deleted resources)
2. Use the manual cleanup commands in the main README
3. Check AWS Console to verify what remains
