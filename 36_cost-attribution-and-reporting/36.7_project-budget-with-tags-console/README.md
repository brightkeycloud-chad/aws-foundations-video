# Project Budget with Tags Console Demo

## Overview
This 5-minute demonstration shows how to create project-specific budgets using cost allocation tags in AWS Budgets, enabling precise cost tracking and alerting for individual projects or business units.

## Prerequisites
- AWS account with billing access
- Cost allocation tags already activated (see demo 36.3)
- AWS resources tagged with project-specific tags
- Access to AWS Budgets console

## Demonstration Steps (5 minutes)

### Step 1: Access AWS Budgets Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **AWS Cost Management**
3. Click **Budgets** in the left navigation pane
4. Click **Create budget** to start the budget creation process

### Step 2: Configure Budget Type and Scope (1 minute)
1. **Budget setup**:
   - Select **Cost budget** (most common for project tracking)
   - Choose **Monthly** for the period
   - Select **Recurring budget**

2. **Budget scope**:
   - **Budget name**: Enter `Project-WebApp-Monthly-Budget`
   - **Budget amount**: Enter `$500` (example amount)
   - **Budget method**: Select **Fixed**

### Step 3: Apply Tag-Based Filters (1.5 minutes)
1. **Filters section**:
   - Click **Add filter**
   - **Dimension**: Select **Tag**
   - **Tag key**: Select `Project` (from your activated cost allocation tags)
   - **Tag values**: Select `WebApp` (or your specific project name)

2. **Additional filters** (optional):
   - Add another filter for **Tag** → `Environment` → `Production`
   - Add filter for **Service** if you want to limit to specific services
   - Add filter for **Linked Account** if using consolidated billing

3. **Preview costs**:
   - Review the **Budget details** section
   - Verify that historical costs match your expectations
   - Check the forecasted spend for the current month

### Step 4: Configure Budget Alerts (1.5 minutes)
1. **Alert thresholds**:
   - **Alert #1**: 
     - Threshold: `80%` of budgeted amount
     - Type: **Actual** costs
     - Email recipients: Enter project manager email
   
   - **Alert #2**:
     - Threshold: `100%` of budgeted amount  
     - Type: **Forecasted** costs
     - Email recipients: Add finance team email

2. **Advanced alert options**:
   - **SNS topic**: Create or select existing SNS topic for Slack/Teams integration
   - **Alert frequency**: Choose **Daily** or **Weekly**

### Step 5: Review and Create Budget (30 seconds)
1. **Review budget configuration**:
   - Verify budget name and amount
   - Confirm tag filters are correct
   - Check alert thresholds and recipients
   - Review cost breakdown by service

2. **Create budget**:
   - Click **Create budget**
   - Confirm budget creation success
   - Note the budget ID for future reference

### Step 6: Demonstrate Budget Monitoring (1 minute)
1. **Budget dashboard**:
   - Show the newly created budget in the budgets list
   - Click on the budget name to view details
   - Explain the budget performance chart

2. **Cost breakdown**:
   - Show **Actual vs Budgeted** comparison
   - Display **Forecasted** spend for the month
   - Review **Service breakdown** for the tagged resources

3. **Historical analysis**:
   - Show previous months' spending for the same project
   - Identify spending trends and patterns

## Advanced Budget Configurations

### Multi-Tag Project Budget
```
Filters:
- Tag: Project = "WebApp"
- Tag: Environment = "Production" 
- Tag: CostCenter = "Engineering"
```

### Service-Specific Project Budget
```
Filters:
- Tag: Project = "DataPipeline"
- Service: Amazon EC2
- Service: Amazon RDS
```

### Account-Specific Project Budget
```
Filters:
- Tag: Project = "MobileApp"
- Linked Account: "123456789012"
```

## Key Benefits Demonstrated
- **Project Cost Visibility**: Track spending for specific projects
- **Proactive Monitoring**: Get alerts before overspending
- **Cost Attribution**: Understand which projects drive costs
- **Budget Accountability**: Hold project teams accountable for spending
- **Trend Analysis**: Identify spending patterns over time

## Best Practices Highlighted
- **Consistent Tagging**: Ensure all project resources are properly tagged
- **Realistic Budgets**: Base budgets on historical data and project requirements
- **Multiple Alerts**: Set both actual and forecasted alerts
- **Regular Review**: Monitor and adjust budgets monthly
- **Stakeholder Notifications**: Include relevant team members in alerts

## Common Budget Scenarios

### Development Project Budget
- **Tags**: `Project=DevProject`, `Environment=Development`
- **Amount**: Lower budget for dev resources
- **Alerts**: 75% actual, 90% forecasted

### Production Application Budget
- **Tags**: `Project=ProdApp`, `Environment=Production`
- **Amount**: Higher budget for production workloads
- **Alerts**: 80% actual, 100% forecasted, 120% actual

### Department Budget
- **Tags**: `CostCenter=Engineering`
- **Amount**: Departmental allocation
- **Alerts**: Multiple thresholds with different recipients

### Temporary Project Budget
- **Tags**: `Project=Migration`, `Owner=DataTeam`
- **Duration**: 3-6 months
- **Alerts**: Aggressive thresholds due to temporary nature

## Troubleshooting Tips
- **No cost data**: Verify tags are activated and resources are tagged
- **Incorrect costs**: Check tag values match exactly (case-sensitive)
- **Missing alerts**: Verify email addresses and SNS topic configuration
- **Budget not updating**: Allow 24 hours for cost data to appear
- **Filter issues**: Ensure tag keys and values exist in your account

## Budget Actions (Advanced)
Configure automatic actions when budget thresholds are exceeded:
- **IAM Policy**: Restrict resource creation
- **EC2 Actions**: Stop or terminate instances
- **SNS Notifications**: Send to multiple channels
- **Lambda Functions**: Custom remediation actions

## Monitoring and Reporting
- **Budget Performance**: Track actual vs budgeted spend
- **Variance Analysis**: Identify significant deviations
- **Trend Reporting**: Monthly and quarterly spending trends
- **Cost Optimization**: Identify opportunities to reduce project costs

## Next Steps
After this demonstration, participants should:
1. Create budgets for all active projects using appropriate tags
2. Set up automated alerts for project stakeholders
3. Implement budget actions for cost control
4. Establish monthly budget review processes
5. Use budget data for project cost forecasting

## Integration Opportunities
- **Project Management Tools**: Export budget data to PM systems
- **Financial Systems**: Integrate with ERP for chargeback
- **DevOps Pipelines**: Include cost checks in deployment processes
- **Reporting Dashboards**: Create executive cost dashboards

## Documentation References
- [Managing your costs with AWS Budgets](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html)
- [Creating a budget](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-create.html)
- [Best practices for AWS Budgets](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-best-practices.html)
- [Configuring budget actions](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-controls.html)
- [Creating an Amazon SNS topic for budget notifications](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-sns-policy.html)
- [Using cost allocation tags](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html)

---
*Demo Duration: 5 minutes*  
*Skill Level: Intermediate*  
*Tools Used: AWS Console, AWS Budgets*
