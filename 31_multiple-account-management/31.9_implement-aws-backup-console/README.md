# Implement AWS Backup (Console)

## Demonstration Overview
This 5-minute demonstration shows how to set up AWS Backup to create automated backups of AWS resources using the AWS Management Console, including creating backup plans, vaults, and policies.

## Prerequisites
- AWS account with appropriate permissions
- At least one EC2 instance or EBS volume to backup
- IAM permissions for AWS Backup service
- Understanding of backup retention requirements

## Demonstration Steps

### Step 1: Access AWS Backup Service (0.5 minutes)
1. Sign in to the AWS Management Console
2. Navigate to **AWS Backup** service
3. If first time using AWS Backup, you'll see the getting started page
4. Review the AWS Backup dashboard showing backup activity overview

### Step 2: Create a Backup Vault (1 minute)
1. In the left navigation pane, click **Backup vaults**
2. Click **Create backup vault**
3. Configure the vault:
   - **Backup vault name**: `DemoBackupVault`
   - **Encryption**: Use AWS managed key (default)
   - **Tags**: Add `Purpose: Demo` tag
4. Click **Create backup vault**
5. Verify the vault appears in the backup vaults list

### Step 3: Create a Backup Plan (2 minutes)
1. In the left navigation pane, click **Backup plans**
2. Click **Create backup plan**
3. Choose **Build a new plan**
4. Configure the backup plan:
   - **Backup plan name**: `DailyBackupPlan`
   - **Backup rule name**: `DailyBackupRule`
5. Configure backup rule settings:
   - **Backup vault**: Select `DemoBackupVault`
   - **Backup frequency**: Daily
   - **Backup window**: Use default (5:00 AM UTC)
   - **Lifecycle**: 
     - Delete after: 30 days
     - Transition to cold storage: Never
6. Click **Create plan**

### Step 4: Assign Resources to Backup Plan (1.5 minutes)
1. From the backup plan details page, click **Assign resources**
2. Configure resource assignment:
   - **Resource assignment name**: `EC2InstanceBackup`
   - **IAM role**: Create new service role (AWSBackupDefaultServiceRole)
3. Define resource selection:
   - **Resource type**: EC2
   - **Selection method**: Include specific resource types
   - **Resource type**: EC2 Instance
4. Add resource selection criteria:
   - **Key**: `tag:Environment`
   - **Value**: `Demo`
   - **Condition**: StringEquals
5. Click **Assign resources**

### Step 5: Create Organizations Backup Policy (1 minute)
1. Navigate to **AWS Organizations** service
2. In the left navigation pane, click **Policies**
3. Click **Create policy**
4. Select **Backup policy** as the policy type
5. Configure the backup policy:
   - **Policy name**: `OrgDailyBackupPolicy`
   - **Description**: `Organization-wide daily backup policy`
6. In the policy document editor, enter:
```json
{
  "plans": {
    "OrgBackupPlan": {
      "regions": {
        "@@assign": ["us-east-1", "us-west-2"]
      },
      "rules": {
        "DailyBackups": {
          "schedule_expression": {
            "@@assign": "cron(0 5 ? * * *)"
          },
          "start_backup_window_minutes": {
            "@@assign": "480"
          },
          "target_backup_vault": {
            "@@assign": "default"
          },
          "delete_after_days": {
            "@@assign": "30"
          }
        }
      },
      "selections": {
        "tags": {
          "BackupRequired": {
            "iam_role_arn": {
              "@@assign": "arn:aws:iam::$account:role/service-role/AWSBackupDefaultServiceRole"
            },
            "tag_key": {
              "@@assign": "BackupRequired"
            },
            "tag_value": {
              "@@assign": ["true"]
            }
          }
        }
      }
    }
  }
}
```
7. Click **Create policy**
8. Attach the policy to the Root OU or specific OUs as needed

### Step 6: Monitor and Verify Setup (0.5 minutes)
1. Navigate back to **AWS Backup** service
2. Navigate to **Jobs** to see backup job status
3. Review **Protected resources** to see assigned resources
4. Check **Backup vaults** to confirm vault creation
5. Explain that backups will run according to the schedule and organization policy

## Key Learning Points
- AWS Backup provides centralized backup across AWS services
- Backup vaults provide secure storage with encryption
- Backup plans define when and how backups are created
- Resource assignment uses tags and resource types for automation
- Organizations backup policies enable centralized backup governance across accounts
- Backup policies can be inherited through organizational hierarchy
- Lifecycle policies help manage backup costs

## Cleanup Instructions
Run the provided cleanup script after the demonstration to remove all created resources and avoid ongoing charges. The script will remove:
- Organizations backup policy and attachments
- Backup plan and resource assignments
- Backup vault (if no recovery points exist)

## Documentation References
- [AWS Backup User Guide](https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html)
- [Creating Backup Plans](https://docs.aws.amazon.com/aws-backup/latest/devguide/creating-a-backup-plan.html)
- [Creating Backup Vaults](https://docs.aws.amazon.com/aws-backup/latest/devguide/vaults.html)
- [Assigning Resources to Backup Plans](https://docs.aws.amazon.com/aws-backup/latest/devguide/assigning-resources.html)
- [AWS Backup IAM Policies](https://docs.aws.amazon.com/aws-backup/latest/devguide/iam-service-roles.html)
- [AWS Organizations Backup Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_backup.html)
- [Creating and Managing Backup Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_backup_create.html)
