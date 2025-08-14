# Create and Use TLS Certificate Console Demonstration

## Overview
This 5-minute demonstration shows how to request and manage TLS/SSL certificates using AWS Certificate Manager (ACM) through the AWS Console. You'll learn to request a public certificate, understand domain validation, and see how certificates integrate with AWS services.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- A domain name you control (for validation) OR willingness to use a demo domain
- Basic understanding of TLS/SSL certificates

## Demonstration Steps

### Step 1: Navigate to AWS Certificate Manager (0.5 minutes)
1. Sign in to the AWS Management Console
2. Navigate to **Certificate Manager** (ACM)
3. Ensure you're in the correct region (certificates are region-specific)
4. Click **Request a certificate**

### Step 2: Request Certificate Type (0.5 minutes)
1. Select **Request a public certificate**
2. Click **Next**

### Step 3: Add Domain Names (1 minute)
1. **Domain name**: Enter your domain (e.g., `demo.example.com`)
   - For demo purposes, you can use `demo-training.example.com`
2. Click **Add another name to this certificate** (optional)
3. Add wildcard domain: `*.demo.example.com` (optional)
4. Click **Next**

### Step 4: Select Validation Method (1 minute)
1. Choose **DNS validation** (recommended)
   - Explain: Requires adding CNAME record to DNS
   - More automated and doesn't expire
2. Alternative: **Email validation**
   - Explain: Sends validation emails to domain contacts
   - Requires manual intervention for renewal
3. Click **Next**

### Step 5: Add Tags and Review (0.5 minutes)
1. Add tags (optional):
   - Key: `Purpose`, Value: `Demo`
   - Key: `Environment`, Value: `Training`
2. Click **Next**
3. Review all settings
4. Click **Confirm and request**

### Step 6: Complete Domain Validation (1.5 minutes)
1. **For DNS Validation**:
   - Click **Create record in Route 53** (if using Route 53)
   - OR copy the CNAME record details to add to your DNS provider
   - Show the validation record format
2. **For Email Validation**:
   - Check email for validation message
   - Click the validation link in the email
3. Explain that validation can take several minutes to hours

### Step 7: View Certificate Details (1 minute)
1. Navigate back to Certificate Manager
2. Click on the certificate (may show "Pending validation")
3. Review certificate details:
   - Certificate ARN
   - Domain names
   - Validation status
   - Key algorithm
   - Signature algorithm
4. Show **Associated resources** tab (empty for new certificate)
5. Explain integration with:
   - Application Load Balancer
   - CloudFront
   - API Gateway
   - Elastic Beanstalk

## Key Learning Points
- ACM provides free SSL/TLS certificates for AWS services
- Certificates are region-specific
- DNS validation is preferred over email validation
- Automatic renewal for certificates in use
- Integration with multiple AWS services
- Wildcard certificates cover subdomains
- Private certificates available for internal use

## Certificate Integration Examples
Show how certificates are used with:
- **CloudFront**: Custom domain names for distributions
- **Application Load Balancer**: HTTPS listeners
- **API Gateway**: Custom domain names
- **Elastic Beanstalk**: HTTPS configuration

## Cleanup Instructions
After the demonstration, clean up resources:

1. Navigate to **Certificate Manager**
2. Select the demo certificate
3. Click **Actions** > **Delete**
4. Type `delete` to confirm
5. Click **Delete**

**Note**: Certificates in use by AWS services cannot be deleted until removed from those services.

## Additional Resources and Citations

### AWS Documentation References
- [AWS Certificate Manager User Guide](https://docs.aws.amazon.com/acm/latest/userguide/)
- [Requesting a Public Certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)
- [DNS Validation](https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html)
- [Email Validation](https://docs.aws.amazon.com/acm/latest/userguide/email-validation.html)
- [Using ACM Certificates with AWS Services](https://docs.aws.amazon.com/acm/latest/userguide/acm-services.html)

### Best Practices Documentation
- [ACM Best Practices](https://docs.aws.amazon.com/acm/latest/userguide/acm-bestpractices.html)
- [Certificate Transparency Logging](https://docs.aws.amazon.com/acm/latest/userguide/acm-concepts.html#concept-transparency)

### Integration Guides
- [Using ACM with CloudFront](https://docs.aws.amazon.com/acm/latest/userguide/acm-services.html#acm-cloudfront)
- [Using ACM with Application Load Balancer](https://docs.aws.amazon.com/acm/latest/userguide/acm-services.html#acm-elb)
- [Using ACM with API Gateway](https://docs.aws.amazon.com/acm/latest/userguide/acm-services.html#acm-apigateway)

## Troubleshooting
- **Validation pending**: Check DNS records are correctly configured
- **Validation failed**: Verify domain ownership and DNS propagation
- **Cannot delete certificate**: Remove from all AWS services first
- **Certificate not available in service**: Ensure certificate is in correct region
- **Wildcard certificate issues**: Verify proper wildcard syntax (`*.domain.com`)

## Demo Notes
- For training purposes, you can request a certificate for a domain you don't own to show the process
- The certificate will remain in "Pending validation" status, which is perfect for demonstration
- Emphasize that in production, proper domain validation is required
- Show both DNS and email validation options
- Highlight the regional nature of certificates
