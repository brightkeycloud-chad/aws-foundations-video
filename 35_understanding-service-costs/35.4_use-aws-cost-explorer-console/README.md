# AWS Cost Explorer Console Demonstration

## Overview
This 5-minute demonstration shows how to use AWS Cost Explorer through the AWS Management Console to analyze costs, view usage trends, and understand spending patterns across AWS services.

## Prerequisites
- AWS account with billing data (at least 24 hours of usage recommended)
- Appropriate IAM permissions to access Cost Explorer
- Web browser to access AWS Management Console

## Learning Objectives
By the end of this demonstration, participants will be able to:
- Enable AWS Cost Explorer for their account
- Navigate the Cost Explorer dashboard
- Analyze cost trends and forecasts
- Use filters and grouping to examine specific services or time periods
- Understand different cost views (unblended, amortized, net costs)

## Demonstration Steps

### Step 1: Enable Cost Explorer (1 minute)

1. **Access the AWS Management Console**
   - Open your web browser and navigate to the [AWS Management Console](https://console.aws.amazon.com/)
   - Sign in with your AWS account credentials

2. **Navigate to Cost Management**
   - In the AWS Management Console, search for "Cost Management" in the services search bar
   - Click on "AWS Cost Management" from the search results
   - Alternatively, navigate directly to: https://console.aws.amazon.com/costmanagement/

3. **Enable Cost Explorer**
   - In the left navigation pane, click on "Cost Explorer"
   - If this is your first time accessing Cost Explorer, you'll see a "Welcome to Cost Explorer" page
   - Click the "Launch Cost Explorer" button
   - **Note**: Cost Explorer is free to use through the console interface

### Step 2: Explore the Cost Explorer Dashboard (2 minutes)

1. **Review Dashboard Overview**
   - Examine the **Month-to-date costs** section showing current month spending
   - Review the **Forecasted month end costs** to understand projected spending
   - Note the comparison with previous month's costs

2. **Analyze Cost Trends**
   - In the "This month trends" section, review the top 5 cost trends
   - Click on any trend to drill down into specific cost drivers
   - Click "View all trends" to see comprehensive trend analysis

3. **Examine the Daily Costs Graph**
   - Review the central graph showing daily unblended costs
   - Observe spending patterns and any unusual spikes
   - Note that data reflects usage up to the previous day

### Step 3: Use Cost Explorer Reports (1.5 minutes)

1. **Access Cost Explorer Reports**
   - Click "Explore costs" in the upper-right corner of the daily costs graph
   - This opens the detailed Cost Explorer reports interface

2. **Explore Default Reports**
   - In the left navigation, click on "Reports" to see default report options
   - Try the "Cost & Usage" report for comprehensive analysis
   - Explore "Daily costs" for granular daily spending analysis

3. **Apply Filters and Grouping**
   - Use the "Filters" panel to narrow down data:
     - Filter by specific services (e.g., Amazon EC2, Amazon S3)
     - Filter by time range (last 7 days, last month, custom range)
     - Filter by linked accounts (if using AWS Organizations)
   - Use "Group by" options to organize data:
     - Group by Service to see per-service costs
     - Group by Usage Type for detailed usage analysis
     - Group by Region to understand regional spending

### Step 4: Understand Different Cost Views (30 seconds)

1. **Cost Types Explanation**
   - **Unblended costs**: Standard on-demand pricing without discounts
   - **Amortized costs**: Shows Reserved Instance and Savings Plans costs spread over time
   - **Net costs**: Shows actual costs after all discounts and credits

2. **Switch Between Views**
   - Use the dropdown menu to switch between different cost types
   - Compare the same time period across different cost views

## Key Features Demonstrated

### Dashboard Components
- **Month-to-date costs**: Current month spending with previous month comparison
- **Forecasted costs**: AI-powered spending predictions for month-end
- **Cost trends**: Top 5 cost changes and drivers
- **Daily cost graph**: Visual representation of daily spending patterns
- **Recent reports**: Quick access to previously viewed reports

### Filtering and Analysis Options
- **Time periods**: Last 7 days, last month, last 3 months, custom ranges
- **Services**: Filter by specific AWS services
- **Accounts**: Filter by linked accounts in AWS Organizations
- **Regions**: Analyze costs by AWS region
- **Usage types**: Detailed breakdown of how services are used
- **Charge types**: Include/exclude specific charge types

### Cost Views
- **Unblended**: Standard pricing without volume discounts
- **Amortized**: Reserved Instance and Savings Plans costs distributed over time
- **Net**: Actual costs after all applicable discounts

## Important Notes

- **Data Availability**: Cost data is typically available within 24 hours of usage
- **Historical Data**: Cost Explorer provides up to 13 months of historical data
- **Forecasting**: Provides up to 12 months of cost forecasting
- **Free Usage**: Console access to Cost Explorer is free; API usage incurs $0.01 per request
- **Cost Anomaly Detection**: Automatically enabled when Cost Explorer is first launched

## Troubleshooting

### Common Issues
1. **No data visible**: Ensure your account has incurred costs and wait 24 hours for data processing
2. **Access denied**: Verify IAM permissions include Cost Explorer access
3. **Limited data**: New accounts may have minimal data; consider creating some resources for demonstration

### Required IAM Permissions
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
                "ce:GetReservationUtilization",
                "ce:GetUsageReport",
                "ce:DescribeCostCategoryDefinition",
                "ce:GetRightsizingRecommendation"
            ],
            "Resource": "*"
        }
    ]
}
```

## Next Steps
After this demonstration, participants can:
- Set up cost budgets and alerts
- Explore Reserved Instance recommendations
- Create custom cost allocation tags
- Use the Cost Explorer API for programmatic access
- Set up Cost Anomaly Detection alerts
- Run monthly cost optimization analyses using the bonus scripts

## Additional Resources

### AWS Documentation
- [Getting started with Cost Explorer](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-getting-started.html)
- [Analyzing your costs and usage with AWS Cost Explorer](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html)
- [Exploring your data using Cost Explorer](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-exploring-data.html)
- [Enabling Cost Explorer](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-enable.html)
- [Controlling access to Cost Explorer](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-access.html)

### Related AWS Services
- [AWS Budgets](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html)
- [AWS Cost Anomaly Detection](https://docs.aws.amazon.com/cost-management/latest/userguide/manage-ad.html)
- [AWS Cost and Usage Reports](https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html)

## Bonus: Cost Optimization Scripts

### Available Scripts
- **`bonus-cost-optimization.sh`** - Basic cost optimization analysis using AWS CLI
- **`bonus-cost-optimization-enhanced.py`** - Enhanced Python script with detailed recommendations
- **`bonus-cost-optimization-mcp.py`** - Advanced script using MCP pricing tools for real-time data
- **`demo-mcp-pricing.sh`** - Demonstration of MCP pricing tools integration

### Running the Bonus Scripts

#### Basic Cost Optimization
```bash
./bonus-cost-optimization.sh
```

#### Enhanced Cost Optimization (Python)
```bash
python3 bonus-cost-optimization-enhanced.py
```

#### MCP-Powered Cost Optimization
```bash
python3 bonus-cost-optimization-mcp.py
```

#### MCP Pricing Tools Demo
```bash
./demo-mcp-pricing.sh
```

### Bonus Script Features
- **Automated Analysis**: Identifies top 3 service costs for current month
- **Optimization Recommendations**: Provides immediate, medium-term, and long-term cost optimization strategies
- **Potential Savings Calculation**: Estimates potential monthly and annual savings
- **Real-time Pricing Data**: Uses MCP pricing tools for current AWS pricing information
- **Service-Specific Tips**: Tailored recommendations for EC2, S3, RDS, Lambda, and other services

### Prerequisites for Bonus Scripts
- AWS CLI installed and configured
- Python 3.6+ (for Python scripts)
- Cost Explorer enabled with at least 24 hours of data
- Appropriate IAM permissions for Cost Explorer API

### Cost Optimization Resources
- [AWS Well-Architected Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
- [AWS Cost Optimization Hub](https://aws.amazon.com/aws-cost-management/cost-optimization/)
- [AWS Trusted Advisor](https://aws.amazon.com/premiumsupport/technology/trusted-advisor/)
- [AWS Pricing API](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html)

---

**Note**: This demonstration uses the AWS Management Console interface. No cleanup is required as Cost Explorer is a read-only service that doesn't create billable resources. The bonus scripts provide additional value by automating cost analysis and providing actionable optimization recommendations.
