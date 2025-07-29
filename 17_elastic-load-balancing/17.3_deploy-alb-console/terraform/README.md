# Application Load Balancer Demo - Terraform Infrastructure

This Terraform configuration creates the EC2 instances needed for the Application Load Balancer demonstration. It deploys two web servers in different Availability Zones in us-west-2, each with a unique webpage that identifies which server is being accessed.

## Architecture

The infrastructure includes:
- **2 EC2 instances** (t3.micro) in different AZs in us-west-2
- **Security Group** allowing HTTP (80) and HTTPS (443) access
- **IAM Role and Instance Profile** for SSM Session Manager access
- **Apache web servers** with custom pages identifying each server
- **Health check endpoints** at `/health`

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- Appropriate AWS permissions to create EC2, IAM, and VPC resources

## Quick Start

1. **Clone and Navigate**
   ```bash
   cd /path/to/17.3_deploy-alb-console/terraform
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review and Customize Variables (Optional)**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars as needed
   ```

4. **Plan the Deployment**
   ```bash
   terraform plan
   ```

5. **Deploy the Infrastructure**
   ```bash
   terraform apply
   ```

6. **Note the Outputs**
   After deployment, Terraform will display important information including:
   - Instance IDs and IP addresses
   - Direct URLs to test each web server
   - Health check endpoints
   - Target group configuration details

## Testing the Web Servers

After deployment (wait 2-3 minutes for full initialization):

### Test Web Server A
```bash
curl http://WEB-SERVER-A-PUBLIC-IP
# Should show "WEB SERVER A - ACTIVE" with blue styling
```

### Test Web Server B
```bash
curl http://WEB-SERVER-B-PUBLIC-IP
# Should show "WEB SERVER B - ACTIVE" with purple styling
```

### Test Health Endpoints
```bash
curl http://WEB-SERVER-A-PUBLIC-IP/health
curl http://WEB-SERVER-B-PUBLIC-IP/health
```

## Using with ALB Demo

These instances are designed to be used as targets for the Application Load Balancer demonstration:

1. **Deploy this infrastructure first**
2. **Note the instance IDs and private IPs from the output**
3. **Follow the main README.md instructions** to create the ALB
4. **Use these instances when registering targets** in the target group

## Web Server Identification

Each web server displays a unique page:

- **Web Server A**: Blue theme, displays "WEB-SERVER-A" 
- **Web Server B**: Purple theme, displays "WEB-SERVER-B"

Both pages show:
- Server identifier
- Instance ID and private IP
- Availability Zone
- Timestamp
- Load balancer demonstration information

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-west-2` | AWS region for deployment |
| `instance_type` | `t3.micro` | EC2 instance type |
| `architecture` | `x86_64` | CPU architecture |
| `web_server_port` | `80` | HTTP port for web servers |
| `health_check_path` | `/health` | Health check endpoint path |
| `allowed_cidr_blocks` | `["0.0.0.0/0"]` | CIDR blocks for HTTP access |

## Security Features

- **SSM Session Manager**: No SSH keys required for access
- **Security Groups**: Restricted to HTTP/HTTPS traffic
- **IAM Roles**: Minimal permissions for SSM access
- **Public Subnets**: Required for internet-facing ALB

## Monitoring and Troubleshooting

### Check Instance Status
```bash
# Using AWS CLI
aws ec2 describe-instances --region us-west-2 --filters "Name=tag:Purpose,Values=ALB-Demo"

# Using SSM Session Manager
aws ssm start-session --target INSTANCE-ID --region us-west-2
```

### Common Issues

1. **Web servers not responding**: Wait 2-3 minutes for user data script completion
2. **Health checks failing**: Verify security group allows port 80
3. **SSM access issues**: Ensure IAM role has proper permissions

### CloudWatch Logs
User data script logs are available in CloudWatch Logs:
- Log Group: `/aws/ec2/user-data`
- Log Stream: Instance ID

## Cleanup

To remove all resources:

```bash
terraform destroy
```

This will delete:
- EC2 instances
- Security groups
- IAM roles and instance profiles

## Cost Considerations

- **t3.micro instances**: ~$0.0104/hour each (2 instances)
- **EBS storage**: ~$0.10/GB/month (8GB each)
- **Data transfer**: Minimal for demo purposes

**Estimated monthly cost**: ~$15-20 if left running continuously

## Integration with ALB Demo

This infrastructure is specifically designed for the ALB console demonstration:

1. **Target Registration**: Use the instance IDs from outputs
2. **Health Checks**: ALB will monitor the `/health` endpoints
3. **Load Distribution**: Different colored pages help visualize load balancing
4. **Multi-AZ**: Instances in different AZs demonstrate high availability

## Additional Resources

- [AWS Application Load Balancer Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EC2 User Data Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)

---
*This infrastructure supports the 17.3 Deploy ALB Console demonstration*
