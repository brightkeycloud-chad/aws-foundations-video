#!/bin/bash

# AWS GuardDuty Sample Findings Generation Script
# This script generates sample findings for testing the SNS integration

set -e

echo "🔍 Generating GuardDuty sample findings..."

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
    echo "✅ AWS CLI configured successfully"
}

# Function to check if GuardDuty is enabled
check_guardduty_enabled() {
    echo "🔄 Checking GuardDuty status..."
    
    DETECTORS=$(aws guardduty list-detectors --query 'DetectorIds' --output text)
    
    if [ -z "$DETECTORS" ] || [ "$DETECTORS" = "None" ]; then
        echo "❌ GuardDuty is not enabled in this region"
        echo "   Please enable GuardDuty first:"
        echo "   1. Go to GuardDuty console"
        echo "   2. Click 'Get started'"
        echo "   3. Click 'Enable GuardDuty'"
        exit 1
    fi
    
    DETECTOR_ID=$(echo $DETECTORS | awk '{print $1}')
    echo "✅ GuardDuty is enabled. Detector ID: $DETECTOR_ID"
}

# Function to generate sample findings
generate_sample_findings() {
    echo "🔄 Generating sample findings..."
    
    # Generate sample findings
    aws guardduty create-sample-findings \
        --detector-id "$DETECTOR_ID" \
        --finding-types \
            "Backdoor:EC2/C&CActivity.B!DNS" \
            "CryptoCurrency:EC2/BitcoinTool.B!DNS" \
            "Trojan:EC2/BlackholeTraffic" \
            "UnauthorizedAccess:EC2/MaliciousIPCaller.Custom"
    
    echo "✅ Sample findings generated successfully!"
    echo ""
    echo "📋 Generated finding types:"
    echo "   • Backdoor:EC2/C&CActivity.B!DNS (HIGH severity)"
    echo "   • CryptoCurrency:EC2/BitcoinTool.B!DNS (HIGH severity)"
    echo "   • Trojan:EC2/BlackholeTraffic (HIGH severity)"
    echo "   • UnauthorizedAccess:EC2/MaliciousIPCaller.Custom (MEDIUM severity)"
}

# Function to list generated findings
list_sample_findings() {
    echo "🔄 Listing sample findings..."
    
    # Wait a moment for findings to be processed
    sleep 3
    
    # List sample findings
    FINDINGS=$(aws guardduty list-findings \
        --detector-id "$DETECTOR_ID" \
        --finding-criteria '{"Criterion":{"type":{"Eq":["SampleFinding"]}}}' \
        --query 'FindingIds' \
        --output text)
    
    if [ ! -z "$FINDINGS" ] && [ "$FINDINGS" != "None" ]; then
        echo "✅ Sample findings created:"
        for FINDING_ID in $FINDINGS; do
            echo "   • $FINDING_ID"
        done
        
        echo ""
        echo "🔍 To view finding details:"
        echo "   aws guardduty get-findings --detector-id $DETECTOR_ID --finding-ids $FINDINGS"
    else
        echo "⏳ Sample findings may still be processing. Check the GuardDuty console in a few moments."
    fi
}

# Function to check EventBridge integration
check_eventbridge_integration() {
    echo "🔄 Checking EventBridge integration..."
    
    # Check if our rule exists
    if aws events describe-rule --name "guardduty-findings-to-sns" &> /dev/null; then
        echo "✅ EventBridge rule found: guardduty-findings-to-sns"
        echo "📧 Check your email for SNS notifications in the next few minutes"
    else
        echo "⚠️  EventBridge rule not found"
        echo "   Run ./create-eventbridge-rule.sh to set up the integration"
    fi
}

# Main execution
main() {
    echo "🚀 GuardDuty Sample Findings Generator"
    echo "====================================="
    
    check_aws_cli
    
    echo ""
    check_guardduty_enabled
    
    echo ""
    generate_sample_findings
    
    echo ""
    list_sample_findings
    
    echo ""
    check_eventbridge_integration
    
    echo ""
    echo "🎉 Sample findings generation completed!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Check GuardDuty console for the new findings"
    echo "   2. Verify SNS notifications in your email"
    echo "   3. Sample findings will be automatically archived after 15 minutes"
    echo ""
    echo "🔗 GuardDuty Console: https://console.aws.amazon.com/guardduty/"
}

# Run main function
main
