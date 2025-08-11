#!/bin/bash

# Cleanup script for Amazon Q CLI Demo
# This script removes any resources that might have been created during the demonstration

echo "Starting cleanup of Amazon Q CLI demo resources..."

# Note: Amazon Q CLI itself doesn't create persistent AWS resources
# However, during the demo, users might have created resources following Q's suggestions
# This script will clean up common resources that might have been created

# Clean up any S3 buckets created during demo (with secure-documents pattern)
echo "Checking for demo S3 buckets..."
DEMO_BUCKETS=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `secure-documents-bucket`)].Name' --output text 2>/dev/null)

if [ ! -z "$DEMO_BUCKETS" ]; then
    for bucket in $DEMO_BUCKETS; do
        echo "Found demo bucket: $bucket"
        
        # Delete all objects in the bucket first
        aws s3 rm s3://$bucket --recursive 2>/dev/null
        
        # Delete all versions if versioning was enabled
        aws s3api delete-objects --bucket $bucket --delete "$(aws s3api list-object-versions --bucket $bucket --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json)" 2>/dev/null
        
        # Delete delete markers
        aws s3api delete-objects --bucket $bucket --delete "$(aws s3api list-object-versions --bucket $bucket --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' --output json)" 2>/dev/null
        
        # Delete the bucket
        aws s3api delete-bucket --bucket $bucket 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "Deleted demo bucket: $bucket"
        else
            echo "Could not delete bucket: $bucket (may not exist or have dependencies)"
        fi
    done
else
    echo "No demo S3 buckets found"
fi

# Clean up any KMS keys created for demo (with description containing "S3 bucket encryption")
echo "Checking for demo KMS keys..."
DEMO_KEYS=$(aws kms list-keys --query 'Keys[].KeyId' --output text 2>/dev/null)

if [ ! -z "$DEMO_KEYS" ]; then
    for key_id in $DEMO_KEYS; do
        KEY_DESC=$(aws kms describe-key --key-id $key_id --query 'KeyMetadata.Description' --output text 2>/dev/null)
        if [[ "$KEY_DESC" == *"S3 bucket encryption"* ]]; then
            echo "Found demo KMS key: $key_id"
            # Schedule key deletion (minimum 7 days)
            aws kms schedule-key-deletion --key-id $key_id --pending-window-in-days 7 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "Scheduled deletion for demo KMS key: $key_id"
            else
                echo "Could not schedule deletion for KMS key: $key_id"
            fi
        fi
    done
else
    echo "No demo KMS keys found"
fi

# Clean up any Lambda functions that might have been created during demo
echo "Checking for demo Lambda functions..."
DEMO_FUNCTIONS=$(aws lambda list-functions --query 'Functions[?contains(FunctionName, `demo`) || contains(FunctionName, `test`)].FunctionName' --output text 2>/dev/null)

if [ ! -z "$DEMO_FUNCTIONS" ]; then
    for function_name in $DEMO_FUNCTIONS; do
        echo "Found potential demo function: $function_name"
        # Only delete if it's clearly a demo function (be conservative)
        if [[ "$function_name" == *"demo"* ]] || [[ "$function_name" == *"test"* ]]; then
            aws lambda delete-function --function-name $function_name 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "Deleted demo Lambda function: $function_name"
            fi
        fi
    done
else
    echo "No demo Lambda functions found"
fi

# Clean up local files that might have been generated
echo "Cleaning up local generated files..."
rm -f *.py 2>/dev/null
rm -f *.sh 2>/dev/null
rm -f *.json 2>/dev/null
rm -f *.yaml 2>/dev/null
rm -f *.yml 2>/dev/null
rm -f *.tf 2>/dev/null

# Clear Amazon Q CLI cache (if any)
if [ -d "$HOME/.amazon-q" ]; then
    echo "Clearing Amazon Q CLI cache..."
    rm -rf "$HOME/.amazon-q/cache" 2>/dev/null
fi

echo "Cleanup completed!"
echo ""
echo "Note: Amazon Q CLI is a client-side tool and doesn't create persistent AWS resources."
echo "This cleanup script removed any demo resources that might have been created"
echo "following Amazon Q's suggestions during the demonstration."
echo ""
echo "If you created additional resources during the demo, please review and clean them up manually."
