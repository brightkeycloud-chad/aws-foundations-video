# Bash Script Automation Terminal Demonstration

## Overview
This 5-minute demonstration showcases how to create powerful bash scripts that automate AWS security monitoring and resource management tasks. Participants will learn to build reusable scripts for AWS operations including resource monitoring and security findings analysis.

## Prerequisites
- AWS CLI v2 installed and configured
- Bash shell environment (Linux/macOS/WSL)
- AWS account with appropriate permissions
- Basic understanding of bash scripting
- Valid AWS credentials configured
- AWS Security Hub enabled (for security findings script)

## Demonstration Files
This demonstration includes the following executable scripts:
- `aws-resource-monitor.sh` - Resource monitoring and reporting utility
- `security-hub-findings.sh` - Security Hub critical findings analyzer with table display

## Demonstration Script (5 minutes)

### Part 1: Resource Monitoring Script (1.5 minutes)

The monitoring script (`aws-resource-monitor.sh`) provides:
- **Real-time resource counting** across multiple AWS services
- **Formatted output** with timestamps
- **Quick resource overview** for operational awareness

```bash
# Run the monitoring script
./aws-resource-monitor.sh
```

This script displays:
- Total S3 buckets in the account
- Running EC2 instances count
- IAM users count
- Timestamp for the report

### Part 2: Security Hub Critical Findings Analysis (2.5 minutes)

The Security Hub script (`security-hub-findings.sh`) demonstrates:
- **Security findings retrieval** from AWS Security Hub
- **Formatted table display** of critical security issues
- **Configurable parameters** for different severity levels and regions
- **Comprehensive error handling** for Security Hub prerequisites
- **Summary statistics** across all severity levels

```bash
# Show script help and options
./security-hub-findings.sh --help

# Get critical findings (default behavior)
./security-hub-findings.sh

# Get findings from different region with custom parameters
./security-hub-findings.sh --region us-west-2 --severity HIGH --number 5

# Get medium severity findings
./security-hub-findings.sh --severity MEDIUM --number 15
```

Key features demonstrated:
1. **Prerequisites checking** - Verifies AWS credentials and Security Hub status
2. **Flexible filtering** - Supports different severity levels (CRITICAL, HIGH, MEDIUM, LOW)
3. **Formatted output** - Displays findings in a clean, readable table format
4. **Error handling** - Provides helpful guidance when Security Hub is not enabled
5. **Summary statistics** - Shows counts across all severity levels
6. **Command-line flexibility** - Configurable region, severity, and result count

### Part 3: Execute Complete Demonstration (1 minute)

```bash
# Run initial resource monitoring
echo "=== Current AWS Resources ==="
./aws-resource-monitor.sh

echo
echo "=== Security Hub Critical Findings ==="
# Run Security Hub analysis
./security-hub-findings.sh

echo
echo "=== High Severity Findings (Alternative View) ==="
./security-hub-findings.sh --severity HIGH --number 5
```

## Key Learning Points
1. **Script Structure**: Proper bash script organization with functions and modular design
2. **AWS Service Integration**: Working with Security Hub and resource monitoring APIs
3. **Error Handling**: Comprehensive error checking and user-friendly error messages
4. **Output Formatting**: Creating readable tables and formatted output
5. **Command-line Interface**: Implementing flexible argument parsing and help systems
6. **Security Monitoring**: Automated security posture assessment and reporting
7. **Prerequisites Validation**: Checking service availability and permissions

## Script Features Demonstrated
- **Colorized output** for improved readability and severity indication
- **Table formatting** with proper column alignment and headers
- **Command-line argument parsing** with validation and help system
- **AWS service status checking** (Security Hub enablement)
- **Flexible filtering** by severity, region, and result count
- **Error handling** with informative messages and troubleshooting guidance
- **JSON processing** using jq for complex data manipulation
- **Summary statistics** for operational overview

## Security Hub Integration
The Security Hub script demonstrates:
- **Service prerequisite checking** - Validates Security Hub is enabled
- **Finding retrieval** with complex filters for severity and status
- **Data processing** - Parsing and formatting JSON responses
- **Table display** - Converting API responses to readable tables
- **Operational guidance** - Providing next steps and additional commands

## Best Practices Shown
- Always verify AWS service availability before operations
- Implement comprehensive help systems for user guidance
- Use meaningful error messages with actionable solutions
- Validate input parameters and provide clear feedback
- Format output for human readability
- Include summary information for operational context
- Provide examples and additional command references

## Usage Instructions

### Running the Demonstration
1. Ensure all prerequisites are met (including Security Hub enabled)
2. Navigate to the demonstration directory
3. Run the scripts in the suggested order:
   ```bash
   # Resource overview
   ./aws-resource-monitor.sh
   
   # Security findings analysis
   ./security-hub-findings.sh
   
   # Alternative severity levels
   ./security-hub-findings.sh --severity HIGH --number 5
   ```

### Security Hub Prerequisites
If Security Hub is not enabled, the script will provide guidance:
```bash
# Enable Security Hub (if needed)
aws securityhub enable-security-hub --region us-east-1

# Enable security standards (recommended)
aws securityhub batch-enable-standards --standards-subscription-requests StandardsArn=arn:aws:securityhub:::ruleset/finding-format/aws-foundational-security-standard/v/1.0.0
```

### Script Customization
- Modify the default `REGION` variable to use your preferred AWS region
- Adjust `MAX_RESULTS` for different result set sizes
- Customize table formatting and column widths as needed
- Add additional severity levels or filtering criteria

## Troubleshooting Tips
- Ensure AWS credentials have Security Hub read permissions
- Verify Security Hub is enabled in the target region
- Check that security standards are enabled to generate findings
- Use `--verbose` mode in AWS CLI commands for detailed debugging
- Review IAM permissions if API calls fail

## Additional Resources and Citations

### AWS Documentation References
1. **AWS Security Hub User Guide**: https://docs.aws.amazon.com/securityhub/latest/userguide/
2. **Security Hub API Reference**: https://docs.aws.amazon.com/securityhub/1.0/APIReference/
3. **AWS CLI Security Hub Commands**: https://docs.aws.amazon.com/cli/latest/reference/securityhub/
4. **AWS CLI Getting Started Guide**: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
5. **AWS CLI Output Formatting**: https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output-format.html

### Security Best Practices
6. **AWS Security Best Practices**: https://docs.aws.amazon.com/security/
7. **Security Hub Best Practices**: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-best-practices.html
8. **AWS Foundational Security Standard**: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp.html

### Bash Scripting Resources
9. **Bash Scripting Guide**: https://tldp.org/LDP/Bash-Beginners-Guide/html/
10. **Advanced Bash Scripting**: https://tldp.org/LDP/abs/html/
11. **JSON Processing with jq**: https://stedolan.github.io/jq/manual/

### AWS Security Hub Integration
12. **Security Hub Findings Format**: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings-format.html
13. **Security Hub Standards**: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards.html

---
*This demonstration shows how to create production-ready bash scripts for AWS security monitoring and resource management. Always ensure proper IAM permissions and test scripts in development environments before production use.*
