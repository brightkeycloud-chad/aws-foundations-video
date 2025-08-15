# AWS Billing and Cost Management Preferences Console Demo

## Overview
This 5-minute demonstration shows how to configure billing and cost management preferences in the AWS Console to optimize cost tracking and reporting capabilities.

## Prerequisites
- AWS account with billing access (management account or IAM user with billing permissions)
- Access to AWS Billing and Cost Management console

## Demonstration Steps (5 minutes)

### Step 1: Access Billing and Cost Management Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **Billing and Cost Management** (search for "billing" in the services search)
3. Click on **Billing and Cost Management** to open the console

### Step 2: Configure Billing Preferences (2 minutes)
1. In the left navigation pane, click **Billing preferences**
2. Review and configure the following settings:
   - **Invoice delivery preferences**: Choose PDF and/or CSV format
   - **Alert preferences**: Enable "Receive Billing Alerts" to get notifications
   - **Cost allocation tags**: Enable to track costs by tags
   - **Credits**: Configure how credits are applied to your bill

3. **Enable Cost Allocation Tags**:
   - Check "Activate cost allocation tags" 
   - This allows you to track costs by resource tags in reports

4. **Configure Alert Preferences**:
   - Enable "Receive Billing Alerts"
   - This enables CloudWatch billing alarms and budget notifications

### Step 3: Set Up Cost and Usage Reports (1.5 minutes)
1. Click **Cost & Usage Reports** in the left navigation
2. Click **Create report**
3. Configure report settings:
   - **Report name**: Enter a descriptive name (e.g., "Monthly-Cost-Report")
   - **Additional report details**: Select desired options
   - **Data refresh settings**: Choose automatic refresh preferences
   - **Time granularity**: Select Daily, Hourly, or Monthly
   - **Report versioning**: Choose create new report version or overwrite

4. Configure S3 delivery options:
   - **S3 bucket**: Select or create an S3 bucket for report delivery
   - **Report path prefix**: Optional path within the bucket
   - **Compression**: Choose GZIP or ZIP

### Step 4: Configure Payment Methods (30 seconds)
1. Click **Payment methods** in the left navigation
2. Review current payment methods
3. Add backup payment method if needed
4. Set default payment method

### Step 5: Review Billing Dashboard (30 seconds)
1. Return to **Bills** in the left navigation
2. Review the billing dashboard showing:
   - Current month charges
   - Previous month comparison
   - Service breakdown
   - Payment status

## Key Benefits Demonstrated
- **Centralized billing management**: Single location for all billing preferences
- **Automated reporting**: Cost and usage reports delivered to S3
- **Cost allocation**: Tag-based cost tracking for better attribution
- **Proactive monitoring**: Billing alerts and notifications
- **Payment flexibility**: Multiple payment methods and backup options

## Best Practices Highlighted
- Enable cost allocation tags early for better cost tracking
- Set up automated reports for regular cost analysis
- Configure billing alerts to avoid unexpected charges
- Use multiple payment methods for redundancy
- Review billing preferences quarterly

## Troubleshooting Tips
- **Missing billing data**: Wait 24 hours for cost allocation tags to appear
- **Report delivery issues**: Verify S3 bucket permissions and policies
- **Access denied**: Ensure IAM user has billing permissions or use management account
- **Missing alerts**: Confirm CloudWatch billing alarms are enabled in us-east-1 region

## Next Steps
After this demonstration, participants should:
1. Enable cost allocation tags in their own accounts
2. Set up automated cost and usage reports
3. Configure billing alerts and budgets
4. Review and optimize payment methods

## Documentation References
- [AWS Billing and Cost Management User Guide](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-what-is.html)
- [Using the AWS Billing and Cost Management home page](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/view-billing-dashboard.html)
- [Cost and Usage Reports User Guide](https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html)
- [Managing your payment methods](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/manage-payments.html)

---
*Demo Duration: 5 minutes*  
*Skill Level: Beginner*  
*Tools Used: AWS Console*
