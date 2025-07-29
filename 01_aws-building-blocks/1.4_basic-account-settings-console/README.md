# Basic Account Settings Console - 5-Minute Demonstration

## Overview
This demonstration covers essential AWS account settings that every user should configure, including billing preferences, contact information, security settings, and account management features. Participants will learn to navigate and configure critical account settings through the AWS Console.

## Learning Objectives
By the end of this demonstration, participants will be able to:
- Access and navigate AWS account settings
- Configure billing preferences and notifications
- Update account contact information
- Understand security settings and best practices
- Set up basic account monitoring and alerts

## Prerequisites
- Active AWS account with appropriate permissions
- Access to AWS Management Console
- Understanding of basic AWS console navigation
- Account owner or administrator permissions recommended

## Demonstration Steps (5 minutes)

### Step 1: Accessing Account Settings (1 minute)
1. **Navigate to Account Settings**
   - Sign in to the AWS Management Console
   - Click on your account name in the top-right corner
   - Select "Account" from the dropdown menu
   - Alternative: Go directly to https://console.aws.amazon.com/billing/home#/account

2. **Account Information Overview**
   - Show the account ID and account name
   - Point out the primary contact information section
   - Explain the importance of keeping this information current

### Step 2: Contact Information Management (1.5 minutes)
1. **Primary Contact Information**
   - Review the current primary contact details
   - Explain that this is tied to the root user account
   - Show how to update contact information if needed
   - Emphasize the security implications of accurate contact info

2. **Alternate Contacts**
   - Navigate to the "Alternate Contacts" section
   - Demonstrate adding/updating alternate contacts for:
     - **Billing**: Receives billing-related communications
     - **Operations**: Receives operational notifications
     - **Security**: Receives security-related alerts
   - Best practice: Use distribution lists rather than individual emails
   - Show how to verify contact information

### Step 3: Billing Preferences Configuration (1.5 minutes)
1. **Access Billing Preferences**
   - Navigate to "Billing preferences" in the left sidebar
   - Or go directly to: https://console.aws.amazon.com/costmanagement/home#/preferences

2. **Invoice Delivery Preferences**
   - Show how to enable/disable PDF invoice delivery by email
   - Demonstrate adding additional invoice email addresses
   - Explain who receives invoices by default

3. **Alert Preferences**
   - Enable "Receive AWS Free Tier alerts"
   - Show how to set up billing alerts
   - Explain the importance of monitoring usage and costs

4. **Cost and Usage Reports**
   - Briefly show the detailed billing reports section
   - Explain legacy vs. current reporting options

### Step 4: Security and Access Settings (1 minute)
1. **Account Security**
   - Navigate to "Security credentials" from the account menu
   - Show Multi-Factor Authentication (MFA) settings
   - Demonstrate the importance of MFA for root account
   - Point out access keys section (emphasize not using root access keys)

2. **IAM Dashboard Access**
   - Quick navigation to IAM dashboard
   - Show security recommendations
   - Explain the principle of least privilege

3. **CloudTrail and Monitoring**
   - Briefly mention AWS CloudTrail for account activity logging
   - Show how to access CloudTrail from the console
   - Explain its role in security and compliance

## Key Configuration Checklist
During the demonstration, emphasize these critical settings:

### ✅ Essential Account Settings
- [ ] Verify primary contact information is accurate
- [ ] Set up alternate contacts for billing, operations, and security
- [ ] Enable PDF invoice delivery if desired
- [ ] Configure Free Tier alerts
- [ ] Enable MFA on root account
- [ ] Review and understand billing preferences
- [ ] Set up basic cost monitoring

### ⚠️ Security Best Practices
- Use strong, unique passwords
- Enable MFA on all accounts
- Regularly review account activity
- Use IAM users instead of root account for daily operations
- Keep contact information updated
- Monitor billing and usage regularly

## Common Configuration Scenarios

### Scenario 1: New Account Setup
1. Update primary contact information
2. Add alternate contacts for key functions
3. Enable billing alerts and Free Tier notifications
4. Configure MFA on root account
5. Set up basic cost monitoring

### Scenario 2: Team Account Management
1. Set up distribution lists for alternate contacts
2. Configure appropriate billing preferences
3. Establish cost monitoring and alerts
4. Document account settings for team reference

## Troubleshooting Common Issues
- **Cannot access billing information**: Check IAM permissions for billing access
- **Email notifications not received**: Verify email addresses and check spam folders
- **MFA setup issues**: Ensure time synchronization on authenticator device
- **Contact update failures**: Verify all required fields are completed correctly

## Key Takeaways
- Account settings are foundational to AWS security and cost management
- Regular review and updates of contact information are essential
- Billing preferences help manage costs and prevent surprises
- Security settings should be configured before deploying resources
- Alternate contacts ensure business continuity for critical notifications

## Next Steps
- Set up detailed billing alerts and budgets
- Configure AWS Organizations for multi-account management
- Implement comprehensive IAM policies
- Set up AWS Config for compliance monitoring
- Review and implement AWS Well-Architected Framework principles

## Additional Resources and Citations

### Primary Documentation
1. **Customizing your Billing preferences - AWS Billing**  
   https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-pref.html  
   *Complete guide to configuring billing preferences, invoice delivery, and alerts*

2. **Update AWS account contact information - AWS Security Incident Response User Guide**  
   https://docs.aws.amazon.com/security-ir/latest/userguide/update-account-contact-info.html  
   *Best practices for maintaining accurate account contact information*

3. **AWS account root user - AWS Identity and Access Management**  
   https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html  
   *Security guidance for root user management and access*

### Related Documentation
- **Managing your AWS payment preferences**: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/manage-payment-method.html
- **What is AWS Billing and Cost Management?**: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-what-is.html
- **AWS Account Management Reference Guide**: https://docs.aws.amazon.com/accounts/latest/reference/
- **IAM Best Practices**: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html

### Additional Resources
- **AWS Free Tier**: https://aws.amazon.com/free/
- **AWS Pricing Calculator**: https://calculator.aws/
- **AWS Well-Architected Framework**: https://aws.amazon.com/architecture/well-architected/

---
*This demonstration focuses on essential account settings that should be configured early in your AWS journey. Regular review and maintenance of these settings is recommended.*
