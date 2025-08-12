#!/bin/bash

# Cleanup script for AWS Backup demonstration
# This script removes all backup resources created during the demonstration

echo "Starting cleanup for AWS Backup demonstration..."

# Set variables for resources created during demo
BACKUP_PLAN_NAME="DailyBackupPlan"
BACKUP_VAULT_NAME="DemoBackupVault"
RESOURCE_ASSIGNMENT_NAME="EC2InstanceBackup"
ORG_BACKUP_POLICY_NAME="OrgDailyBackupPolicy"

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "Error: AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
}

# Check AWS CLI configuration
check_aws_cli

# Clean up Organizations backup policy first
echo "Cleaning up Organizations backup policy..."
ORG_POLICY_ID=$(aws organizations list-policies --filter BACKUP_POLICY --query "Policies[?Name=='$ORG_BACKUP_POLICY_NAME'].Id" --output text)

if [ ! -z "$ORG_POLICY_ID" ]; then
    echo "Found Organizations backup policy ID: $ORG_POLICY_ID"
    
    # Get all targets (accounts/OUs) where this policy is attached
    echo "Finding targets where backup policy is attached..."
    TARGETS=$(aws organizations list-targets-for-policy --policy-id "$ORG_POLICY_ID" --query "Targets[].TargetId" --output text)
    
    # Detach policy from all targets
    if [ ! -z "$TARGETS" ]; then
        for TARGET in $TARGETS; do
            echo "Detaching backup policy from target: $TARGET"
            aws organizations detach-policy --policy-id "$ORG_POLICY_ID" --target-id "$TARGET"
            if [ $? -eq 0 ]; then
                echo "Successfully detached backup policy from $TARGET"
            else
                echo "Failed to detach backup policy from $TARGET"
            fi
        done
    else
        echo "No targets found for backup policy"
    fi
    
    # Delete the Organizations backup policy
    echo "Deleting Organizations backup policy: $ORG_BACKUP_POLICY_NAME"
    aws organizations delete-policy --policy-id "$ORG_POLICY_ID"
    if [ $? -eq 0 ]; then
        echo "Successfully deleted Organizations backup policy: $ORG_BACKUP_POLICY_NAME"
    else
        echo "Failed to delete Organizations backup policy: $ORG_BACKUP_POLICY_NAME"
    fi
else
    echo "Organizations backup policy $ORG_BACKUP_POLICY_NAME not found"
fi

# Get backup plan ID
echo "Finding backup plan: $BACKUP_PLAN_NAME..."
BACKUP_PLAN_ID=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='$BACKUP_PLAN_NAME'].BackupPlanId" --output text)

if [ ! -z "$BACKUP_PLAN_ID" ]; then
    echo "Found backup plan ID: $BACKUP_PLAN_ID"
    
    # Get resource assignments for this backup plan
    echo "Finding resource assignments..."
    ASSIGNMENT_IDS=$(aws backup list-backup-selections --backup-plan-id "$BACKUP_PLAN_ID" --query "BackupSelectionsList[].SelectionId" --output text)
    
    # Delete resource assignments
    if [ ! -z "$ASSIGNMENT_IDS" ]; then
        for ASSIGNMENT_ID in $ASSIGNMENT_IDS; do
            echo "Deleting resource assignment: $ASSIGNMENT_ID"
            aws backup delete-backup-selection --backup-plan-id "$BACKUP_PLAN_ID" --selection-id "$ASSIGNMENT_ID"
            if [ $? -eq 0 ]; then
                echo "Successfully deleted resource assignment: $ASSIGNMENT_ID"
            else
                echo "Failed to delete resource assignment: $ASSIGNMENT_ID"
            fi
        done
    else
        echo "No resource assignments found"
    fi
    
    # Delete backup plan
    echo "Deleting backup plan: $BACKUP_PLAN_NAME"
    aws backup delete-backup-plan --backup-plan-id "$BACKUP_PLAN_ID"
    if [ $? -eq 0 ]; then
        echo "Successfully deleted backup plan: $BACKUP_PLAN_NAME"
    else
        echo "Failed to delete backup plan: $BACKUP_PLAN_NAME"
    fi
else
    echo "Backup plan $BACKUP_PLAN_NAME not found"
fi

# Check for any backup jobs and wait for completion before deleting vault
echo "Checking for active backup jobs..."
ACTIVE_JOBS=$(aws backup list-backup-jobs --by-state RUNNING --query "BackupJobs[?BackupVaultName=='$BACKUP_VAULT_NAME'].JobId" --output text)

if [ ! -z "$ACTIVE_JOBS" ]; then
    echo "Warning: Active backup jobs found. Waiting for completion before deleting vault..."
    echo "Active job IDs: $ACTIVE_JOBS"
    echo "Please wait for jobs to complete, then manually delete the backup vault: $BACKUP_VAULT_NAME"
else
    # Delete backup vault (only if no recovery points exist)
    echo "Checking for recovery points in vault: $BACKUP_VAULT_NAME"
    RECOVERY_POINTS=$(aws backup list-recovery-points-by-backup-vault --backup-vault-name "$BACKUP_VAULT_NAME" --query "RecoveryPoints[].RecoveryPointArn" --output text 2>/dev/null)
    
    if [ -z "$RECOVERY_POINTS" ]; then
        echo "Deleting backup vault: $BACKUP_VAULT_NAME"
        aws backup delete-backup-vault --backup-vault-name "$BACKUP_VAULT_NAME"
        if [ $? -eq 0 ]; then
            echo "Successfully deleted backup vault: $BACKUP_VAULT_NAME"
        else
            echo "Failed to delete backup vault: $BACKUP_VAULT_NAME"
        fi
    else
        echo "Warning: Recovery points exist in vault $BACKUP_VAULT_NAME"
        echo "Please manually delete recovery points first, then delete the vault"
    fi
fi

echo "Cleanup completed!"
echo "Note: If any resources couldn't be deleted automatically, please remove them manually from the AWS Console"
