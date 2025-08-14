# AWS Security Hub Standards Enablement Demo

## Overview
This 6-minute demonstration shows how to enable security standards in AWS Security Hub using the AWS Console. You'll learn to enable standards, understand their purpose, view the security score dashboard, and explore real-time compliance insights.

## Prerequisites
- AWS account with appropriate permissions
- AWS Security Hub enabled in your region
- AWS Config enabled and configured (recommended for accurate findings)

## Demo Steps (6 minutes)

### Step 1: Access AWS Security Hub (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **AWS Security Hub** service
3. If Security Hub is not enabled, click **Enable Security Hub**
4. Select your region from the top-right dropdown

### Step 2: Explore Available Security Standards (1.5 minutes)
1. In the Security Hub console, click **Security standards** in the left navigation pane
2. Review the **current available standards** (as of 2025):
   - **AWS Foundational Security Best Practices (FSBP)** - AWS's comprehensive security baseline
   - **AWS Resource Tagging Standard** - Ensures proper resource tagging
   - **CIS AWS Foundations Benchmark** - Industry-standard security configurations
   - **NIST SP 800-53 Revision 5** - Federal security framework
   - **NIST SP 800-171 Revision 2** - Controlled Unclassified Information protection
   - **PCI DSS** - Payment Card Industry Data Security Standard
   - **Service-managed standard: AWS Control Tower** - Multi-account governance

3. **Interactive Element**: Click on each standard to preview:
   - Number of controls included
   - Target compliance framework
   - Industry applicability

### Step 3: Enable Multiple Standards Strategically (2 minutes)
1. **Start with AWS FSBP** (most comprehensive):
   - Click **AWS Foundational Security Best Practices**
   - Note: **200+ controls** covering all major AWS services
   - Click **Enable** and observe the enablement process

2. **Add Resource Tagging Standard**:
   - Click **AWS Resource Tagging**
   - Explain: "Essential for cost management and governance"
   - Enable this standard as well

3. **Choose Industry-Specific Standard**:
   - For financial services: Enable **PCI DSS**
   - For government: Enable **NIST SP 800-53**
   - For general business: Enable **CIS AWS Foundations**
   - Demonstrate the selection process and explain use cases

### Step 4: Real-Time Standards Comparison (1.5 minutes)
1. Navigate back to **Security standards** overview
2. **Interactive Analysis**:
   - Compare control counts across enabled standards
   - Show overlapping vs. unique controls
   - Explain why multiple standards provide comprehensive coverage

3. **Live Demo Element**: 
   - Click on one enabled standard
   - Show the **control categories**:
     - **EC2** controls (compute security)
     - **S3** controls (data protection)
     - **IAM** controls (access management)
     - **CloudTrail** controls (audit logging)
     - **VPC** controls (network security)

### Step 5: Explore Control Details and Remediation (30 seconds)
1. Click on a specific control (e.g., "EC2.1 - Amazon EC2 Security Groups should not allow unrestricted access")
2. Show the detailed view:
   - **Control description** and rationale
   - **Remediation guidance** with step-by-step instructions
   - **Affected resources** (if any exist)
   - **Severity level** and compliance impact

### Step 6: Security Score Dashboard Deep Dive (30 seconds)
1. Navigate to **Summary** or return to **Security standards**
2. **Interactive Elements**:
   - View security scores for each enabled standard
   - Explain score calculation: (Passed controls / Total enabled controls) × 100
   - Show how scores update over time
   - Note: Initial scores appear within 30 minutes, update every 24 hours

## Enhanced Learning Points
- **Standards Evolution**: Security Hub continuously adds new standards based on industry needs
- **Multi-Standard Strategy**: Different standards serve different compliance requirements
- **Overlapping Controls**: Many controls appear across multiple standards, providing reinforcement
- **Resource Tagging**: Often overlooked but critical for governance and cost management
- **Real-Time Monitoring**: Standards provide continuous compliance monitoring, not just point-in-time assessments
- **Remediation Guidance**: Each control includes specific, actionable remediation steps
- **Score Trending**: Security scores help track improvement over time

## Interactive Demo Enhancements
- **Standards Comparison**: Show side-by-side control counts and purposes
- **Industry Mapping**: Explain which standards apply to different industries
- **Control Overlap Analysis**: Demonstrate how controls reinforce each other across standards
- **Live Remediation**: If time permits, show how to fix a simple control finding

## Cleanup
No cleanup required - Security Hub standards provide ongoing security value and should remain enabled for continuous monitoring.

**Optional**: To disable a standard for demo purposes:
1. Go to **Security standards**
2. Select the standard you want to disable
3. Click **Disable standard**
4. Confirm the action

## Additional Resources and Citations

### AWS Documentation References
- [Standards reference for Security Hub CSPM](https://docs.aws.amazon.com/securityhub/latest/userguide/standards-reference.html)
- [Enabling a security standard - AWS Security Hub](https://docs.aws.amazon.com/securityhub/latest/userguide/enable-standards.html)
- [What is AWS Security Hub CSPM?](https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html)
- [Calculating security scores](https://docs.aws.amazon.com/securityhub/latest/userguide/standards-security-score.html)
- [AWS Security Hub Console](https://console.aws.amazon.com/securityhub/)

### Standards Documentation
- [AWS Foundational Security Best Practices](https://docs.aws.amazon.com/securityhub/latest/userguide/standards-reference-fsbp.html)
- [CIS AWS Foundations Benchmark](https://docs.aws.amazon.com/securityhub/latest/userguide/standards-reference-cis.html)
- [NIST SP 800-53 Revision 5](https://docs.aws.amazon.com/securityhub/latest/userguide/standards-reference-nist-800-53.html)
- [PCI DSS Standard](https://docs.aws.amazon.com/securityhub/latest/userguide/standards-reference-pci-dss.html)

### Best Practices
- Enable AWS Config before enabling Security Hub standards for accurate findings
- Start with AWS Foundational Security Best Practices as your baseline
- Add industry-specific standards based on compliance requirements
- Use Resource Tagging standard for governance and cost management
- Set up notifications for critical findings using EventBridge
- Review and customize control settings based on your environment

### Industry Guidance
- **Financial Services**: FSBP + PCI DSS + CIS
- **Government/Federal**: FSBP + NIST SP 800-53 + NIST SP 800-171
- **Healthcare**: FSBP + CIS + Resource Tagging
- **General Enterprise**: FSBP + CIS + Resource Tagging + Control Tower

---
*Demo Duration: 6 minutes*  
*Last Updated: August 2025*  
*Standards Current as of: August 2025*
