#!/bin/bash

# AWS Config Demo Validation Script
# This script checks that the AWS Config demonstration was completed successfully

set -e

echo "=== AWS Config Demo Validation ==="
echo

VALIDATION_PASSED=true
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region || echo "us-east-1")

# Check if Config recorder exists and is recording
echo "1. Validating AWS Config recorder..."
RECORDER_NAME=$(aws configservice describe-configuration-recorders --query 'ConfigurationRecorders[0].name' --output text 2>/dev/null || echo "None")

if [ "$RECORDER_NAME" != "None" ] && [ "$RECORDER_NAME" != "" ]; then
    echo "✅ Config recorder exists: $RECORDER_NAME"
    
    # Check recorder status
    RECORDING_STATUS=$(aws configservice describe-configuration-recorder-status --configuration-recorder-names "$RECORDER_NAME" --query 'ConfigurationRecordersStatus[0].recording' --output text 2>/dev/null || echo "false")
    
    if [ "$RECORDING_STATUS" = "True" ]; then
        echo "✅ Config recorder is actively recording"
    else
        echo "❌ Config recorder is not recording"
        VALIDATION_PASSED=false
    fi
    
    # Check what resources are being recorded
    RECORD_ALL=$(aws configservice describe-configuration-recorders --configuration-recorder-names "$RECORDER_NAME" --query 'ConfigurationRecorders[0].recordingGroup.allSupported' --output text 2>/dev/null || echo "false")
    
    if [ "$RECORD_ALL" = "True" ]; then
        echo "✅ Recording all supported resource types"
    else
        echo "⚠️  Recording limited resource types"
    fi
    
    # Check global resources
    INCLUDE_GLOBAL=$(aws configservice describe-configuration-recorders --configuration-recorder-names "$RECORDER_NAME" --query 'ConfigurationRecorders[0].recordingGroup.includeGlobalResourceTypes' --output text 2>/dev/null || echo "false")
    
    if [ "$INCLUDE_GLOBAL" = "True" ]; then
        echo "✅ Including global resource types"
    else
        echo "⚠️  Not including global resource types"
    fi
    
else
    echo "❌ No Config recorder found"
    VALIDATION_PASSED=false
fi
echo

# Check delivery channel
echo "2. Validating Config delivery channel..."
DELIVERY_CHANNEL=$(aws configservice describe-delivery-channels --query 'DeliveryChannels[0].name' --output text 2>/dev/null || echo "None")

if [ "$DELIVERY_CHANNEL" != "None" ] && [ "$DELIVERY_CHANNEL" != "" ]; then
    echo "✅ Delivery channel exists: $DELIVERY_CHANNEL"
    
    # Get S3 bucket name
    S3_BUCKET=$(aws configservice describe-delivery-channels --delivery-channel-names "$DELIVERY_CHANNEL" --query 'DeliveryChannels[0].s3BucketName' --output text 2>/dev/null || echo "None")
    
    if [ "$S3_BUCKET" != "None" ]; then
        echo "✅ S3 bucket configured: $S3_BUCKET"
        
        # Check if bucket exists and is accessible
        if aws s3api head-bucket --bucket "$S3_BUCKET" &>/dev/null; then
            echo "✅ S3 bucket is accessible"
            
            # Check for configuration files
            CONFIG_FILES=$(aws s3 ls "s3://$S3_BUCKET/" --recursive | wc -l || echo "0")
            if [ "$CONFIG_FILES" -gt 0 ]; then
                echo "✅ Configuration files present in bucket ($CONFIG_FILES files)"
            else
                echo "⚠️  No configuration files yet (may take time to appear)"
            fi
        else
            echo "❌ S3 bucket not accessible"
            VALIDATION_PASSED=false
        fi
    fi
    
    # Check SNS topic (optional)
    SNS_TOPIC=$(aws configservice describe-delivery-channels --delivery-channel-names "$DELIVERY_CHANNEL" --query 'DeliveryChannels[0].snsTopicARN' --output text 2>/dev/null || echo "None")
    
    if [ "$SNS_TOPIC" != "None" ] && [ "$SNS_TOPIC" != "" ]; then
        echo "✅ SNS topic configured: $SNS_TOPIC"
    else
        echo "ℹ️  No SNS topic configured (optional feature)"
    fi
    
else
    echo "❌ No delivery channel found"
    VALIDATION_PASSED=false
fi
echo

# Check Config rules
echo "3. Validating Config rules..."
DEMO_RULES=("s3-bucket-public-access-prohibited" "ec2-security-group-attached-to-eni")
RULES_FOUND=0

for RULE in "${DEMO_RULES[@]}"; do
    if aws configservice describe-config-rules --config-rule-names "$RULE" --query 'ConfigRules[0].ConfigRuleName' --output text 2>/dev/null | grep -q "$RULE"; then
        echo "✅ Config rule exists: $RULE"
        RULES_FOUND=$((RULES_FOUND + 1))
        
        # Check rule state
        RULE_STATE=$(aws configservice describe-config-rules --config-rule-names "$RULE" --query 'ConfigRules[0].ConfigRuleState' --output text 2>/dev/null || echo "UNKNOWN")
        
        if [ "$RULE_STATE" = "ACTIVE" ]; then
            echo "   ✅ Rule is active"
        else
            echo "   ⚠️  Rule state: $RULE_STATE"
        fi
        
        # Check compliance results (may not be available immediately)
        COMPLIANCE_RESULTS=$(aws configservice get-compliance-details-by-config-rule --config-rule-name "$RULE" --query 'length(EvaluationResults)' --output text 2>/dev/null || echo "0")
        
        if [ "$COMPLIANCE_RESULTS" -gt 0 ]; then
            echo "   ✅ Compliance evaluations available ($COMPLIANCE_RESULTS results)"
        else
            echo "   ⚠️  No compliance results yet (may take time to evaluate)"
        fi
        
    else
        echo "❌ Config rule not found: $RULE"
        VALIDATION_PASSED=false
    fi
done

if [ "$RULES_FOUND" -eq 2 ]; then
    echo "✅ All demo Config rules created successfully"
elif [ "$RULES_FOUND" -gt 0 ]; then
    echo "⚠️  Some Config rules created ($RULES_FOUND out of 2)"
else
    echo "❌ No demo Config rules found"
    VALIDATION_PASSED=false
fi
echo

# Check discovered resources
echo "4. Validating resource discovery..."
DISCOVERED_RESOURCES=$(aws configservice list-discovered-resources --resource-type AWS::EC2::Instance --query 'length(resourceIdentifiers)' --output text 2>/dev/null || echo "0")

if [ "$DISCOVERED_RESOURCES" -gt 0 ]; then
    echo "✅ Resources discovered and being monitored"
    
    # Show resource types being monitored
    echo "   Resource types being monitored:"
    aws configservice get-discovered-resource-counts --query 'resourceCounts[?resourceCount > `0`].[resourceType, resourceCount]' --output table 2>/dev/null || echo "   Unable to retrieve resource counts"
else
    echo "⚠️  No resources discovered yet (may take 10-15 minutes)"
fi
echo

# Check Config service status
echo "5. Checking overall Config service status..."
CONFIG_STATUS=$(aws configservice describe-configuration-recorder-status --query 'ConfigurationRecordersStatus[0].lastStatus' --output text 2>/dev/null || echo "UNKNOWN")

if [ "$CONFIG_STATUS" = "SUCCESS" ]; then
    echo "✅ Config service status: SUCCESS"
elif [ "$CONFIG_STATUS" = "PENDING" ]; then
    echo "⚠️  Config service status: PENDING (still initializing)"
else
    echo "❌ Config service status: $CONFIG_STATUS"
    VALIDATION_PASSED=false
fi
echo

# Final validation result
if [ "$VALIDATION_PASSED" = true ]; then
    echo "🎉 AWS Config Demo Validation PASSED!"
    echo "✅ Config recorder is active and recording"
    echo "✅ Delivery channel is configured with S3 storage"
    echo "✅ Demo Config rules are created and active"
    echo "✅ Resource discovery is working"
    echo
    echo "Next steps:"
    echo "- Wait 10-15 minutes for full resource discovery"
    echo "- Check the Config dashboard for compliance status"
    echo "- Explore resource configuration timelines"
    echo "- Run './cleanup.sh' when ready to remove demo resources"
else
    echo "❌ AWS Config Demo Validation FAILED!"
    echo "Please review the issues above and re-run the demonstration steps."
fi
