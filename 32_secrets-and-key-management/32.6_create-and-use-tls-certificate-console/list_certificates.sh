#!/bin/bash

# Helper script to list all certificates in AWS Certificate Manager
# Useful for demonstration purposes

echo "Listing all certificates in AWS Certificate Manager"
echo "=================================================="

# List all certificates with key information
aws acm list-certificates --query 'CertificateSummaryList[*].{Domain:DomainName,Status:Status,Arn:CertificateArn}' --output table

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Certificates listed successfully!"
    echo ""
    echo "Certificate Status meanings:"
    echo "- PENDING_VALIDATION: Waiting for domain validation"
    echo "- ISSUED: Certificate is valid and ready to use"
    echo "- INACTIVE: Certificate validation failed"
    echo "- EXPIRED: Certificate has expired"
    echo "- VALIDATION_TIMED_OUT: Domain validation timed out"
    echo ""
    echo "💡 Use 'aws acm describe-certificate --certificate-arn <ARN>' for detailed information"
else
    echo "❌ Failed to list certificates. Please check:"
    echo "1. AWS CLI is configured correctly"
    echo "2. You have acm:ListCertificates permission"
    echo "3. You're in the correct AWS region"
fi
