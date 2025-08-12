# AWS Multiple Account Management Demonstrations

This directory contains four 5-minute demonstrations focused on AWS multiple account management capabilities. Each demonstration is designed to be delivered using the AWS Management Console and includes comprehensive documentation and cleanup procedures.

## Available Demonstrations

### 1. Organizations Configuration Management (Console)
**Directory**: `31.3_organizations-configuration-management-console`
**Duration**: 5 minutes
**Focus**: Setting up and managing AWS Organizations, creating OUs, and managing accounts

**Key Topics**:
- Organization hierarchy and structure
- Creating and managing Organizational Units (OUs)
- Account invitation and management
- Organization policies overview

### 2. Deploy Organizations Service Control Policies (Console)
**Directory**: `31.4_deploy-organizations-scp-console`
**Duration**: 5 minutes
**Focus**: Creating and deploying Service Control Policies to restrict actions across member accounts

**Key Topics**:
- Service Control Policy creation
- Policy attachment to OUs and accounts
- Policy inheritance and testing
- Guardrails implementation

### 3. IAM Identity Center (Console)
**Directory**: `31.6_iam-identity-center-console`
**Duration**: 5 minutes
**Focus**: Setting up centralized identity management across multiple AWS accounts

**Key Topics**:
- IAM Identity Center setup and configuration
- User and group management
- Permission sets creation
- Account access assignment

### 4. Implement AWS Backup (Console)
**Directory**: `31.9_implement-aws-backup-console`
**Duration**: 5 minutes
**Focus**: Setting up centralized backup across AWS resources and accounts

**Key Topics**:
- Backup vault creation
- Backup plan configuration
- Resource assignment and tagging
- Cross-account backup considerations

## General Prerequisites

All demonstrations require:
- AWS account with appropriate administrative permissions
- AWS Organizations enabled (for relevant demonstrations)
- Basic understanding of AWS services and concepts
- Access to AWS Management Console

## Using These Demonstrations

Each demonstration directory contains:
- **README.md**: Complete step-by-step instructions with timing
- **cleanup.sh**: Automated cleanup script to remove demo resources
- Additional scripts as needed for specific demonstrations

### Before Each Demonstration
1. Review the README.md file for prerequisites and setup requirements
2. Ensure you have the necessary permissions and access
3. Prepare any required test accounts or resources

### After Each Demonstration
1. Run the provided cleanup script: `./cleanup.sh`
2. Verify all demo resources have been removed
3. Check for any manual cleanup steps mentioned in the documentation

## Documentation Standards

All demonstrations follow consistent documentation standards:
- Clear step-by-step instructions with time allocations
- Current AWS documentation references with direct links
- Comprehensive cleanup procedures
- Key learning points summary
- Prerequisites and assumptions clearly stated

## Support and Troubleshooting

If you encounter issues during any demonstration:
1. Check the AWS service status page for any ongoing issues
2. Verify your account permissions and limits
3. Review the AWS documentation links provided in each README
4. Ensure cleanup scripts are run after each demonstration to avoid resource conflicts

## Cost Considerations

These demonstrations are designed to use minimal AWS resources and should incur little to no cost when properly cleaned up. However:
- Always run cleanup scripts after demonstrations
- Monitor your AWS billing dashboard
- Some services may have minimum charges or data transfer costs
- AWS Backup may create actual backups that incur storage costs if not cleaned up

## Updates and Maintenance

These demonstrations are based on current AWS documentation and console interfaces. AWS services evolve regularly, so:
- Verify current console layouts match the instructions
- Check for updated AWS documentation links
- Test demonstrations periodically to ensure accuracy
- Update instructions as needed for service changes
