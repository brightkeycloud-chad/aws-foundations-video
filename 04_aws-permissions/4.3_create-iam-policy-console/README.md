# 4.3 Create IAM Policy - Console Demonstration

## Overview
This 5-minute demonstration shows how to create a custom IAM policy using the AWS Management Console. You'll learn to use both the Visual Editor and JSON Editor to create policies that grant specific permissions to AWS resources.

## Learning Objectives
By the end of this demonstration, participants will understand how to:
- Navigate to the IAM policy creation interface
- Use the Visual Editor to create policies without JSON knowledge
- Use the JSON Editor for advanced policy creation
- Apply security best practices when creating policies
- Test and validate policy syntax

## Prerequisites
- AWS account with administrative access
- Basic understanding of AWS services (S3, EC2)
- Understanding of IAM concepts (users, roles, permissions)

## Demonstration Scenario
We'll create a custom policy that allows read-only access to S3 buckets and the ability to list EC2 instances. This demonstrates both service-specific permissions and different access levels.

## Step-by-Step Instructions

### Part 1: Access IAM Policy Creation (1 minute)

1. **Sign in to AWS Console**
   - Navigate to [https://console.aws.amazon.com/iam/](https://console.aws.amazon.com/iam/)
   - Sign in with administrative credentials

2. **Navigate to Policies**
   - In the left navigation pane, click **Policies**
   - Click **Create policy** button

### Part 2: Create Policy Using Visual Editor (2 minutes)

1. **Select Service and Actions**
   - In the **Policy editor** section, ensure **Visual** is selected
   - In **Select a service**, search for and select **S3**
   - Under **Actions allowed**, expand **Read** access level
   - Select the following actions:
     - `GetObject`
     - `GetObjectVersion`
     - `ListBucket`

2. **Configure Resources**
   - In the **Resources** section, click **Add ARNs**
   - For bucket resources: Select **Any in this account**
   - For object resources: Select **Any in this account**

3. **Add Second Service**
   - Click **Add more permissions**
   - Search for and select **EC2**
   - Under **Actions allowed**, expand **List** access level
   - Select `DescribeInstances`
   - For Resources, select **All**

### Part 3: Review and Switch to JSON (1 minute)

1. **Switch to JSON View**
   - Click the **JSON** tab to see the generated policy
   - Review the JSON structure and explain key elements:
     - `Version`: Policy language version
     - `Statement`: Array of permission statements
     - `Effect`: Allow or Deny
     - `Action`: Specific API actions
     - `Resource`: ARNs of resources

2. **Validate Policy**
   - Note any warnings or suggestions from IAM Access Analyzer
   - Explain how the policy validator helps identify issues

### Part 4: Complete Policy Creation (1 minute)

1. **Add Policy Details**
   - Click **Next**
   - Enter **Policy Name**: `S3ReadOnlyEC2ListDemo`
   - Enter **Description**: `Allows read-only access to S3 and listing EC2 instances`

2. **Review and Create**
   - Review the **Permissions defined in this policy** section
   - Click **Create policy**

## Key Teaching Points

### Visual Editor Benefits
- No JSON knowledge required
- Guided interface prevents syntax errors
- Built-in validation and suggestions
- Easy to understand permission structure

### JSON Editor Advantages
- Full control over policy structure
- Ability to copy from examples
- Support for complex conditions
- Better for version control and automation

### Security Best Practices
- **Principle of Least Privilege**: Grant only necessary permissions
- **Specific Resources**: Avoid using `*` when possible
- **Regular Review**: Periodically audit and update policies
- **Policy Validation**: Always resolve security warnings

## Common Mistakes to Avoid
- Using overly broad permissions (`*` actions)
- Not specifying appropriate resources
- Ignoring policy validation warnings
- Creating policies without clear naming conventions

## Next Steps
After creating the policy:
1. Attach it to a test user or role
2. Test the permissions using the IAM Policy Simulator
3. Monitor usage through CloudTrail logs
4. Refine permissions based on actual usage patterns

## Troubleshooting Tips
- **Policy too large**: Break into multiple smaller policies
- **Syntax errors**: Use the Visual Editor to fix JSON issues
- **Access denied**: Check both identity-based and resource-based policies
- **Unexpected permissions**: Review all attached policies and inheritance

## Additional Resources and Citations

### AWS Documentation References
1. **Create IAM policies (console)** - [https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create-console.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create-console.html)
2. **Policies and permissions in AWS Identity and Access Management** - [https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)
3. **IAM policy testing with the IAM policy simulator** - [https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_testing-policies.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_testing-policies.html)

### Related Tools
- **AWS Policy Generator**: [https://awspolicygen.s3.amazonaws.com/policygen.html](https://awspolicygen.s3.amazonaws.com/policygen.html)
- **IAM Policy Simulator**: [https://policysim.aws.amazon.com/](https://policysim.aws.amazon.com/)

## Demonstration Notes
- **Total Time**: 5 minutes
- **Difficulty**: Beginner to Intermediate
- **Tools Used**: AWS Management Console
- **Services Covered**: IAM, S3, EC2
