# 4.5 Create Resource Policy - Console Demonstration

## Overview
This 5-minute demonstration shows how to create and configure resource-based policies using the AWS Management Console. You'll learn the difference between identity-based and resource-based policies, and create an S3 bucket policy that grants cross-account access.

## Learning Objectives
By the end of this demonstration, participants will understand how to:
- Differentiate between identity-based and resource-based policies
- Create S3 bucket policies using the console
- Configure cross-account access permissions
- Use the AWS Policy Generator for resource policies
- Apply security best practices for resource-based policies

## Prerequisites
- AWS account with administrative access
- Basic understanding of AWS IAM concepts
- Familiarity with S3 bucket management
- Understanding of AWS account IDs and ARNs

## Demonstration Scenario
We'll create an S3 bucket policy that allows a specific external AWS account to read objects from our bucket while maintaining security controls. This demonstrates cross-account access patterns commonly used in enterprise environments.

## Key Concepts Review

### Identity-Based vs Resource-Based Policies
- **Identity-Based Policies**: Attached to users, groups, or roles (who can do what)
- **Resource-Based Policies**: Attached to resources like S3 buckets (what can be done to this resource)
- **Cross-Account Access**: Resource-based policies enable access from other AWS accounts

## Step-by-Step Instructions

### Part 1: Prepare S3 Bucket (1 minute)

1. **Navigate to S3 Console**
   - Go to [https://console.aws.amazon.com/s3/](https://console.aws.amazon.com/s3/)
   - Select an existing bucket or create a new one named `demo-resource-policy-bucket-[random-suffix]`

2. **Access Bucket Permissions**
   - Click on the bucket name
   - Navigate to the **Permissions** tab
   - Locate the **Bucket policy** section

### Part 2: Create Resource Policy Using Policy Generator (2 minutes)

1. **Open Policy Generator**
   - In the **Bucket policy** section, click **Edit**
   - Click **Policy generator** to open AWS Policy Generator in new window

2. **Configure Policy Generator**
   - **Select Type of Policy**: Choose **S3 Bucket Policy**
   - **Effect**: Select **Allow**
   - **Principal**: Enter external AWS account ID (format: `arn:aws:iam::123456789012:root`)
   - **AWS Service**: Select **Amazon S3**
   - **Actions**: Select:
     - `GetObject`
     - `GetObjectVersion`
     - `ListBucket`
   - **Amazon Resource Name (ARN)**: 
     - For bucket: `arn:aws:s3:::your-bucket-name`
     - For objects: `arn:aws:s3:::your-bucket-name/*`

3. **Generate Policy**
   - Click **Add Statement** for each resource type (bucket and objects)
   - Click **Generate Policy**
   - Copy the generated JSON policy

### Part 3: Apply and Validate Policy (1.5 minutes)

1. **Apply Policy to Bucket**
   - Return to the S3 console **Edit bucket policy** page
   - Paste the generated policy into the **Policy** text box
   - Review the policy structure:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "AWS": "arn:aws:iam::123456789012:root"
           },
           "Action": [
             "s3:GetObject",
             "s3:GetObjectVersion",
             "s3:ListBucket"
           ],
           "Resource": [
             "arn:aws:s3:::your-bucket-name",
             "arn:aws:s3:::your-bucket-name/*"
           ]
         }
       ]
     }
     ```

2. **Validate Policy**
   - Review any warnings from IAM Access Analyzer
   - Click **Preview external access** to see access analysis
   - Address any security recommendations

### Part 4: Advanced Configuration and Best Practices (0.5 minutes)

1. **Add Conditions (Optional)**
   - Demonstrate adding IP address restrictions:
     ```json
     "Condition": {
       "IpAddress": {
         "aws:SourceIp": "203.0.113.0/24"
       }
     }
     ```

2. **Save Policy**
   - Click **Save changes**
   - Verify policy is active in the **Permissions** tab

## Key Teaching Points

### Resource Policy Components
- **Principal**: Who is granted access (AWS accounts, users, roles)
- **Action**: What operations are allowed on the resource
- **Resource**: Specific resource ARNs the policy applies to
- **Condition**: Optional constraints on when policy applies

### Cross-Account Access Pattern
1. Resource owner creates resource-based policy
2. External account principal needs identity-based policy
3. Both policies must allow the action for access to succeed

### Security Considerations
- **Least Privilege**: Grant minimal necessary permissions
- **Principal Specification**: Be specific about who gets access
- **Condition Usage**: Add constraints like IP addresses, time windows
- **Regular Auditing**: Review and update policies periodically

## Common Use Cases for Resource-Based Policies

### S3 Bucket Policies
- Cross-account data sharing
- Public website hosting
- CloudFront origin access
- Cross-region replication

### Other AWS Services with Resource-Based Policies
- **Lambda**: Function resource policies for cross-account invocation
- **SNS**: Topic policies for cross-account publishing
- **SQS**: Queue policies for cross-account message sending
- **KMS**: Key policies for encryption key usage

## Security Best Practices

### Policy Design
- Use specific principals instead of wildcards
- Implement condition blocks for additional security
- Regular policy reviews and updates
- Monitor access patterns through CloudTrail

### Access Analysis
- Use IAM Access Analyzer to identify external access
- Review findings and ensure they're intentional
- Set up alerts for policy changes
- Document business justification for cross-account access

## Troubleshooting Common Issues

### Access Denied Errors
- Verify both resource-based and identity-based policies allow action
- Check for explicit deny statements
- Validate principal ARN format
- Confirm resource ARN accuracy

### Policy Validation Errors
- Check JSON syntax and formatting
- Verify ARN formats are correct
- Ensure required elements are present
- Review condition syntax

## Testing the Policy
1. **From External Account**: Attempt to access bucket objects
2. **AWS CLI Test**: Use `aws s3 ls` command from external account
3. **Policy Simulator**: Test policy logic before deployment
4. **CloudTrail Monitoring**: Verify access attempts are logged

## Additional Resources and Citations

### AWS Documentation References
1. **Adding a bucket policy by using the Amazon S3 console** - [https://docs.aws.amazon.com/AmazonS3/latest/userguide/add-bucket-policy.html](https://docs.aws.amazon.com/AmazonS3/latest/userguide/add-bucket-policy.html)
2. **Examples of Amazon S3 bucket policies** - [https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html)
3. **Policies and permissions in AWS Identity and Access Management** - [https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)

### Tools and Utilities
- **AWS Policy Generator**: [https://awspolicygen.s3.amazonaws.com/policygen.html](https://awspolicygen.s3.amazonaws.com/policygen.html)
- **IAM Policy Simulator**: [https://policysim.aws.amazon.com/](https://policysim.aws.amazon.com/)
- **IAM Access Analyzer**: Built into AWS Console for policy analysis

### Related Documentation
- **Cross account resource access in IAM**: [https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies-cross-account-resource-access.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies-cross-account-resource-access.html)
- **AWS services that work with IAM**: [https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html)

## Demonstration Notes
- **Total Time**: 5 minutes
- **Difficulty**: Intermediate
- **Tools Used**: AWS Management Console, AWS Policy Generator
- **Services Covered**: S3, IAM, Access Analyzer
- **Key Concept**: Resource-based policies for cross-account access
