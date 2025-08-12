#!/bin/bash

# Cleanup script for Organizations Configuration Management demonstration
# This script removes test OUs and cancels invitations created during the demonstration

echo "Starting cleanup for Organizations Configuration Management demonstration..."

# Set variables for resources created during demo
PRODUCTION_OU_NAME="Production"
DEVELOPMENT_OU_NAME="Development"

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "Error: AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
}

# Check AWS CLI configuration
check_aws_cli

# Get the root ID
echo "Getting organization root ID..."
ROOT_ID=$(aws organizations list-roots --query "Roots[0].Id" --output text)

if [ -z "$ROOT_ID" ]; then
    echo "Error: Could not retrieve organization root ID"
    exit 1
fi

echo "Organization root ID: $ROOT_ID"

# Function to delete OU if it exists and is empty
delete_ou_if_exists() {
    local ou_name=$1
    echo "Checking for OU: $ou_name"
    
    # Find OU ID by name
    OU_ID=$(aws organizations list-organizational-units-for-parent --parent-id "$ROOT_ID" --query "OrganizationalUnits[?Name=='$ou_name'].Id" --output text)
    
    if [ ! -z "$OU_ID" ]; then
        echo "Found OU: $ou_name (ID: $OU_ID)"
        
        # Check if OU has any accounts
        ACCOUNTS=$(aws organizations list-accounts-for-parent --parent-id "$OU_ID" --query "Accounts[].Id" --output text)
        
        # Check if OU has any child OUs
        CHILD_OUS=$(aws organizations list-organizational-units-for-parent --parent-id "$OU_ID" --query "OrganizationalUnits[].Id" --output text)
        
        if [ -z "$ACCOUNTS" ] && [ -z "$CHILD_OUS" ]; then
            echo "Deleting empty OU: $ou_name"
            aws organizations delete-organizational-unit --organizational-unit-id "$OU_ID"
            if [ $? -eq 0 ]; then
                echo "Successfully deleted OU: $ou_name"
            else
                echo "Failed to delete OU: $ou_name"
            fi
        else
            echo "OU $ou_name is not empty. Please move accounts/child OUs first:"
            if [ ! -z "$ACCOUNTS" ]; then
                echo "  Accounts in OU: $ACCOUNTS"
            fi
            if [ ! -z "$CHILD_OUS" ]; then
                echo "  Child OUs: $CHILD_OUS"
            fi
        fi
    else
        echo "OU $ou_name not found"
    fi
}

# Delete test OUs
delete_ou_if_exists "$PRODUCTION_OU_NAME"
delete_ou_if_exists "$DEVELOPMENT_OU_NAME"

# Cancel any pending invitations
echo "Checking for pending invitations..."
PENDING_INVITATIONS=$(aws organizations list-handshakes-for-organization --filter ActionType=INVITE,State=OPEN --query "Handshakes[].Id" --output text)

if [ ! -z "$PENDING_INVITATIONS" ]; then
    echo "Found pending invitations: $PENDING_INVITATIONS"
    for INVITATION_ID in $PENDING_INVITATIONS; do
        echo "Canceling invitation: $INVITATION_ID"
        aws organizations cancel-handshake --handshake-id "$INVITATION_ID"
        if [ $? -eq 0 ]; then
            echo "Successfully canceled invitation: $INVITATION_ID"
        else
            echo "Failed to cancel invitation: $INVITATION_ID"
        fi
    done
else
    echo "No pending invitations found"
fi

echo "Cleanup completed!"
echo "Note: If any OUs couldn't be deleted due to containing accounts or child OUs,"
echo "please move those resources first, then manually delete the OUs from the AWS Console"
