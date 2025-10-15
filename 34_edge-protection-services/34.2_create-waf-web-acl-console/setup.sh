#!/bin/bash

# Demo 34.2: Create WAF Web ACL for CloudFront using AWS CLI
# This script creates a WAF Web ACL with managed rule groups including Bot Control

set -e

# Configuration
WEB_ACL_NAME="demo-web-acl"
WEB_ACL_DESCRIPTION="Demo Web ACL for edge protection"
METRIC_NAME="demoWebACL"
REGION="us-east-1"  # Required for CloudFront

echo "Creating WAF Web ACL: $WEB_ACL_NAME"

# Create the Web ACL with managed rule groups
WEB_ACL_ARN=$(aws wafv2 create-web-acl \
    --region $REGION \
    --scope CLOUDFRONT \
    --name "$WEB_ACL_NAME" \
    --description "$WEB_ACL_DESCRIPTION" \
    --default-action Allow={} \
    --rules '[
        {
            "Name": "AWSManagedRulesCommonRuleSet",
            "Priority": 1,
            "OverrideAction": {"None": {}},
            "Statement": {
                "ManagedRuleGroupStatement": {
                    "VendorName": "AWS",
                    "Name": "AWSManagedRulesCommonRuleSet"
                }
            },
            "VisibilityConfig": {
                "SampledRequestsEnabled": true,
                "CloudWatchMetricsEnabled": true,
                "MetricName": "CommonRuleSetMetric"
            }
        },
        {
            "Name": "AWSManagedRulesKnownBadInputsRuleSet",
            "Priority": 2,
            "OverrideAction": {"None": {}},
            "Statement": {
                "ManagedRuleGroupStatement": {
                    "VendorName": "AWS",
                    "Name": "AWSManagedRulesKnownBadInputsRuleSet"
                }
            },
            "VisibilityConfig": {
                "SampledRequestsEnabled": true,
                "CloudWatchMetricsEnabled": true,
                "MetricName": "KnownBadInputsMetric"
            }
        },
        {
            "Name": "AWSManagedRulesBotControlRuleSet",
            "Priority": 3,
            "OverrideAction": {"None": {}},
            "Statement": {
                "ManagedRuleGroupStatement": {
                    "VendorName": "AWS",
                    "Name": "AWSManagedRulesBotControlRuleSet"
                }
            },
            "VisibilityConfig": {
                "SampledRequestsEnabled": true,
                "CloudWatchMetricsEnabled": true,
                "MetricName": "BotControlMetric"
            }
        }
    ]' \
    --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName="$METRIC_NAME" \
    --query 'Summary.ARN' \
    --output text)

echo "✅ WAF Web ACL created successfully!"
echo "Web ACL ARN: $WEB_ACL_ARN"
echo "Web ACL Name: $WEB_ACL_NAME"
echo "Region: $REGION"
echo ""
echo "The Web ACL includes the following managed rule groups:"
echo "  - AWS Core Rule Set (Priority 1)"
echo "  - AWS Known Bad Inputs (Priority 2)"
echo "  - AWS Bot Control (Priority 3)"
echo ""
echo "To associate this Web ACL with a CloudFront distribution, use:"
echo "aws cloudfront update-distribution --id <distribution-id> --distribution-config file://distribution-config.json"
