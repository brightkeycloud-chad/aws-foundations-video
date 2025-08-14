# Inspector Demo - Vulnerable Resources Deployment Guide

## Quick Start (Day Before Demo)

### Option 1: Terraform (Recommended)
```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply -auto-approve
```

### Option 2: Shell Script
```bash
./deploy-vulnerable-resources.sh
```

## What Gets Created

| Resource Type | Count | Purpose |
|---------------|-------|---------|
| EC2 Instances | 2 | Amazon Linux 2 + Ubuntu with vulnerable packages |
| Lambda Function | 1 | Python 3.8 with outdated dependencies |
| ECR Repository | 1 | Container images with known vulnerabilities |
| Security Groups | 1 | Deliberately permissive (SSH from 0.0.0.0/0) |
| IAM Roles | 2 | Minimal permissions for EC2 and Lambda |

## Expected Costs (us-east-1)
- **EC2 Instances**: ~$0.0116/hour × 2 = ~$0.56/day
- **Lambda Function**: Minimal (pay per invocation)
- **ECR Repository**: $0.10/GB/month for storage
- **Total**: ~$0.60/day

## Timeline
- **Deploy**: Day before demo (allow 2-4 hours for scanning)
- **Demo**: 5 minutes
- **Cleanup**: Immediately after demo

## Verification Commands

### Check EC2 Instances
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Purpose,Values=Inspector Demo" \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

### Check Lambda Function
```bash
aws lambda get-function --function-name inspector-demo-vulnerable-function
```

### Check ECR Repository
```bash
aws ecr describe-repositories --repository-names inspector-demo-vulnerable
```

### Check Inspector Findings
```bash
aws inspector2 list-findings \
  --filter-criteria '{"resourceTags":[{"key":"Purpose","value":"Inspector Demo"}]}' \
  --query 'findings[].{Severity:severity,Title:title,Resource:resources[0].id}' \
  --output table
```

## Troubleshooting

### No Findings After 4 Hours
1. Verify Inspector is enabled:
   ```bash
   aws inspector2 get-account-status
   ```

2. Check instance status:
   ```bash
   aws ec2 describe-instance-status --include-all-instances
   ```

3. Verify SSM agent is running (required for Inspector):
   ```bash
   aws ssm describe-instance-information
   ```

### Deployment Failures
- **Terraform**: Check `terraform.log` for detailed errors
- **Script**: Check AWS CLI configuration and permissions
- **Common**: Ensure default VPC exists in your region

## Cleanup (Critical!)

### Terraform
```bash
cd terraform/
terraform destroy -auto-approve
# OR
./cleanup.sh
```

### Script
```bash
./cleanup-vulnerable-resources.sh
```

### Manual Verification
```bash
# Check for remaining resources
aws ec2 describe-instances --filters "Name=tag:Purpose,Values=Inspector Demo"
aws lambda list-functions --query 'Functions[?contains(FunctionName,`inspector-demo`)]'
aws ecr describe-repositories --query 'repositories[?contains(repositoryName,`inspector-demo`)]'
```

## Security Notes

⚠️ **CRITICAL**: These resources contain deliberate vulnerabilities:
- Outdated packages with known CVEs
- Permissive security groups (SSH from 0.0.0.0/0)
- Vulnerable application dependencies
- Insecure configurations

🔒 **MUST DO**:
- Deploy only in non-production accounts
- Clean up immediately after demo
- Never use these configurations in production
- Monitor costs during deployment

## File Structure
```
33.4_explore-inspector-findings-console/
├── README.md                           # Main demo instructions
├── DEPLOYMENT_GUIDE.md                 # This file
├── deploy-vulnerable-resources.sh      # Script deployment
├── cleanup-vulnerable-resources.sh     # Script cleanup
└── terraform/                          # Terraform deployment
    ├── main.tf                         # Main configuration
    ├── variables.tf                    # Input variables
    ├── outputs.tf                      # Output values
    ├── terraform.tfvars.example        # Example variables
    ├── user_data_al2.sh               # Amazon Linux 2 setup
    ├── user_data_ubuntu.sh            # Ubuntu setup
    ├── lambda_function.py              # Vulnerable Lambda code
    ├── requirements.txt                # Vulnerable Python packages
    ├── Dockerfile                      # Vulnerable container image
    └── cleanup.sh                      # Terraform cleanup
```

---
*Deploy responsibly. Clean up immediately. Demo safely.*
