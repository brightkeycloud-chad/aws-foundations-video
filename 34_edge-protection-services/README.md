# AWS Foundations: Edge Protection Services (Module 34)

## Overview
This module contains demonstrations for AWS edge protection services, focusing on AWS WAF (Web Application Firewall) integration with CloudFront and other edge services. These demonstrations are designed to be delivered in a classroom or training environment.

## Module Structure

### 34.2 - Create WAF Web ACL (Console)
**Duration**: 5 minutes  
**Tool**: AWS Management Console  
**Focus**: Creating and configuring AWS WAF Web ACLs with managed rule groups

**Learning Objectives**:
- Understand AWS WAF Web ACL components
- Configure managed rule groups for common threats
- Set default actions for non-matching requests
- Navigate the AWS WAF console effectively

### 34.3 - Associate WAF with Edge Services (Console)
**Duration**: 5 minutes  
**Tool**: AWS Management Console  
**Focus**: Associating WAF Web ACLs with CloudFront distributions

**Learning Objectives**:
- Associate WAF Web ACLs with CloudFront distributions
- Understand the relationship between WAF and edge services
- Verify WAF protection is active
- Monitor WAF activity and metrics

## Prerequisites for All Demonstrations
- AWS account with appropriate permissions
- IAM permissions for AWS WAF and CloudFront services
- Access to AWS Management Console
- Basic understanding of web security concepts

## Required IAM Permissions
Ensure your IAM user or role has the following permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "wafv2:*",
                "cloudfront:*",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics"
            ],
            "Resource": "*"
        }
    ]
}
```

## Demonstration Flow
1. **Start with Demo 34.2**: Create a WAF Web ACL
2. **Continue with Demo 34.3**: Associate the Web ACL with CloudFront
3. **Optional**: Test the WAF rules and monitor activity

## Quick Start Guide

### For Demo 34.2 (Create WAF Web ACL):
```bash
cd 34.2_create-waf-web-acl-console
# Follow README.md instructions
# Run cleanup when done:
./cleanup.sh
```

### For Demo 34.3 (Associate WAF with Edge Services):
```bash
cd 34.3_associate-waf-with-edge-services-console
# Optional: Create demo CloudFront distribution
./setup-demo-distribution.sh
# Follow README.md instructions
# Run cleanup when done:
./cleanup.sh
```

## Key Concepts Covered

### AWS WAF
- Web Application Firewall for application layer protection
- Managed rule groups vs. custom rules
- Web ACL capacity units (WCUs)
- Integration with AWS services

### CloudFront Integration
- Edge-based security filtering
- Global distribution of WAF rules
- Performance impact considerations
- Monitoring and logging

### Security Best Practices
- Layered security approach
- Monitoring and alerting
- Regular rule updates
- Cost optimization

## Troubleshooting Common Issues

### Permission Errors
- Verify IAM permissions for WAF and CloudFront
- Ensure you're in the correct AWS region (US East for CloudFront)

### Resource Not Found
- Check AWS region (CloudFront resources are global but managed in US East)
- Verify resource names and IDs

### Association Failures
- Ensure CloudFront distribution is in "Deployed" status
- Check for existing WAF associations
- Verify Web ACL scope matches resource type

## Cost Considerations
- WAF charges per Web ACL, rule, and request
- CloudFront charges for requests and data transfer
- Monitor usage through AWS Cost Explorer
- Use AWS Pricing Calculator for estimates

## Additional Resources

### AWS Documentation
- [AWS WAF Developer Guide](https://docs.aws.amazon.com/waf/latest/developerguide/)
- [CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

### Training Materials
- [AWS Security Fundamentals](https://aws.amazon.com/training/course-descriptions/security-fundamentals/)
- [AWS WAF Workshop](https://catalog.workshops.aws/waf/en-US)

### Pricing Information
- [AWS WAF Pricing](https://aws.amazon.com/waf/pricing/)
- [CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/)

---

## Support and Feedback
For questions about these demonstrations or to report issues:
- Review the individual demo README files
- Check AWS documentation links provided
- Consult AWS Support for account-specific issues

*Module created for AWS Foundations training program*
