# IAM Identity Center with External IdP (Console)

## Demonstration Overview
This 5-minute demonstration shows how to manage AWS IAM Identity Center when it's already configured with an external Identity Provider (IdP), focusing on permission sets, account assignments, and access management using the AWS Management Console.

## Prerequisites
- AWS Organizations enabled with all features
- IAM Identity Center already enabled and configured with external IdP (SAML 2.0, Azure AD, etc.)
- Management account access with administrative permissions
- At least one member account in the organization
- Existing users/groups synchronized from external IdP

## Demonstration Steps

### Step 1: Review Existing IAM Identity Center Configuration (1 minute)
1. Sign in to the AWS Management Console as the management account
2. Navigate to **IAM Identity Center** service
3. Review the Identity Center dashboard showing current configuration
4. Navigate to **Settings** and show the configured identity source:
   - **Identity source**: External identity provider (e.g., "Active Directory" or "SAML 2.0")
   - **Provider details**: Show the configured IdP information
5. Review **Multi-factor authentication** settings inherited from IdP

### Step 2: Review Synchronized Users and Groups (1 minute)
1. In the left navigation pane, click **Users**
2. Show existing users synchronized from the external IdP
3. Select a user to view their details and group memberships
4. Navigate to **Groups** to show synchronized groups from IdP
5. Select a group (e.g., "Engineering" or "Developers") to view members
6. Explain that user/group management happens in the external IdP, not in Identity Center

### Step 3: Create a New Permission Set (1.5 minutes)
1. In the left navigation pane, click **Permission sets**
2. Click **Create permission set**
3. Choose **Custom permission set**
4. Configure permission set details:
   - **Name**: `ReadOnlyAnalyst`
   - **Description**: `Read-only access for business analysts`
   - **Session duration**: 4 hours
5. Click **Next**
6. Choose **Attach AWS managed policies**
7. Search for and select:
   - `ReadOnlyAccess`
   - `AWSSupportUser`
8. Click **Next** through remaining steps
9. Review and click **Create**

### Step 4: Assign Permission Set to Accounts (1.5 minutes)
1. In the left navigation pane, click **AWS accounts**
2. Select a target AWS account (e.g., "Development" or "Staging")
3. Click **Assign users or groups**
4. Select **Groups** tab
5. Choose an existing group from your IdP (e.g., "Business-Analysts")
6. Click **Next**
7. Select the **ReadOnlyAnalyst** permission set created in Step 3
8. Click **Next** and review the assignment
9. Click **Submit**
10. Show the assignment appearing in the account's **Permission sets** tab

### Step 5: Review Access Portal and User Experience (1 minute)
1. Navigate to **Settings** in the left navigation
2. Show the **AWS access portal URL** that users access
3. Explain the user login flow:
   - Users go to the access portal URL
   - They're redirected to the external IdP for authentication
   - After authentication, they see their assigned AWS accounts and roles
4. Show **Application assignments** (if any applications are configured)
5. Review **Audit logs** to show access tracking capabilities

## Key Learning Points
- External IdP integration centralizes identity management outside AWS
- Users and groups are synchronized automatically from the external IdP
- Permission sets define AWS access levels and are managed in Identity Center
- Account assignments link IdP groups to AWS accounts with specific permission sets
- Users authenticate through their corporate IdP but access AWS resources seamlessly
- Session duration and MFA policies can be configured per permission set

## Testing Access (Optional)
If time permits, demonstrate:
1. Open the AWS access portal URL in an incognito/private browser window
2. Show the redirect to the external IdP login page
3. Explain how users would authenticate and then see their assigned accounts

## Cleanup Instructions
Run the provided cleanup script after the demonstration to remove the test permission set and assignments created during the demo.

## Documentation References
- [AWS IAM Identity Center User Guide](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
- [Connect to Your External Identity Provider](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source-idp.html)
- [Manage Your Identity Source in IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source.html)
- [Creating Permission Sets](https://docs.aws.amazon.com/singlesignon/latest/userguide/howtocreatepermissionset.html)
- [Assigning User Access to AWS Accounts](https://docs.aws.amazon.com/singlesignon/latest/userguide/useraccess.html)
- [Attribute-Based Access Control (ABAC)](https://docs.aws.amazon.com/singlesignon/latest/userguide/abac.html)
