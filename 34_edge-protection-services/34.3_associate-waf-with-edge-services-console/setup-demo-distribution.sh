#!/bin/bash

# Helper script to create a demo CloudFront distribution for WAF association demo
# This script creates a simple CloudFront distribution that can be used for demonstration

set -e

echo "🚀 Setting up demo CloudFront distribution for WAF association demo..."

# Set region
export AWS_DEFAULT_REGION=us-east-1

# Configuration
ORIGIN_DOMAIN="example.com"
COMMENT="Demo distribution for WAF association"
CALLER_REFERENCE="waf-demo-$(date +%s)"

echo "📋 Creating CloudFront distribution with:"
echo "  - Origin: $ORIGIN_DOMAIN"
echo "  - Comment: $COMMENT"
echo "  - Caller Reference: $CALLER_REFERENCE"

# Create distribution config JSON
cat > /tmp/distribution-config.json << EOF
{
    "CallerReference": "$CALLER_REFERENCE",
    "Comment": "$COMMENT",
    "Enabled": true,
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "demo-origin",
                "DomainName": "$ORIGIN_DOMAIN",
                "CustomOriginConfig": {
                    "HTTPPort": 80,
                    "HTTPSPort": 443,
                    "OriginProtocolPolicy": "https-only",
                    "OriginSslProtocols": {
                        "Quantity": 1,
                        "Items": ["TLSv1.2"]
                    }
                }
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "demo-origin",
        "ViewerProtocolPolicy": "redirect-to-https",
        "TrustedSigners": {
            "Enabled": false,
            "Quantity": 0
        },
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            }
        },
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000
    },
    "PriceClass": "PriceClass_100"
}
EOF

echo "🔨 Creating CloudFront distribution..."

# Create the distribution
RESULT=$(aws cloudfront create-distribution --distribution-config file:///tmp/distribution-config.json)

# Extract distribution ID and domain name
DISTRIBUTION_ID=$(echo "$RESULT" | jq -r '.Distribution.Id')
DOMAIN_NAME=$(echo "$RESULT" | jq -r '.Distribution.DomainName')
STATUS=$(echo "$RESULT" | jq -r '.Distribution.Status')

echo "✅ CloudFront distribution created successfully!"
echo ""
echo "📋 Distribution Details:"
echo "  - Distribution ID: $DISTRIBUTION_ID"
echo "  - Domain Name: $DOMAIN_NAME"
echo "  - Status: $STATUS"
echo ""
echo "⏳ Distribution is being deployed. This typically takes 10-15 minutes."
echo "💡 You can proceed with the WAF association demo while deployment is in progress."
echo ""
echo "🔗 CloudFront Console URL:"
echo "https://console.aws.amazon.com/cloudfront/v3/home?region=us-east-1#/distributions/$DISTRIBUTION_ID"
echo ""
echo "🌐 Distribution URL (available after deployment):"
echo "https://$DOMAIN_NAME"

# Clean up temp file
rm -f /tmp/distribution-config.json

echo ""
echo "🎉 Setup completed! You can now proceed with Demo 34.3."
