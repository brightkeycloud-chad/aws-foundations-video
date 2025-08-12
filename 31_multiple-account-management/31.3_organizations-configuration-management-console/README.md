# Organizations Configuration Management (Console)

## Demonstration Overview
This 5-minute demonstration shows how to configure and manage AWS Organizations, including creating organizational units (OUs), managing accounts, and implementing organizational policies using the AWS Management Console.

## Prerequisites
- AWS account with Organizations management permissions
- Understanding of organizational hierarchy concepts
- At least one additional AWS account to demonstrate account management
- Administrative access to the management account

## Demonstration Steps

### Step 1: Access and Review AWS Organizations (1 minute)
1. Sign in to the AWS Management Console as the management account
2. Navigate to **AWS Organizations** service
3. Review the current organization structure in the **AWS accounts** view
4. Explain the organization hierarchy: Root → OUs → Accounts
5. Show the organization ID and management account details

### Step 2: Create Organizational Units (1.5 minutes)
1. In the **AWS accounts** section, select the **Root** organizational unit
2. Click **Actions** → **Create organizational unit**
3. Create the first OU:
   - **Name**: `Production`
   - **Description**: `Production workload accounts`
4. Click **Create organizational unit**
5. Repeat to create a second OU:
   - **Name**: `Development`
   - **Description**: `Development and testing accounts`
6. Verify both OUs appear under the Root

### Step 3: Configure Account Management (1.5 minutes)
1. Click **Add an AWS account** → **Invite an existing AWS account**
2. Enter account details:
   - **Email or account ID**: Enter a test account email or ID
   - **Message**: `Invitation to join our AWS Organization`
3. Click **Send invitation** (Note: For demo purposes, explain the process without completing)
4. Navigate to **Invitations** to show pending invitations
5. Demonstrate how to move accounts between OUs:
   - Select an existing account
   - Click **Actions** → **Move**
   - Select the target OU (e.g., Development)

### Step 4: Configure Organization Policies (1 minute)
1. Navigate to **Policies** in the left navigation
2. Show the different policy types available:
   - Service control policies (SCPs)
   - Backup policies
   - Tag policies
   - AI services opt-out policies
3. Click on **Service control policies**
4. Review the default **FullAWSAccess** policy
5. Explain how policies can be created and attached to OUs or accounts

### Step 5: Review Organization Settings (1 minute)
1. Navigate to **Settings** in the left navigation
2. Review organization configuration:
   - Organization ID
   - Management account
   - Feature set (All features vs. Consolidated billing only)
3. Show **Trusted access for AWS services**
4. Explain the importance of enabling trusted access for services like:
   - AWS Config
   - AWS CloudTrail
   - AWS SSO (IAM Identity Center)

## Key Learning Points
- Organizations provide centralized management of multiple AWS accounts
- OUs help organize accounts by function, environment, or business unit
- Policies can be applied at different levels of the hierarchy
- Trusted access enables AWS services to work across the organization
- Account invitations require acceptance from the target account

## Cleanup Instructions
After the demonstration:
1. Cancel any pending account invitations
2. Move accounts back to their original OUs if changed
3. Delete the test OUs created during the demo:
   - Select the OU
   - Click **Actions** → **Delete**
   - Confirm deletion

## Documentation References
- [AWS Organizations User Guide](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html)
- [Creating and Managing Organizational Units](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_ous.html)
- [Inviting AWS Accounts to Join Your Organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_invites.html)
- [Managing AWS Accounts in Your Organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts.html)
- [Enabling Trusted Access with Other AWS Services](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services.html)
