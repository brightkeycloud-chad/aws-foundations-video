# Lambda Demonstration Cleanup Scripts

This directory contains multiple cleanup scripts to remove resources created during the Lambda demonstration or testing.

## Available Cleanup Scripts

### 1. Quick Cleanup (Recommended)
**File**: `quick_cleanup.sh`  
**Best for**: Fast, simple cleanup using AWS CLI

```bash
./quick_cleanup.sh
```

**What it does**:
- ✅ Deletes Lambda function: `myLambdaFunction`
- ✅ Deletes IAM role: `myLambdaFunction-role` (with policy detachment)
- ✅ Deletes CloudWatch log group: `/aws/lambda/myLambdaFunction`
- ✅ Removes local virtual environment and Python cache
- ✅ No user interaction required
- ✅ Uses AWS CLI commands only

### 2. Interactive Cleanup (Advanced)
**File**: `cleanup.sh` + `cleanup.py`  
**Best for**: Thorough cleanup with additional resource discovery

```bash
./cleanup.sh
```

**What it does**:
- ✅ Everything from quick cleanup
- ✅ Scans for additional related resources
- ✅ Interactive prompts for additional cleanup
- ✅ Detailed progress reporting
- ✅ Error handling and recovery
- ✅ Uses boto3 Python SDK

## Prerequisites

### For Quick Cleanup:
- AWS CLI installed and configured
- Bash shell

### For Interactive Cleanup:
- AWS CLI installed and configured
- Python 3 installed
- Bash shell
- boto3 (automatically installed if needed)

## Usage Examples

### After Demonstration:
```bash
# Quick cleanup after demo
./quick_cleanup.sh
```

### After Testing:
```bash
# Thorough cleanup after running tests
./cleanup.sh
```

### Manual Resource Check:
```bash
# Check what resources exist before cleanup
aws lambda list-functions --query 'Functions[?contains(FunctionName, `myLambda`)]'
aws iam list-roles --query 'Roles[?contains(RoleName, `myLambda`)]'
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/myLambda"
```

## Resources Cleaned Up

### AWS Resources:
1. **Lambda Function**: `myLambdaFunction`
   - Function code and configuration
   - Environment variables
   - Triggers and event source mappings

2. **IAM Role**: `myLambdaFunction-role`
   - Execution role for Lambda
   - Attached policies (AWSLambdaBasicExecutionRole)
   - Trust relationships

3. **CloudWatch Log Group**: `/aws/lambda/myLambdaFunction`
   - Function execution logs
   - Log streams and events
   - Retention settings

### Local Files:
1. **Virtual Environment**: `venv/`
   - Python packages (boto3, etc.)
   - Virtual environment configuration

2. **Python Cache**: `__pycache__/`
   - Compiled Python bytecode
   - Module cache files

## Safety Features

### Quick Cleanup:
- ✅ Only removes specifically named resources
- ✅ Graceful handling of missing resources
- ✅ No accidental deletion of other resources
- ✅ Clear status messages for each operation

### Interactive Cleanup:
- ✅ Shows AWS account information before cleanup
- ✅ Requires user confirmation before deletion
- ✅ Scans for related resources before cleanup
- ✅ Interactive prompts for additional resources
- ✅ Detailed error reporting

## Troubleshooting

### Permission Errors:
```bash
# Ensure your AWS user/role has these permissions:
# - lambda:DeleteFunction
# - iam:DeleteRole
# - iam:DetachRolePolicy
# - iam:ListAttachedRolePolicies
# - logs:DeleteLogGroup
```

### Script Not Executable:
```bash
chmod +x quick_cleanup.sh
chmod +x cleanup.sh
```

### AWS CLI Not Configured:
```bash
aws configure
# Enter your Access Key ID, Secret Access Key, Region, and Output format
```

### Python/boto3 Issues:
```bash
# The scripts will automatically handle virtual environments
# If you encounter issues, manually install boto3:
pip3 install boto3
```

## Verification

### Check Resources Are Gone:
```bash
# Verify Lambda function is deleted
aws lambda get-function --function-name myLambdaFunction
# Should return: ResourceNotFoundException

# Verify IAM role is deleted  
aws iam get-role --role-name myLambdaFunction-role
# Should return: NoSuchEntity

# Verify log group is deleted
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/myLambda"
# Should return empty list
```

### Check Local Files:
```bash
ls -la
# Should not see 'venv' or '__pycache__' directories
```

## Cost Considerations

### AWS Resources:
- **Lambda**: No charges after function deletion
- **IAM**: No charges for roles/policies
- **CloudWatch Logs**: Small storage charges until deletion

### Cleanup Benefits:
- ✅ Prevents ongoing CloudWatch Logs storage charges
- ✅ Removes unused IAM resources (security best practice)
- ✅ Keeps AWS account clean and organized
- ✅ Prevents resource limits from being reached

## Best Practices

1. **Always Clean Up**: Run cleanup after demonstrations or testing
2. **Verify Deletion**: Check that resources are actually removed
3. **Use Quick Cleanup**: For routine cleanup after demos
4. **Use Interactive Cleanup**: When you suspect additional resources exist
5. **Check Permissions**: Ensure cleanup scripts have necessary AWS permissions

## Integration with CI/CD

### In Automated Testing:
```bash
# Add to your test pipeline
./run_test.sh && ./quick_cleanup.sh
```

### In Makefile:
```makefile
test:
	./run_test.sh

cleanup:
	./quick_cleanup.sh

test-and-cleanup: test cleanup
```

---

**Note**: These cleanup scripts are specifically designed for the Lambda demonstration resources. They will not affect other Lambda functions or IAM roles in your AWS account unless they have very similar names.
