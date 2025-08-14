# AWS Security Reporting Services - Demo Summary

This directory contains three 5-minute demonstrations focused on AWS security reporting services. Each demo includes comprehensive documentation, scripts, and cleanup procedures.

## Available Demonstrations

### 1. Enable Security Hub Standards (Console)
**Directory**: `33.6_enable-security-hub-standards-console/`
**Duration**: 6 minutes
**Tools**: AWS Console

**What you'll learn**:
- How to enable AWS Security Hub standards (updated 2025 list)
- Understanding different security standards (FSBP, Resource Tagging, CIS, NIST, PCI DSS, Control Tower)
- Strategic multi-standard enablement approach
- Viewing and interpreting security scores with real-time analysis
- Exploring security controls and remediation guidance
- Industry-specific standard recommendations

**Key Files**:
- `README.md` - Complete demonstration instructions with current standards
- `show-standards-info.sh` - Helper script showing current standards information
- No cleanup required (standards can remain enabled)

**Enhanced Features**:
- Current 2025 standards list (7 available standards)
- Interactive standards comparison
- Industry-specific recommendations
- Real-time compliance insights
- Multi-standard strategy demonstration

### 2. Explore Inspector Findings (Console)
**Directory**: `33.4_explore-inspector-findings-console/`
**Duration**: 5 minutes
**Tools**: AWS Console
**Setup Required**: Deploy vulnerable resources day before demo

**What you'll learn**:
- Navigating the Amazon Inspector dashboard
- Filtering and analyzing vulnerability findings
- Understanding severity levels and CVE information
- Exploring remediation guidance
- Exporting findings for reporting

**Key Files**:
- `README.md` - Complete demonstration instructions
- `DEPLOYMENT_GUIDE.md` - Quick setup guide for vulnerable resources
- `deploy-vulnerable-resources.sh` - Script to create vulnerable EC2, Lambda, ECR resources
- `cleanup-vulnerable-resources.sh` - Automated cleanup script
- `terraform/` - Terraform-based deployment option with cleanup

**Pre-Demo Setup** (Deploy day before):
- Creates 2 EC2 instances with vulnerable packages
- Creates Lambda function with outdated dependencies  
- Creates ECR repository with vulnerable container images
- Allows 2-4 hours for Inspector to generate findings

### 3. Deliver GuardDuty Findings to SNS (Console)
**Directory**: `33.2_deliver-guardduty-findings-to-sns-console/`
**Duration**: 5 minutes
**Tools**: AWS Console, EventBridge, SNS

**What you'll learn**:
- Setting up SNS topics for security notifications
- Configuring EventBridge rules for GuardDuty findings
- Testing the integration with sample findings
- Understanding automated incident response workflows

**Key Files**:
- `README.md` - Complete demonstration instructions
- `cleanup.sh` - Automated cleanup script
- `create-eventbridge-rule.sh` - Quick setup automation
- `generate-sample-findings.sh` - Sample findings generator

## Prerequisites

### Common Requirements
- AWS account with appropriate permissions
- AWS CLI configured (for automated scripts)
- Basic understanding of AWS security services

### Service-Specific Requirements
- **Security Hub**: AWS Config enabled (recommended)
- **Inspector**: EC2 instances or container images to scan
- **GuardDuty**: Service enabled in your region

## Quick Start Guide

### For Console-Only Demos (Security Hub, Inspector)
1. Navigate to the demo directory
2. Follow the step-by-step instructions in `README.md`
3. No cleanup required

### For GuardDuty SNS Demo
1. Navigate to `33.2_deliver-guardduty-findings-to-sns-console/`
2. **Option A - Manual Setup**: Follow `README.md` instructions
3. **Option B - Automated Setup**: Run `./create-eventbridge-rule.sh`
4. Test with sample findings: `./generate-sample-findings.sh`
5. Clean up resources: `./cleanup.sh`

## Learning Objectives

By completing these demonstrations, you will understand:

1. **Security Posture Management**
   - How to enable and configure security standards
   - Interpreting security scores and control findings
   - Best practices for compliance monitoring

2. **Vulnerability Management**
   - Identifying and prioritizing security vulnerabilities
   - Understanding CVE scoring and remediation guidance
   - Exporting findings for compliance reporting

3. **Incident Response Automation**
   - Setting up real-time security notifications
   - Configuring event-driven security workflows
   - Testing and validating security integrations

## Best Practices Demonstrated

- **Layered Security**: Using multiple AWS security services together
- **Automation**: Leveraging EventBridge for automated responses
- **Monitoring**: Continuous security posture assessment
- **Compliance**: Meeting industry security standards
- **Documentation**: Maintaining clear operational procedures

## Additional Resources

### AWS Security Services Documentation
- [AWS Security Hub User Guide](https://docs.aws.amazon.com/securityhub/latest/userguide/)
- [Amazon Inspector User Guide](https://docs.aws.amazon.com/inspector/latest/user/)
- [Amazon GuardDuty User Guide](https://docs.aws.amazon.com/guardduty/latest/ug/)

### AWS Console Links
- [Security Hub Console](https://console.aws.amazon.com/securityhub/)
- [Inspector Console](https://console.aws.amazon.com/inspector/v2/home)
- [GuardDuty Console](https://console.aws.amazon.com/guardduty/)
- [EventBridge Console](https://console.aws.amazon.com/events/)
- [SNS Console](https://console.aws.amazon.com/sns/)

### Integration Patterns
- [AWS Security Reference Architecture](https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/)
- [Security Hub Integrations](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-integrations.html)
- [EventBridge Integration Patterns](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-integrations.html)

---
*Total Demo Time: 15 minutes (3 demos × 5 minutes each)*  
*Last Updated: August 2025*  
*AWS Foundations Video Series - Module 33: Security Reporting Services*
