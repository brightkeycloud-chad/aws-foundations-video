#!/bin/bash

# CloudTrail Demo Validation Script
# This script checks that the CloudTrail demonstration was completed successfully

set -e

echo "=== CloudTrail Demo Validation ==="
echo

TRAIL_NAME="demo-cloudtrail-trail"
VALIDATION_PASSED=true

# Check if trail exists and is configured correctly
echo "1. Validating CloudTrail trail..."
if aws cloudtrail describe-trails --trail-name-list "$TRAIL_NAME" --query 'trailList[0].Name' --output text 2>/dev/null | grep -q "$TRAIL_NAME"; then
    echo "✅ Trail '$TRAIL_NAME' exists"
    
    # Get trail details
    TRAIL_DETAILS=$(aws cloudtrail describe-trails --trail-name-list "$TRAIL_NAME" --query 'trailList[0]' --output json)
    
    # Check multi-region
    IS_MULTI_REGION=$(echo "$TRAIL_DETAILS" | jq -r '.IsMultiRegionTrail')
    if [ "$IS_MULTI_REGION" = "true" ]; then
        echo "✅ Multi-region logging enabled"
    else
        echo "⚠️  Multi-region logging not enabled"
    fi
    
    # Check S3 bucket
    S3_BUCKET=$(echo "$TRAIL_DETAILS" | jq -r '.S3BucketName')
    echo "✅ S3 bucket configured: $S3_BUCKET"
    
    # Check if logging is active
    LOGGING_STATUS=$(aws cloudtrail get-trail-status --name "$TRAIL_NAME" --query 'IsLogging' --output text 2>/dev/null || echo "false")
    if [ "$LOGGING_STATUS" = "True" ]; then
        echo "✅ Trail is actively logging"
    else
        echo "❌ Trail is not logging"
        VALIDATION_PASSED=false
    fi
    
else
    echo "❌ Trail '$TRAIL_NAME' not found"
    VALIDATION_PASSED=false
fi
echo

# Check S3 bucket exists and has proper configuration
echo "2. Validating S3 bucket configuration..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_PREFIX="cloudtrail-logs-demo-${ACCOUNT_ID}"

BUCKETS=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '$BUCKET_PREFIX')].Name" --output text 2>/dev/null || echo "")

if [ -n "$BUCKETS" ]; then
    for BUCKET in $BUCKETS; do
        echo "✅ CloudTrail S3 bucket found: $BUCKET"
        
        # Check bucket policy exists
        if aws s3api get-bucket-policy --bucket "$BUCKET" &>/dev/null; then
            echo "✅ Bucket policy configured"
        else
            echo "⚠️  No bucket policy found (may be set by CloudTrail)"
        fi
        
        # Check for any log files (may take time to appear)
        LOG_COUNT=$(aws s3 ls "s3://$BUCKET/" --recursive | wc -l || echo "0")
        if [ "$LOG_COUNT" -gt 0 ]; then
            echo "✅ Log files present in bucket ($LOG_COUNT files)"
        else
            echo "⚠️  No log files yet (may take 15 minutes to appear)"
        fi
    done
else
    echo "❌ No CloudTrail S3 buckets found"
    VALIDATION_PASSED=false
fi
echo

# Check CloudWatch Logs integration (optional)
echo "3. Checking CloudWatch Logs integration..."
LOG_GROUP_NAME="CloudTrail/demo-trail"

if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP_NAME" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "$LOG_GROUP_NAME"; then
    echo "✅ CloudWatch Log Group exists: $LOG_GROUP_NAME"
    
    # Check for log streams
    STREAM_COUNT=$(aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --query 'length(logStreams)' --output text 2>/dev/null || echo "0")
    if [ "$STREAM_COUNT" -gt 0 ]; then
        echo "✅ Log streams present ($STREAM_COUNT streams)"
    else
        echo "⚠️  No log streams yet (may take time to appear)"
    fi
else
    echo "ℹ️  CloudWatch Logs integration not configured (optional feature)"
fi
echo

# Check recent events
echo "4. Checking for recent CloudTrail events..."
RECENT_EVENTS=$(aws cloudtrail lookup-events --max-items 5 --query 'length(Events)' --output text 2>/dev/null || echo "0")

if [ "$RECENT_EVENTS" -gt 0 ]; then
    echo "✅ Recent events found ($RECENT_EVENTS events)"
    echo "   Events should appear in CloudTrail console within 15 minutes"
else
    echo "⚠️  No recent events found (may take time to appear)"
fi
echo

# Final validation result
if [ "$VALIDATION_PASSED" = true ]; then
    echo "🎉 CloudTrail Demo Validation PASSED!"
    echo "✅ All core components are properly configured"
    echo "✅ Trail is active and logging"
    echo "✅ S3 bucket is configured for log storage"
    echo
    echo "Next steps:"
    echo "- Wait 15 minutes for events to appear in the console"
    echo "- Check the CloudTrail dashboard for recent activity"
    echo "- Run './cleanup.sh' when ready to remove demo resources"
else
    echo "❌ CloudTrail Demo Validation FAILED!"
    echo "Please review the issues above and re-run the demonstration steps."
fi
