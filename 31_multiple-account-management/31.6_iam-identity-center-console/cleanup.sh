#!/bin/bash

# Cleanup script for IAM Identity Center with External IdP demonstration
# This script removes test permission sets and assignments created during the demonstration
# Note: Users and groups are managed by external IdP and should not be deleted

echo "Starting cleanup for IAM Identity Center with External IdP demonstration..."

# Set variables for resources created during demo
PERMISSION_SET_NAME="ReadOnlyAnalyst"

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "Error: AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
}

# Check AWS CLI configuration
check_aws_cli

# Get the Identity Center instance ARN
echo "Getting IAM Identity Center instance..."
INSTANCE_ARN=$(aws sso-admin list-instances --query "Instances[0].InstanceArn" --output text)

if [ -z "$INSTANCE_ARN" ] || [ "$INSTANCE_ARN" = "None" ]; then
    echo "Error: IAM Identity Center instance not found or not enabled"
    exit 1
fi

echo "Identity Center instance ARN: $INSTANCE_ARN"

# Function to remove account assignments for a permission set
remove_account_assignments() {
    local permission_set_arn=$1
    echo "Removing account assignments for permission set..."
    
    # Get all account assignments for this permission set
    aws sso-admin list-account-assignments --instance-arn "$INSTANCE_ARN" --permission-set-arn "$permission_set_arn" --query "AccountAssignments[]" --output json > /tmp/assignments.json
    
    # Process each assignment
    if [ -s /tmp/assignments.json ] && [ "$(cat /tmp/assignments.json)" != "[]" ]; then
        while IFS= read -r assignment; do
            ACCOUNT_ID=$(echo "$assignment" | jq -r '.AccountId')
            PRINCIPAL_TYPE=$(echo "$assignment" | jq -r '.PrincipalType')
            PRINCIPAL_ID=$(echo "$assignment" | jq -r '.PrincipalId')
            
            echo "Removing assignment: Account=$ACCOUNT_ID, Principal=$PRINCIPAL_ID, Type=$PRINCIPAL_TYPE"
            aws sso-admin delete-account-assignment \
                --instance-arn "$INSTANCE_ARN" \
                --permission-set-arn "$permission_set_arn" \
                --target-type AWS_ACCOUNT \
                --target-id "$ACCOUNT_ID" \
                --principal-type "$PRINCIPAL_TYPE" \
                --principal-id "$PRINCIPAL_ID"
                
            if [ $? -eq 0 ]; then
                echo "Successfully removed assignment"
            else
                echo "Failed to remove assignment"
            fi
        done < <(cat /tmp/assignments.json | jq -c '.[]')
    else
        echo "No account assignments found"
    fi
    
    rm -f /tmp/assignments.json
}

# Find and delete permission set
echo "Finding permission set: $PERMISSION_SET_NAME"
PERMISSION_SET_ARN=$(aws sso-admin list-permission-sets --instance-arn "$INSTANCE_ARN" --query "PermissionSets[]" --output text | while read arn; do
    name=$(aws sso-admin describe-permission-set --instance-arn "$INSTANCE_ARN" --permission-set-arn "$arn" --query "PermissionSet.Name" --output text)
    if [ "$name" = "$PERMISSION_SET_NAME" ]; then
        echo "$arn"
        break
    fi
done)

if [ ! -z "$PERMISSION_SET_ARN" ]; then
    echo "Found permission set ARN: $PERMISSION_SET_ARN"
    
    # Remove account assignments first
    remove_account_assignments "$PERMISSION_SET_ARN"
    
    # Wait a moment for assignments to be fully removed
    echo "Waiting for assignments to be removed..."
    sleep 10
    
    # Delete permission set
    echo "Deleting permission set: $PERMISSION_SET_NAME"
    aws sso-admin delete-permission-set --instance-arn "$INSTANCE_ARN" --permission-set-arn "$PERMISSION_SET_ARN"
    if [ $? -eq 0 ]; then
        echo "Successfully deleted permission set: $PERMISSION_SET_NAME"
    else
        echo "Failed to delete permission set: $PERMISSION_SET_NAME"
    fi
else
    echo "Permission set $PERMISSION_SET_NAME not found"
fi

echo "Cleanup completed!"
echo ""
echo "Note: Users and groups are managed by your external Identity Provider"
echo "and were not modified during this demonstration."
echo "If any permission sets couldn't be deleted automatically,"
echo "please remove them manually from the AWS Console."
