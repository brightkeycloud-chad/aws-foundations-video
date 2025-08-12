# Deploy Organizations Service Control Policies (Console)

## Demonstration Overview
This 5-minute demonstration shows how to create and deploy Service Control Policies (SCPs) in AWS Organizations using the AWS Management Console to restrict actions across member accounts.

## Prerequisites
- AWS Organizations enabled with all features
- Management account access
- At least one member account or organizational unit (OU)
- Administrative permissions in the management account

## Demonstration Steps

### Step 1: Access AWS Organizations (1 minute)
1. Sign in to the AWS Management Console as the management account
2. Navigate to **AWS Organizations** service
3. Verify that your organization is set up with "All features" enabled
4. Review the organizational structure showing accounts and OUs

### Step 2: Create a Service Control Policy (2 minutes)
1. In the left navigation pane, click **Policies**
2. Click **Create policy**
3. Select **Service control policy** as the policy type
4. Enter policy details:
   - **Policy name**: `DenyEC2TerminateInstances`
   - **Description**: `Prevents termination of EC2 instances`
5. In the policy document editor, replace the default content with:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
```
6. Click **Create policy**

### Step 3: Attach Policy to Organizational Unit (1.5 minutes)
1. Navigate to **AWS accounts** in the left navigation
2. Select the target OU or account where you want to apply the policy
3. In the **Policies** tab on the right panel, click **Attach**
4. Select the `DenyEC2TerminateInstances` policy
5. Click **Attach policy**
6. Verify the policy appears in the attached policies list

### Step 4: Test and Verify Policy (0.5 minutes)
1. Explain that the policy is now active and will prevent EC2 instance termination
2. Show the policy inheritance structure in the organization
3. Demonstrate how to view effective policies for any account

## Key Learning Points
- SCPs provide guardrails for what actions can be performed in member accounts
- Policies are inherited down the organizational hierarchy
- SCPs only restrict permissions; they don't grant them
- The management account is never affected by SCPs

## Cleanup Instructions
After the demonstration, remove the test policy:
1. Navigate to the OU or account where the policy was attached
2. In the **Policies** tab, select the policy and click **Detach**
3. Go to **Policies** in the left navigation
4. Select the `DenyEC2TerminateInstances` policy
5. Click **Delete** and confirm the deletion

## Documentation References
- [AWS Organizations User Guide - Service Control Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
- [AWS Organizations User Guide - Creating and Managing SCPs](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_create.html)
- [AWS Organizations User Guide - Attaching and Detaching SCPs](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_attach-detach.html)
- [SCP Examples](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples.html)
