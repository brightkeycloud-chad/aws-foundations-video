# Enable Cost Allocation Tags Console Demo

## Overview
This 5-minute demonstration shows how to enable and manage cost allocation tags in the AWS Console to track and categorize AWS costs by business dimensions such as projects, departments, or environments.

## Prerequisites
- AWS account with billing access (management account or IAM user with billing permissions)
- Existing AWS resources with tags applied (EC2 instances, S3 buckets, etc.)
- Access to AWS Billing and Cost Management console

## Demonstration Steps (5 minutes)

### Step 1: Access Cost Allocation Tags Manager (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **Billing and Cost Management**
3. In the left navigation pane, click **Cost allocation tags**
4. Review the cost allocation tags overview page

### Step 2: Understand Tag Types (1 minute)
Explain the two types of cost allocation tags:

**AWS-Generated Tags:**
- Created automatically by AWS services
- Examples: `aws:createdBy`, `aws:cloudformation:stack-name`
- Use `aws:` prefix
- Track resource creation and management context

**User-Defined Tags:**
- Created and applied by users
- Examples: `Environment`, `Project`, `CostCenter`, `Owner`
- Use `user:` prefix in reports
- Track business-specific categorization

### Step 3: Activate AWS-Generated Tags (1 minute)
1. Click on the **AWS-generated cost allocation tags** tab
2. Review available AWS-generated tags:
   - `aws:createdBy` - Shows who created the resource
   - `aws:cloudformation:stack-name` - CloudFormation stack name
   - `aws:cloudformation:logical-id` - CloudFormation logical ID
3. Select tags to activate by checking the boxes
4. Click **Activate** to enable selected tags
5. Note: Tags take up to 24 hours to appear in reports

### Step 4: Activate User-Defined Tags (1.5 minutes)
1. Click on the **User-defined cost allocation tags** tab
2. Review the list of available user-defined tags from your resources
3. Common business tags to activate:
   - `Environment` (Production, Development, Testing)
   - `Project` (project names or codes)
   - `CostCenter` (department or cost center codes)
   - `Owner` (team or individual responsible)
   - `Application` (application or service name)

4. Select relevant tags by checking the boxes
5. Click **Activate** to enable selected tags
6. Demonstrate the status change from "Inactive" to "Active"

### Step 5: Apply Tags to Resources (1 minute)
1. Navigate to **EC2 Console** (open in new tab)
2. Select an EC2 instance
3. Click **Actions** → **Instance Settings** → **Manage tags**
4. Add cost allocation tags:
   - Key: `Environment`, Value: `Production`
   - Key: `Project`, Value: `WebApp`
   - Key: `CostCenter`, Value: `Engineering`
5. Click **Save**
6. Return to Billing console

### Step 6: Verify Tag Activation and Usage (1 minute)
1. Return to **Cost allocation tags** page
2. Refresh the page to see newly applied tags
3. Navigate to **Cost Explorer** (if available)
4. Click **Create report**
5. In the **Group by** section, select **Tag**
6. Choose one of your activated tags (e.g., `Environment`)
7. Show how costs can now be filtered and grouped by tag values

## Key Benefits Demonstrated
- **Cost Attribution**: Track costs by business dimensions
- **Detailed Reporting**: Break down costs by projects, departments, or environments
- **Budget Allocation**: Create budgets based on tag values
- **Cost Optimization**: Identify high-cost resources by category
- **Chargeback/Showback**: Allocate costs to appropriate business units

## Best Practices Highlighted
- **Consistent Tagging Strategy**: Use standardized tag keys and values
- **Early Activation**: Enable cost allocation tags before creating resources
- **Regular Review**: Periodically review and activate new tags
- **Governance**: Implement tag policies for consistent tagging
- **Documentation**: Maintain a tag taxonomy for your organization

## Common Tag Examples
- **Environment**: `Production`, `Development`, `Staging`, `Testing`
- **Project**: `ProjectAlpha`, `WebsiteRedesign`, `DataMigration`
- **CostCenter**: `Engineering`, `Marketing`, `Finance`, `Operations`
- **Owner**: `TeamA`, `john.doe@company.com`, `DataEngineering`
- **Application**: `WebApp`, `Database`, `Analytics`, `Backup`

## Troubleshooting Tips
- **Tags not appearing**: Wait 24 hours after activation
- **Missing tag values**: Ensure tags are applied to resources before activation
- **Access denied**: Verify billing permissions in IAM
- **Incomplete cost data**: Tags only track costs for resources created after activation
- **Case sensitivity**: Tag keys and values are case-sensitive

## Verification Steps
After the demonstration:
1. Check that selected tags show "Active" status
2. Verify tags appear in Cost Explorer grouping options
3. Confirm tagged resources show tag values in billing reports
4. Test filtering capabilities in Cost Explorer

## Next Steps
After this demonstration, participants should:
1. Develop a comprehensive tagging strategy for their organization
2. Apply consistent tags to existing resources
3. Set up automated tagging using AWS Config Rules or Lambda
4. Create cost allocation reports using activated tags
5. Implement tag policies in AWS Organizations (if applicable)

## Documentation References
- [Organizing and tracking costs using AWS cost allocation tags](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html)
- [Using user-defined cost allocation tags](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/custom-tags.html)
- [Activating AWS-generated tags cost allocation tags](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activate-built-in-tags.html)
- [Best Practices for Tagging AWS Resources](https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/tagging-best-practices.html)
- [Using Tag Editor](https://docs.aws.amazon.com/tag-editor/latest/userguide/tag-editor.html)

---
*Demo Duration: 5 minutes*  
*Skill Level: Beginner to Intermediate*  
*Tools Used: AWS Console*
