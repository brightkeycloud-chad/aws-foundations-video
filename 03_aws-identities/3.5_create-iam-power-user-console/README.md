# Create IAM Power User Demonstration (5 minutes)

## Overview
This demonstration shows how to create an IAM user with PowerUser access using the AWS Management Console. A Power User has broad access to AWS services but cannot manage IAM users, groups, or organizational settings, making it ideal for developers and technical users who need extensive AWS access without full administrative privileges.

## Learning Objectives
By the end of this demonstration, participants will understand:
- The difference between PowerUser and Administrator access
- How to create an IAM user with PowerUserAccess policy
- What permissions PowerUser access provides and restricts
- When to use PowerUser access vs other permission levels

## Prerequisites
- AWS account with administrator access
- Access to the AWS Management Console
- Understanding of IAM concepts (users, policies, permissions)

## Demonstration Steps (5 minutes)

### Step 1: Navigate to IAM Service (30 seconds)
1. Sign in to the [AWS Management Console](https://console.aws.amazon.com/)
2. In the search bar, type "IAM" and select "IAM" from the results
3. Click on "Users" in the left navigation pane

### Step 2: Create New IAM User (1 minute)
1. Click the "Create user" button
2. **Specify user details:**
   - Enter **User name**: `PowerUser` (or preferred name like `DeveloperUser`)
   - Check "Provide user access to the AWS Management Console"
   - Select "I want to create an IAM user"
   - Click "Next"

### Step 3: Set Console Password (30 seconds)
1. **Console password options:**
   - Select "Custom password"
   - Enter a strong password (minimum 8 characters)
   - Optionally check "Users must create a new password at next sign-in"
   - Click "Next"

### Step 4: Attach PowerUser Policy (1.5 minutes)
1. **Set permissions:**
   - Select "Attach policies directly"
   - In the search box, type "PowerUserAccess"
   - Check the box next to "PowerUserAccess" policy
   - **Review the policy details:**
     - Click on the policy name to see details
     - Note: "Provides full access to AWS services and resources, but does not allow management of Users and groups"
   - Click "Next"

### Step 5: Review and Create User (1 minute)
1. **Review user details:**
   - Verify user name: `PowerUser`
   - Verify console access is enabled
   - Verify PowerUserAccess policy is attached
   - Review the permissions summary
   - Click "Create user"

### Step 6: Save User Credentials (30 seconds)
1. **Save the sign-in information:**
   - Console sign-in URL
   - User name
   - Password (if needed for sharing)
2. Click "Return to users list"

### Step 7: Test PowerUser Access (1 minute)
1. **Sign out** of the current session
2. **Sign in as the PowerUser:**
   - Use the console sign-in URL
   - Enter username and password
3. **Test allowed access:**
   - Navigate to EC2 service - ✅ Full access
   - Navigate to S3 service - ✅ Full access
   - Navigate to Lambda service - ✅ Full access
4. **Test restricted access:**
   - Navigate to IAM service
   - Try to view Users - ❌ Access denied
   - Try to create a new user - ❌ Access denied

## PowerUserAccess Policy Details

### What PowerUser CAN Do:
- **Full access** to most AWS services (EC2, S3, Lambda, RDS, etc.)
- **Create and manage** AWS resources
- **View** IAM roles (but not users or groups)
- **Create** service-linked roles
- **Access** account information and regions
- **Use** all AWS services for development and operations

### What PowerUser CANNOT Do:
- **Manage IAM users** or groups
- **Create or modify** IAM policies
- **Manage** AWS Organizations
- **Modify** account settings
- **Access** billing information
- **Perform** user management tasks

### Policy Structure:
```json
{
  "Effect": "Allow",
  "NotAction": [
    "iam:*",
    "organizations:*", 
    "account:*"
  ],
  "Resource": "*"
}
```

## Use Cases for PowerUser Access

### Ideal For:
- **Developers**: Need broad AWS access for building applications
- **DevOps Engineers**: Require extensive service access but not user management
- **Technical Teams**: Need operational access without administrative privileges
- **Contractors**: Temporary workers who need broad access but not user management

### Not Suitable For:
- **Account administrators**: Who need to manage users and billing
- **Security teams**: Who need to manage IAM policies and users
- **Compliance officers**: Who need access to organizational settings

## Security Best Practices Demonstrated
1. **Principle of least privilege**: PowerUser has broad but not unlimited access
2. **Separation of duties**: Separates operational access from user management
3. **Controlled access**: Prevents unauthorized user creation or policy changes
4. **Audit trail**: All actions are logged in CloudTrail

## Important Notes
- **PowerUser is still powerful**: Can access most AWS services and create resources
- **Cost implications**: PowerUsers can create expensive resources
- **No IAM management**: Cannot create users, groups, or modify policies
- **Service-linked roles**: Can create these special roles required by some services

## Troubleshooting
- **Access denied to IAM**: This is expected behavior for PowerUsers
- **Cannot create users**: PowerUsers don't have IAM user management permissions
- **Service issues**: PowerUsers should have access to most other AWS services

## Next Steps
After creating the PowerUser:
1. Enable MFA for enhanced security
2. Set up billing alerts to monitor resource usage
3. Create resource tagging policies for cost tracking
4. Consider using IAM groups for multiple PowerUsers

## Comparison with Other Access Levels

| Access Level | IAM Management | Service Access | Use Case |
|-------------|----------------|----------------|----------|
| **Administrator** | Full | Full | Account admins |
| **PowerUser** | Limited | Full | Developers/DevOps |
| **ReadOnly** | View only | View only | Auditors |
| **Custom** | Varies | Varies | Specific roles |

## Documentation References
- [PowerUserAccess AWS Managed Policy](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/PowerUserAccess.html)
- [Create an IAM User in Your AWS Account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
- [AWS Managed Policies for Job Functions](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html)
- [Managed Policies and Inline Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)

---
*This demonstration is part of the AWS Foundations training series focusing on AWS Identity and Access Management (IAM) fundamentals.*
