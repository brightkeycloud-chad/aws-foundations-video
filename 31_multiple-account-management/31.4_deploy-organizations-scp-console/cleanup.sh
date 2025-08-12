#!/bin/bash

# Cleanup script for Organizations SCP demonstration
# This script removes the test SCP policy created during the demonstration

echo "Starting cleanup for Organizations SCP demonstration..."

# Set the policy name created during the demo
POLICY_NAME="DenyEC2TerminateInstances"

# Get the policy ID
echo "Finding policy ID for $POLICY_NAME..."
POLICY_ID=$(aws organizations list-policies --filter SERVICE_CONTROL_POLICY --query "Policies[?Name=='$POLICY_NAME'].Id" --output text)

if [ -z "$POLICY_ID" ]; then
    echo "Policy $POLICY_NAME not found. It may have already been deleted."
    exit 0
fi

echo "Found policy ID: $POLICY_ID"

# Get all targets (accounts/OUs) where this policy is attached
echo "Finding targets where policy is attached..."
TARGETS=$(aws organizations list-targets-for-policy --policy-id "$POLICY_ID" --query "Targets[].TargetId" --output text)

# Detach policy from all targets
if [ ! -z "$TARGETS" ]; then
    for TARGET in $TARGETS; do
        echo "Detaching policy from target: $TARGET"
        aws organizations detach-policy --policy-id "$POLICY_ID" --target-id "$TARGET"
        if [ $? -eq 0 ]; then
            echo "Successfully detached policy from $TARGET"
        else
            echo "Failed to detach policy from $TARGET"
        fi
    done
else
    echo "No targets found for this policy"
fi

# Delete the policy
echo "Deleting policy $POLICY_NAME..."
aws organizations delete-policy --policy-id "$POLICY_ID"

if [ $? -eq 0 ]; then
    echo "Successfully deleted policy $POLICY_NAME"
    echo "Cleanup completed successfully!"
else
    echo "Failed to delete policy $POLICY_NAME"
    echo "Please manually delete the policy from the AWS Console"
    exit 1
fi
