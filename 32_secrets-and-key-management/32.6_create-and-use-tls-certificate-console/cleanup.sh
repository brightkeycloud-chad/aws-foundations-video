#!/bin/bash

# Cleanup script for TLS Certificate Console Demonstration
# This script deletes demo certificates from AWS Certificate Manager

echo "Starting cleanup for TLS Certificate Console Demonstration..."

# Look for certificates with demo-related domain names
DEMO_DOMAINS=("demo.example.com" "demo-training.example.com" "*.demo.example.com")

echo "Searching for demo certificates..."

# Get all certificates in the current region
CERTIFICATES=$(aws acm list-certificates --query 'CertificateSummaryList[*].{Arn:CertificateArn,Domain:DomainName}' --output json)

if [ $? -ne 0 ]; then
    echo "❌ Failed to list certificates. Please check AWS CLI configuration."
    exit 1
fi

# Check if any certificates exist
CERT_COUNT=$(echo "$CERTIFICATES" | jq length)
if [ "$CERT_COUNT" -eq 0 ]; then
    echo "No certificates found in this region."
    echo "Cleanup complete - no action needed."
    exit 0
fi

echo "Found $CERT_COUNT certificate(s) in this region."

# Look for demo certificates
DEMO_CERTS_FOUND=false

for domain in "${DEMO_DOMAINS[@]}"; do
    echo "Checking for certificates with domain: $domain"
    
    # Find certificates matching the demo domain
    CERT_ARNS=$(echo "$CERTIFICATES" | jq -r ".[] | select(.Domain == \"$domain\") | .Arn")
    
    if [ -n "$CERT_ARNS" ]; then
        DEMO_CERTS_FOUND=true
        echo "Found certificate(s) for domain $domain:"
        
        while IFS= read -r cert_arn; do
            if [ -n "$cert_arn" ]; then
                echo "  Certificate ARN: $cert_arn"
                
                # Check if certificate is in use
                echo "  Checking if certificate is in use..."
                CERT_DETAILS=$(aws acm describe-certificate --certificate-arn "$cert_arn" --query 'Certificate.InUseBy' --output json)
                IN_USE_COUNT=$(echo "$CERT_DETAILS" | jq length)
                
                if [ "$IN_USE_COUNT" -gt 0 ]; then
                    echo "  ⚠️  Certificate is in use by AWS services. Cannot delete."
                    echo "  Services using this certificate:"
                    echo "$CERT_DETAILS" | jq -r '.[]'
                    echo "  Please remove the certificate from these services first."
                else
                    echo "  Deleting certificate..."
                    aws acm delete-certificate --certificate-arn "$cert_arn"
                    
                    if [ $? -eq 0 ]; then
                        echo "  ✅ Successfully deleted certificate for domain: $domain"
                    else
                        echo "  ❌ Failed to delete certificate for domain: $domain"
                    fi
                fi
            fi
        done <<< "$CERT_ARNS"
    fi
done

if [ "$DEMO_CERTS_FOUND" = false ]; then
    echo "No demo certificates found with the expected domain names."
    echo "If you created certificates with different domain names, please delete them manually:"
    echo "1. Go to AWS Certificate Manager in the console"
    echo "2. Select the certificate(s) created during the demo"
    echo "3. Click 'Actions' > 'Delete'"
    echo "4. Type 'delete' to confirm"
fi

echo ""
echo "Cleanup script completed."
echo ""
echo "Note: If certificates were in 'Pending validation' status, they should now be deleted."
echo "If any certificates are still in use by AWS services, remove them from those services first."
