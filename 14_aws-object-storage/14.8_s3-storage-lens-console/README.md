# S3 Storage Lens Console Demonstration

## Overview
This 5-minute demonstration shows how to use Amazon S3 Storage Lens to gain visibility into storage usage, activity trends, and cost optimization opportunities across your S3 environment using the AWS Management Console.

## Learning Objectives
By the end of this demonstration, participants will be able to:
- Navigate to S3 Storage Lens in the AWS console
- Understand the default Storage Lens dashboard
- Interpret key storage metrics and recommendations
- Create a custom Storage Lens dashboard
- Configure metrics selection and scope
- Understand cost optimization insights provided by Storage Lens

## Prerequisites
- AWS account with S3 Storage Lens permissions
- Existing S3 buckets with some data (for meaningful metrics)
- Basic understanding of S3 storage classes and concepts
- Access to AWS Management Console

## Demonstration Steps

### Step 1: Access S3 Storage Lens (30 seconds)
1. Open the Amazon S3 console
2. In the left navigation pane, expand **"S3 Storage Lens"**
3. Click on **"Dashboards"**
4. Observe the default dashboard named "default-account-dashboard"
5. Click on the default dashboard to open it

### Step 2: Explore the Default Dashboard (1.5 minutes)
1. **Overview Section:**
   - Review the summary metrics at the top:
     - Total storage
     - Object count
     - Average object size
     - Accounts and buckets count
   - Explain that this provides a high-level view of your S3 usage

2. **Cost Optimization Tab:**
   - Click on the "Cost optimization" tab
   - Review metrics such as:
     - Incomplete multipart uploads
     - Non-current version bytes
     - Delete markers
   - Explain how these metrics help identify cost savings opportunities

3. **Data Protection Tab:**
   - Click on "Data protection" to view:
     - Encryption status
     - Object Lock configuration
     - Replication metrics
   - Emphasize the importance of data protection best practices

4. **Access Patterns Tab:**
   - Review access patterns and activity metrics
   - Show retrieval patterns and request metrics
   - Explain how this helps optimize storage class selection

### Step 3: Interpret Key Metrics and Recommendations (1 minute)
1. **Storage Metrics:**
   - Point out storage breakdown by storage class
   - Explain the cost implications of different storage classes
   - Show trends over time using the date range selector

2. **Recommendations:**
   - Highlight any contextual recommendations provided
   - Explain how recommendations help optimize costs and performance
   - Discuss the potential savings identified

3. **Drill-Down Capabilities:**
   - Demonstrate clicking on specific metrics to drill down
   - Show how to filter by account, region, or bucket
   - Explain the hierarchical view of data

### Step 4: Create a Custom Dashboard (2 minutes)
1. **Initiate Dashboard Creation:**
   - Navigate back to the Dashboards list
   - Click **"Create dashboard"**

2. **Configure Dashboard Scope:**
   - **General Settings:**
     - Enter dashboard name: "demo-custom-dashboard"
     - Note the home region (where metrics are stored)
     - Add optional tags:
       - Key: "Purpose", Value: "Training"
       - Key: "Team", Value: "Demo"

   - **Dashboard Scope:**
     - Choose to include specific regions or all regions
     - Demonstrate bucket inclusion/exclusion options
     - Explain when you might want to limit scope

3. **Configure Metrics Selection:**
   - **Free vs. Advanced Metrics:**
     - Show the difference between free and advanced metrics
     - Explain that free metrics are available for 14 days
     - Advanced metrics are available for 15 months (additional cost)
   
   - **Advanced Features (if demonstrating):**
     - CloudWatch publishing option
     - Prefix aggregation capabilities
     - Advanced metrics categories:
       - Activity metrics
       - Detailed status code metrics
       - Advanced cost optimization metrics
       - Advanced data protection metrics

### Step 5: Configure Optional Features (45 seconds)
1. **Metrics Export (Optional):**
   - Show the metrics export configuration
   - Explain CSV vs. Apache Parquet formats
   - Demonstrate destination bucket selection
   - Mention encryption options for exports

2. **Review and Create:**
   - Review all configuration settings
   - Click **"Create dashboard"**
   - Explain that it may take up to 48 hours for data to appear
   - Return to the dashboard list to verify creation

### Step 6: Best Practices and Use Cases (30 seconds)
1. **Monitoring Strategies:**
   - Regular review of cost optimization recommendations
   - Setting up automated exports for analysis
   - Using multiple dashboards for different organizational units

2. **Integration Opportunities:**
   - Combining with CloudWatch for alerting
   - Exporting data for custom analysis
   - Using insights for governance and compliance

## Key Features Highlighted

### Default Dashboard Benefits
- **No Configuration Required:** Automatically enabled for all accounts
- **Account-Wide Visibility:** Comprehensive view across all buckets
- **Historical Data:** 28 days of free metrics
- **Cost Insights:** Immediate identification of optimization opportunities

### Custom Dashboard Advantages
- **Targeted Analysis:** Focus on specific regions, buckets, or prefixes
- **Extended Retention:** Up to 15 months with advanced metrics
- **Enhanced Metrics:** Detailed activity and status code metrics
- **Automated Exports:** Regular data exports for external analysis

### Metrics Categories
1. **Summary Metrics:** Total storage, object count, average object size
2. **Cost Optimization:** Incomplete uploads, non-current versions, delete markers
3. **Data Protection:** Encryption, replication, Object Lock status
4. **Activity Metrics:** Request patterns, retrieval trends, error rates

## Cost Optimization Insights
- **Incomplete Multipart Uploads:** Identify and clean up failed uploads
- **Non-Current Versions:** Optimize versioning lifecycle policies
- **Storage Class Analysis:** Right-size storage class selection
- **Delete Markers:** Clean up unnecessary delete markers
- **Retrieval Patterns:** Optimize access patterns and storage classes

## Best Practices
- Review Storage Lens dashboards monthly for cost optimization
- Set up automated exports for trend analysis
- Use custom dashboards for specific organizational units
- Combine insights with lifecycle policies for automated optimization
- Monitor data protection metrics for compliance

## Limitations to Mention
- Data freshness: Metrics are updated daily, not real-time
- Advanced metrics have additional costs
- Some metrics require minimum data thresholds
- Configuration changes can take up to 48 hours to reflect

## Cleanup Instructions
To remove the custom dashboard:
1. Navigate to S3 Storage Lens > Dashboards
2. Select the custom dashboard
3. Click **"Delete"**
4. Confirm deletion
5. Note: Default dashboard cannot be deleted, only disabled

## Additional Resources and Citations

### AWS Documentation References
- [Create an Amazon S3 Storage Lens dashboard](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage_lens_creating_dashboard.html) - Comprehensive guide to creating custom dashboards
- [Amazon S3 Storage Lens metrics glossary](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage_lens_metrics_glossary.html) - Complete reference of available metrics
- [Metrics selection](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage_lens_basics_metrics_recommendations.html#storage_lens_basics_metrics_selection) - Understanding free vs. advanced metrics
- [View an Amazon S3 Storage Lens dashboard configuration details](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage_lens_viewing.html) - Managing and viewing dashboard configurations

### Cost and Pricing Information
- [Amazon S3 pricing](https://aws.amazon.com/s3/pricing/) - Storage Lens advanced metrics pricing
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/) - Additional cost optimization tools

### Related Services
- [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/) - Monitoring and alerting integration
- [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/) - Complementary cost analysis tools

---
*This demonstration is designed to be completed in approximately 5 minutes, providing participants with practical knowledge of S3 Storage Lens capabilities for storage optimization and monitoring.*
