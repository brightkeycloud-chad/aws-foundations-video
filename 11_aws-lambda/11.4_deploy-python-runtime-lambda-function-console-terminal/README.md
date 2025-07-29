# Deploy Python Runtime Lambda Function (Console + Terminal)

## Demonstration Overview
**Duration:** 5 minutes  
**Tools:** AWS Management Console, Terminal/CLI  
**Objective:** Deploy a Python Lambda function that uses AWS Cost Explorer API to retrieve current monthly billing information

This demonstration shows how to create a Lambda function that integrates with AWS Cost Explorer API, processes billing data, and stores results in S3. It showcases AWS service integration, IAM permissions, and deployment package management.

## Prerequisites
- AWS account with Lambda, Cost Explorer, and S3 permissions
- AWS CLI configured with appropriate credentials
- Python 3.8+ installed locally
- pip package manager
- Terminal/command line access
- **Important**: Cost Explorer API requires billing access permissions

## Step-by-Step Instructions

### Step 1: Prepare the Environment (1 minute)

1. **Verify Prerequisites**
   ```bash
   # Check Python version
   python3 --version
   
   # Check pip
   pip --version
   
   # Verify AWS CLI configuration
   aws sts get-caller-identity
   ```

2. **Create S3 Bucket** (if needed)
   ```bash
   # Replace with unique bucket name
   aws s3 mb s3://your-lambda-demo-bucket-$(date +%s)
   ```

3. **Verify Cost Explorer Access**
   ```bash
   # Test Cost Explorer permissions (this should not error)
   aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-02 --granularity MONTHLY --metrics BlendedCost
   ```

### Step 2: Create Function in Console (1.5 minutes)

1. **Navigate to Lambda Console**
   - Open [AWS Lambda Console](https://console.aws.amazon.com/lambda/)
   - Click **Create function**

2. **Configure Function**
   - Select **Author from scratch**
   - Function name: `CostExplorerFunction`
   - Runtime: **Python 3.13**
   - Architecture: **x86_64**
   - Click **Create function**

3. **Update Execution Role**
   - Go to **Configuration** → **Permissions**
   - Click on the execution role name
   - Add the following policies:
     - **AmazonS3FullAccess** (for demo purposes)
     - **AWSBillingReadOnlyAccess** (for Cost Explorer access)
   - Or create a custom policy with these permissions:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": [
             "ce:GetCostAndUsage",
             "ce:GetDimensionValues",
             "ce:GetReservationCoverage",
             "ce:GetReservationPurchaseRecommendation",
             "ce:GetReservationUtilization"
           ],
           "Resource": "*"
         }
       ]
     }
     ```

### Step 3: Build Deployment Package (1.5 minutes)

1. **Navigate to Project Directory**
   ```bash
   cd /path/to/this/directory
   ```

2. **Run Deployment Script**
   ```bash
   ./deploy.sh
   ```
   
   The script will:
   - Install boto3 dependencies to `package/` directory
   - Copy function code
   - Create `deployment-package.zip`
   - Update the Lambda function code

3. **Manual Alternative** (if script fails):
   ```bash
   # Create package directory
   mkdir package
   
   # Install dependencies
   pip install --target ./package -r requirements.txt
   
   # Copy function code
   cp lambda_function.py package/
   
   # Create zip file
   cd package && zip -r ../deployment-package.zip . && cd ..
   ```

### Step 4: Upload and Test (1 minute)

1. **Upload via Console** (alternative to CLI):
   - In Lambda console, click **Upload from** → **.zip file**
   - Select `deployment-package.zip`
   - Click **Save**

2. **Create Test Event**
   - Click **Test**
   - Event name: `CostExplorerTest`
   - Use the JSON from `test-event.json` (update bucket name):
   ```json
   {
     "bucket_name": "your-lambda-demo-bucket",
     "granularity": "MONTHLY",
     "group_by": "SERVICE"
   }
   ```
   - Click **Save**

3. **Execute Test**
   - Click **Test** to run the function
   - Review execution results and billing data

### Step 5: Verify Results (30 seconds)

1. **Check S3 Output**
   ```bash
   # List objects in bucket
   aws s3 ls s3://your-lambda-demo-bucket/cost-data/
   
   # Download and view the result
   aws s3 cp s3://your-lambda-demo-bucket/cost-data/monthly-bill-[timestamp].json ./billing-result.json
   cat billing-result.json | jq .
   ```

2. **Review CloudWatch Logs**
   - Check function execution logs
   - Verify Cost Explorer API call logs
   - Review S3 storage confirmation

## Key Learning Points

- **AWS Service Integration**: Direct integration with Cost Explorer API
- **IAM Permissions**: Specific permissions required for billing data access
- **Date Range Handling**: Proper date calculations for monthly billing periods
- **Error Handling**: Specific handling for permission and API errors
- **Data Processing**: Transforming API responses into structured summaries
- **Cost Analysis**: Understanding AWS billing data structure

## Understanding the Code

The function demonstrates:
- **Cost Explorer API**: Using `boto3.client('ce')` for billing data
- **Date Calculations**: Proper month range calculations with timezone awareness
- **Data Processing**: Aggregating and sorting cost data by service
- **Error Handling**: Specific handling for billing permission errors
- **JSON Processing**: Complex data structure manipulation
- **S3 Integration**: Storing processed billing reports

## Sample Output

The function returns billing information like:
```json
{
  "message": "Monthly billing data retrieved successfully",
  "billing_summary": {
    "current_month_total": 45.67,
    "currency": "USD",
    "period": "2024-01-01 to 2024-02-01",
    "top_services": [
      {
        "service": "Amazon Elastic Compute Cloud - Compute",
        "cost": 25.30,
        "percentage": 55.4
      },
      {
        "service": "Amazon Simple Storage Service",
        "cost": 12.15,
        "percentage": 26.6
      }
    ]
  }
}
```

## Troubleshooting

**Common Issues:**

1. **Permission Errors**:
   ```bash
   # Check current user permissions
   aws iam get-user
   
   # List attached policies
   aws iam list-attached-user-policies --user-name [username]
   ```

2. **Cost Explorer Access**:
   - Ensure billing access is enabled in account settings
   - Cost Explorer must be activated (may take 24 hours for new accounts)
   - Root account or IAM user needs billing permissions

3. **Date Range Issues**:
   - Cost Explorer requires at least 1 day of data
   - Monthly granularity needs proper month boundaries

**Solutions:**
```bash
# Test Cost Explorer access
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-02 --granularity DAILY --metrics BlendedCost

# Check function logs for detailed errors
aws logs tail /aws/lambda/CostExplorerFunction --follow
```

## Advanced Variations

Try these modifications:
- Change granularity to "DAILY" for daily costs
- Group by "REGION" or "USAGE_TYPE" instead of "SERVICE"
- Add cost forecasting using `get_cost_forecast` API
- Implement cost alerts based on thresholds
- Add historical cost comparison

## Test Variations

**Daily Granularity:**
```json
{
  "bucket_name": "your-lambda-demo-bucket",
  "granularity": "DAILY",
  "group_by": "SERVICE"
}
```

**Group by Region:**
```json
{
  "bucket_name": "your-lambda-demo-bucket",
  "granularity": "MONTHLY",
  "group_by": "REGION"
}
```

## Cleanup

```bash
# Delete function
aws lambda delete-function --function-name CostExplorerFunction

# Delete S3 bucket contents and bucket
aws s3 rm s3://your-lambda-demo-bucket --recursive
aws s3 rb s3://your-lambda-demo-bucket

# Clean local files
rm -rf package/ deployment-package.zip billing-result.json
```

## Documentation References

- [AWS Cost Explorer API Reference](https://docs.aws.amazon.com/aws-cost-management/latest/APIReference/API_Operations_AWS_Cost_Explorer_Service.html)
- [Working with .zip file archives for Python Lambda functions - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html)
- [Building Lambda functions with Python - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
- [AWS Lambda execution role - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
- [Managing your costs with AWS Budgets](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/budgets-managing-costs.html)
