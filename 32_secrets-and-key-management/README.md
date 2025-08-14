# AWS Secrets and Key Management Demonstrations

This directory contains three comprehensive 5-minute demonstrations covering AWS security services for secrets and key management. Each demonstration includes detailed instructions, scripts, and cleanup procedures.

## Demonstrations Overview

### 32.2 Create and Use KMS Key Console
**Duration**: 5 minutes  
**Tools**: AWS Console  
**Focus**: AWS Key Management Service (KMS)

Learn to create and use customer-managed encryption keys through the AWS Console. Covers key creation, permissions, and basic encrypt/decrypt operations.

**Key Topics**:
- Creating symmetric encryption keys
- Setting key administrative and usage permissions
- Testing encryption and decryption
- Key policy management

### 32.4 Create and Use Secret Console Terminal
**Duration**: 5 minutes  
**Tools**: AWS Console + AWS CLI  
**Focus**: AWS Secrets Manager

Demonstrates storing and retrieving database credentials using both console and command-line interfaces. Includes programmatic access patterns.

**Key Topics**:
- Storing database credentials securely
- Retrieving secrets via CLI
- Updating secret values
- Secret versioning and metadata

### 32.6 Create and Use TLS Certificate Console
**Duration**: 5 minutes  
**Tools**: AWS Console  
**Focus**: AWS Certificate Manager (ACM)

Shows how to request and manage TLS/SSL certificates for use with AWS services. Covers domain validation methods and service integration.

**Key Topics**:
- Requesting public SSL/TLS certificates
- DNS vs email validation
- Certificate integration with AWS services
- Certificate lifecycle management

## Prerequisites for All Demonstrations

### AWS Account Requirements
- Active AWS account with appropriate permissions
- IAM permissions for:
  - KMS: `kms:CreateKey`, `kms:Encrypt`, `kms:Decrypt`, `kms:ScheduleKeyDeletion`
  - Secrets Manager: `secretsmanager:CreateSecret`, `secretsmanager:GetSecretValue`, `secretsmanager:UpdateSecret`, `secretsmanager:DeleteSecret`
  - Certificate Manager: `acm:RequestCertificate`, `acm:ListCertificates`, `acm:DeleteCertificate`

### Technical Requirements
- AWS CLI installed and configured (for 32.4 demonstration)
- `jq` installed for JSON parsing (for 32.4 scripts)
- Access to AWS Management Console
- Basic understanding of encryption and certificate concepts

## Running the Demonstrations

### Individual Demonstration Structure
Each demonstration directory contains:
- `README.md` - Detailed step-by-step instructions
- Scripts (where applicable) - Automation for CLI operations
- `cleanup.sh` - Automated cleanup script

### Execution Order
1. Read the README.md in each demonstration directory
2. Follow the step-by-step instructions
3. Run provided scripts as indicated
4. Execute cleanup.sh after completion

### Cleanup Process
Each demonstration includes an automated cleanup script that:
- Removes all resources created during the demo
- Requires no user input
- Provides clear success/failure feedback
- Includes manual cleanup instructions as fallback

## Learning Objectives

After completing all demonstrations, participants will understand:

### Security Best Practices
- Centralized key management with AWS KMS
- Secure storage of sensitive data with Secrets Manager
- Automated certificate management with ACM
- Principle of least privilege for access control

### Integration Patterns
- How KMS integrates with other AWS services
- Programmatic access to secrets for applications
- Certificate usage with load balancers, CloudFront, and API Gateway
- Automation possibilities with AWS CLI and SDKs

### Operational Considerations
- Key rotation and lifecycle management
- Secret versioning and updates
- Certificate renewal and validation
- Monitoring and auditing capabilities

## Additional Resources

### AWS Documentation
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [AWS Well-Architected Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/)
- [AWS Cryptographic Services and Tools](https://docs.aws.amazon.com/crypto/)

### Training Materials
- [AWS Security Fundamentals](https://aws.amazon.com/training/course-descriptions/security-fundamentals/)
- [AWS Security Learning Path](https://aws.amazon.com/training/learning-paths/security/)

## Troubleshooting

### Common Issues
- **Permission Denied**: Verify IAM permissions for the specific service
- **Resource Not Found**: Check AWS region and resource names
- **CLI Command Failures**: Ensure AWS CLI is configured with valid credentials
- **Script Execution Issues**: Verify script permissions and dependencies

### Support Resources
- AWS Documentation links provided in each demonstration
- AWS Support Center for account-specific issues
- AWS Forums for community support

## Cost Considerations

### KMS
- Customer-managed keys: $1/month per key
- API requests: $0.03 per 10,000 requests

### Secrets Manager
- $0.40 per secret per month
- $0.05 per 10,000 API calls

### Certificate Manager
- Public certificates: Free when used with AWS services
- Private certificates: $400/month per private CA

**Note**: Cleanup scripts ensure minimal cost impact for demonstrations.
