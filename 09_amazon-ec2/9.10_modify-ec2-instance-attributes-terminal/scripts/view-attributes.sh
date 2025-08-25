#!/bin/bash

# EC2 Instance Attributes Demo - View Current Attributes
# This script displays current instance attributes

set -e  # Exit on any error

echo "=== EC2 Instance Attributes Demo - View Current Attributes ==="
echo

# Check if INSTANCE_ID is set
if [[ -z "$INSTANCE_ID" ]]; then
    echo "❌ INSTANCE_ID environment variable is not set."
    echo "Please run: export INSTANCE_ID=your-instance-id"
    echo "Or run ./scripts/setup.sh first to see available instances."
    exit 1
fi

echo "🔍 Viewing attributes for instance: $INSTANCE_ID"
echo

# Check if instance exists
if ! aws ec2 describe-instances --instance-ids "$INSTANCE_ID" &> /dev/null; then
    echo "❌ Instance $INSTANCE_ID not found or you don't have permission to access it."
    exit 1
fi

echo "📋 Instance Details:"
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].[InstanceId,InstanceType,State.Name,PublicIpAddress,PrivateIpAddress]' \
    --output table
echo

echo "🛡️  Termination Protection Status:"
TERMINATION_PROTECTION=$(aws ec2 describe-instance-attribute --instance-id "$INSTANCE_ID" --attribute disableApiTermination --query 'DisableApiTermination.Value' --output text)
if [[ "$TERMINATION_PROTECTION" == "True" ]]; then
    echo "✅ Enabled"
else
    echo "❌ Disabled"
fi
echo

echo "🔄 Source/Destination Check Status:"
SOURCE_DEST_CHECK=$(aws ec2 describe-instance-attribute --instance-id "$INSTANCE_ID" --attribute sourceDestCheck --query 'SourceDestCheck.Value' --output text)
if [[ "$SOURCE_DEST_CHECK" == "True" ]]; then
    echo "✅ Enabled"
else
    echo "❌ Disabled"
fi
echo

echo "🏷️  Security Groups:"
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].SecurityGroups[*].[GroupId,GroupName]' \
    --output table
echo

echo "💾 EBS Optimization Status:"
EBS_OPTIMIZED=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].EbsOptimized' --output text)
if [[ "$EBS_OPTIMIZED" == "True" ]]; then
    echo "✅ Enabled"
else
    echo "❌ Disabled"
fi
echo

echo "🔒 IMDS (Instance Metadata Service) Settings:"
# Get IMDS configuration
IMDS_INFO=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].MetadataOptions' --output json 2>/dev/null || echo "null")

if [[ "$IMDS_INFO" == "null" ]]; then
    echo "⚠️  IMDS settings not available (older instance or unsupported)"
else
    # Check if jq is available for better parsing
    if command -v jq &> /dev/null; then
        HTTP_TOKENS=$(echo "$IMDS_INFO" | jq -r '.HttpTokens // "unknown"')
        HTTP_ENDPOINT=$(echo "$IMDS_INFO" | jq -r '.HttpEndpoint // "unknown"')
        HOP_LIMIT=$(echo "$IMDS_INFO" | jq -r '.HttpPutResponseHopLimit // "unknown"')
        METADATA_TAGS=$(echo "$IMDS_INFO" | jq -r '.InstanceMetadataTags // "unknown"')
        
        echo "   HTTP Endpoint: $HTTP_ENDPOINT"
        echo "   HTTP Tokens: $HTTP_TOKENS"
        echo "   Hop Limit: $HOP_LIMIT"
        echo "   Instance Metadata Tags: $METADATA_TAGS"
        
        # Security assessment
        if [[ "$HTTP_TOKENS" == "required" ]]; then
            echo "   🟢 Security: Good (IMDSv2 required)"
        elif [[ "$HTTP_TOKENS" == "optional" ]]; then
            echo "   🟡 Security: Moderate (IMDSv1 allowed)"
        else
            echo "   ❓ Security: Unknown"
        fi
    else
        echo "   Raw IMDS Config: $IMDS_INFO"
        echo "   💡 Install 'jq' for better IMDS settings display"
    fi
fi
echo

echo "✅ Attribute viewing complete!"
