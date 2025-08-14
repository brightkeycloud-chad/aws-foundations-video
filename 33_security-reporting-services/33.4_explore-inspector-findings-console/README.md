# AWS Inspector Findings Exploration Demo

## Overview
This 5-minute demonstration shows how to explore and analyze Amazon Inspector findings using the AWS Console. You'll learn to navigate the Inspector dashboard, filter findings, and understand vulnerability details using deliberately vulnerable resources.

## Prerequisites
- AWS account with appropriate permissions
- Amazon Inspector enabled in your region
- **Vulnerable resources deployed** (see deployment options below)
- Allow 2-4 hours after deployment for Inspector to generate findings

## Pre-Demo Setup (Deploy Day Before)

### Option 1: Terraform Deployment (Recommended)
```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferences
terraform init
terraform plan
terraform apply
```

### Option 2: Script-Based Deployment
```bash
./deploy-vulnerable-resources.sh
```

### What Gets Deployed
- **2 EC2 Instances**: Amazon Linux 2 and Ubuntu with vulnerable packages
- **1 Lambda Function**: Python function with outdated dependencies
- **1 ECR Repository**: Container images with known vulnerabilities
- **Security Groups**: Deliberately permissive configurations
- **IAM Roles**: Minimal required permissions

**⚠️ IMPORTANT**: Deploy these resources the day before your demo to allow Inspector time to scan and generate findings.

## Demo Steps (5 minutes)

### Step 1: Access Amazon Inspector (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **Amazon Inspector** service
3. Ensure you're in the correct region
4. Verify Inspector is enabled and scanning

### Step 2: Explore the Inspector Dashboard (1 minute)
1. Review the **Dashboard** overview:
   - **Coverage summary** showing scanned resources
   - **Critical findings** count from your vulnerable resources
   - **Vulnerability trends** over time
   - **Top vulnerable resources** (your deployed instances)
2. Note the different scan types:
   - **EC2 instance scanning** (your vulnerable instances)
   - **Container image scanning** (your ECR images)
   - **Lambda function scanning** (your vulnerable function)

### Step 3: Navigate to Findings (1 minute)
1. Click **Findings** in the left navigation pane
2. Review the findings table showing:
   - **Finding title** and CVE descriptions
   - **Severity** (Critical, High, Medium, Low)
   - **Resource** affected (your deployed resources)
   - **First observed** date
   - **Status** (Active findings from your vulnerable resources)

### Step 4: Filter and Analyze Findings (2 minutes)
1. Use the **Filter** options to narrow down findings:
   - Filter by **Severity**: Select "Critical" and "High"
   - Filter by **Resource type**: Choose "EC2 Instance"
   - Filter by **Finding status**: Select "Active"
2. Click on a specific finding to view detailed information:
   - **Vulnerability details** and CVE information
   - **Affected resource** details (your instances)
   - **Remediation guidance** for the vulnerable packages
   - **CVSS score** and vector
   - **References** to external vulnerability databases

### Step 5: Explore Finding Categories (1 minute)
1. Navigate to different finding views:
   - **By vulnerability**: Shows critical vulnerabilities from your resources
   - **By instance**: Shows your vulnerable EC2 instances
   - **By container image**: Shows your vulnerable ECR images
2. Click on a vulnerable resource to see:
   - All findings for that specific resource
   - Resource metadata and configuration
   - Remediation priorities

### Step 6: Export and Reporting (30 seconds)
1. Demonstrate the **Export** functionality:
   - Click **Export** button on the Findings page
   - Choose export format (CSV or JSON)
   - Show how findings can be used for compliance reporting
2. Mention integration with **AWS Security Hub** for centralized findings

## Key Learning Points
- Inspector automatically scans EC2 instances, container images, and Lambda functions
- Findings are categorized by severity with detailed CVE information
- Each finding includes specific remediation guidance
- Filtering helps prioritize the most critical vulnerabilities
- Inspector integrates with Security Hub for centralized security management
- Findings can be exported for reporting and compliance purposes
- Vulnerable packages are identified with specific version information

## Post-Demo Cleanup

### Terraform Cleanup
```bash
cd terraform/
./cleanup.sh
# OR
terraform destroy -auto-approve
```

### Script-Based Cleanup
```bash
./cleanup-vulnerable-resources.sh
```

**⚠️ IMPORTANT**: Clean up resources immediately after the demo to avoid unnecessary costs and security risks.

## Deployment Details

### Vulnerable Components Created
- **Amazon Linux 2 Instance**: Older AMI with vulnerable packages
  - Apache 2.4.54, OpenSSL 1.0.2k, Python 3.7.16
  - Vulnerable Python packages: requests 2.25.1, Pillow 8.3.2, Django 3.2.13
- **Ubuntu 20.04 Instance**: Older packages with known CVEs
  - Apache 2.4.41, OpenSSL 1.1.1f, PHP 7.4.3
  - Vulnerable Node.js packages: lodash 4.17.20, express 4.17.1
- **Lambda Function**: Python 3.8 runtime with vulnerable dependencies
  - requests 2.25.1, urllib3 1.26.5, Pillow 8.3.2
- **Container Images**: Ubuntu 20.04 base with vulnerable packages
  - Multiple language runtimes with outdated packages

### Expected Findings
After 2-4 hours, you should see:
- **50+ findings** across all resources
- **Critical and High severity** CVEs in system packages
- **Medium severity** findings in application dependencies
- **Low severity** configuration issues

## Troubleshooting

### No Findings Appearing
- Wait longer (up to 4 hours for initial scans)
- Verify Inspector is enabled: `aws inspector2 get-account-status`
- Check resource tags match deployment
- Ensure instances are running and accessible

### Insufficient Findings
- Redeploy with older AMI versions
- Install additional vulnerable packages
- Check Inspector coverage in the dashboard

### Cleanup Issues
- Use both cleanup scripts if needed
- Manually terminate resources via console if scripts fail
- Check for remaining resources with tags: `Purpose=Inspector Demo`

## Additional Resources and Citations

### AWS Documentation References
- [Viewing your Amazon Inspector findings](https://docs.aws.amazon.com/inspector/latest/user/findings-understanding-locating-analyzing.html)
- [What is Amazon Inspector?](https://docs.aws.amazon.com/inspector/latest/user/what-is-inspector.html)
- [Scanning Amazon ECR container images](https://docs.aws.amazon.com/inspector/latest/user/scanning-ecr.html)
- [Exporting Amazon Inspector findings reports](https://docs.aws.amazon.com/inspector/latest/user/findings-managing-exporting-reports.html)
- [Amazon Inspector Console](https://console.aws.amazon.com/inspector/v2/home)

### Understanding Severity Levels
- [Understanding Amazon Inspector finding severity](https://docs.aws.amazon.com/inspector/latest/user/findings-understanding-severity.html)
- [Managing Amazon Inspector findings with filtering](https://docs.aws.amazon.com/inspector/latest/user/findings-managing-filtering.html)

### Integration Resources
- [Amazon Inspector integrations](https://docs.aws.amazon.com/inspector/latest/user/integrations.html)
- [Automate security scans using Inspector and Security Hub](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/automate-security-scans-for-cross-account-workloads-using-amazon-inspector-and-aws-security-hub.html)

### Vulnerability Databases
- [Common Vulnerabilities and Exposures (CVE)](https://cve.mitre.org/)
- [National Vulnerability Database (NVD)](https://nvd.nist.gov/)
- [Common Vulnerability Scoring System (CVSS)](https://www.first.org/cvss/)

---
*Demo Duration: 5 minutes*  
*Setup Time: 2-4 hours for findings generation*  
*Last Updated: August 2025*
