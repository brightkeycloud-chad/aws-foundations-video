# Terraform Infrastructure for Auto Scaling Group Demo

## Overview
This Terraform configuration creates the supporting infrastructure needed for the Auto Scaling Group console demonstration. It sets up everything except the Auto Scaling Group itself, allowing the demonstration to focus on ASG creation and testing.

## File Structure
```
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── user-data.sh              # User data script for EC2 instances
├── terraform.tfvars.example  # Example variables file
├── .gitignore                # Git ignore patterns
├── README.md                 # Demonstration guide
└── TERRAFORM.md              # This infrastructure guide
```

## Architecture
```
Internet Gateway
    ↓
Application Load Balancer (ALB)
    ↓
Target Group (Health Checks: /health)
    ↓
[Auto Scaling Group - Created in Demo]
    ↓
Launch Template → EC2 Instances (Amazon Linux 2023)
                      ↓
                  user-data.sh (IMDSv2-compatible)
```

## Resources Created

### Core Infrastructure
- **Launch Template**: Pre-configured with Amazon Linux 2023 (x86_64)
- **Application Load Balancer**: Internet-facing ALB with HTTP listener
- **Target Group**: Configured for HTTP health checks on `/health` endpoint
- **Security Groups**: 
  - ALB Security Group (allows inbound HTTP from internet)
  - EC2 Security Group (allows inbound HTTP from ALB only)

### IAM Resources
- **IAM Role**: EC2 role with SSM Session Manager permissions
- **Instance Profile**: Attached to launch template for SSM access

### Web Application Features
- **Custom Web Server**: Displays instance metadata and scaling information
- **Health Check Endpoint**: JSON response at `/health` for ALB health checks
- **Load Testing Tool**: Pre-installed stress-ng for scaling demonstrations
- **Auto-refresh UI**: Web page refreshes every 30 seconds to show load balancing

## Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- Permissions to create EC2, IAM, and ELB resources

## Deployment

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Configure Variables (Optional)
Copy and customize the variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred settings
```

### 3. Plan Deployment
```bash
terraform plan
```

### 4. Deploy Infrastructure
```bash
terraform apply
```

### 5. Note Outputs
After deployment, Terraform will display important information including:
- Launch Template name for the demo
- ALB DNS name for testing
- Target Group ARN for ASG attachment

## Configuration Details

### Launch Template Configuration
- **AMI**: Latest Amazon Linux 2023 (x86_64)
- **Instance Type**: t3.micro (configurable via variables)
- **Security Group**: Allows HTTP from ALB only
- **IAM Role**: SSM Session Manager access
- **User Data**: Comprehensive web server setup with monitoring tools

### Application Load Balancer
- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Listener**: HTTP on port 80
- **Target Group**: HTTP health checks every 30 seconds

### Security Configuration
- **ALB Security Group**: 
  - Inbound: HTTP (80) from 0.0.0.0/0
  - Outbound: All traffic
- **EC2 Security Group**:
  - Inbound: HTTP (80) from ALB security group only
  - Outbound: All traffic

### Health Checks
- **Path**: `/health`
- **Protocol**: HTTP
- **Port**: 80
- **Healthy Threshold**: 2 consecutive successes
- **Unhealthy Threshold**: 2 consecutive failures
- **Timeout**: 5 seconds
- **Interval**: 30 seconds

## Variables

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `aws_region` | AWS region for resources | `us-east-1` | string |
| `instance_type` | EC2 instance type | `t3.micro` | string |
| `project_name` | Project name for tagging | `auto-scaling-group-demo` | string |

## Outputs

| Output | Description |
|--------|-------------|
| `launch_template_name` | Name of the launch template for ASG creation |
| `target_group_arn` | ARN of target group for ASG attachment |
| `alb_dns_name` | DNS name of ALB for testing |
| `demo_url` | Complete URL to access the demo application |
| `demonstration_instructions` | Step-by-step instructions for the demo |

## Testing the Infrastructure

### 1. Verify ALB is Accessible
```bash
# Test ALB endpoint (replace with actual DNS name from output)
curl http://[ALB-DNS-NAME]
```

### 2. Check Health Endpoint
```bash
# Test health check endpoint
curl http://[ALB-DNS-NAME]/health
```

### 3. Verify Launch Template
```bash
# List launch templates
aws ec2 describe-launch-templates --query 'LaunchTemplates[?LaunchTemplateName==`asg-demo-launch-template`]'
```

## Demonstration Flow
1. **Pre-Demo**: Deploy this Terraform infrastructure
2. **Demo**: Create Auto Scaling Group using AWS Console
3. **Testing**: Use ALB DNS name to test load balancing and scaling
4. **Cleanup**: Delete ASG via console, then run `terraform destroy`

## Load Testing
Each instance includes a load generation script for testing auto scaling:
```bash
# SSH into an instance and run:
/home/ec2-user/generate-load.sh
```

This generates CPU load for 5 minutes to trigger auto scaling policies.

## Cleanup
```bash
# Destroy all Terraform-managed resources
terraform destroy
```

**Important**: Delete the Auto Scaling Group via AWS Console before running `terraform destroy`, as Terraform doesn't manage the ASG.

## Troubleshooting

### Common Issues
1. **ALB not accessible**: Check security group rules and internet gateway
2. **Health checks failing**: Verify EC2 security group allows ALB access
3. **Launch template not found**: Ensure Terraform apply completed successfully
4. **Permission errors**: Verify AWS credentials have necessary permissions

### Useful Commands
```bash
# Check ALB status
aws elbv2 describe-load-balancers --names asg-demo-alb

# Check target group health
aws elbv2 describe-target-health --target-group-arn [TARGET-GROUP-ARN]

# View launch template details
aws ec2 describe-launch-templates --launch-template-names asg-demo-launch-template
```

## Cost Considerations
- ALB: ~$16-22/month (plus data processing charges)
- Target Group: No additional charge
- Launch Template: No charge
- EC2 instances: Only charged when ASG creates instances during demo

## Security Notes
- EC2 instances only accept HTTP traffic from ALB
- No SSH keys required (uses SSM Session Manager)
- All resources use least-privilege security groups
- IAM role follows AWS best practices for EC2 SSM access

---

*This infrastructure supports the Auto Scaling Group console demonstration*  
*Terraform version: >= 1.0*  
*AWS Provider version: ~> 5.0*
