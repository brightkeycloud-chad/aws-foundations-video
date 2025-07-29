# DNS Performance Demo - Terraform Infrastructure

This Terraform configuration creates the infrastructure needed for the DNS performance demonstration using Amazon Route 53. It deploys web servers in three AWS regions to demonstrate latency-based and geolocation routing capabilities.

## Architecture Overview

The infrastructure includes:
- **US East 2 Server**: EC2 instance in `us-east-2` (Ohio) - Blue theme
- **US West 2 Server**: EC2 instance in `us-west-2` (Oregon) - Orange theme  
- **EU Central 1 Server**: EC2 instance in `eu-central-1` (Frankfurt) - Purple theme
- **IAM Role & Instance Profile**: Created in `us-east-1` (global resources)
- **Security Groups**: Allow HTTP/HTTPS traffic in each region
- **Web Content**: Custom HTML pages identifying each server's region and purpose

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **AWS permissions** for:
   - EC2 (instances, security groups, VPCs) in multiple regions
   - IAM (roles, policies, instance profiles) in us-east-1
   - SSM (Session Manager) in all target regions

## Quick Start

### 1. Initialize Terraform
```bash
cd terraform
terraform init
```

### 2. Review the Plan
```bash
terraform plan
```

### 3. Deploy Infrastructure
```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 4. Get Output Information
```bash
terraform output
```

## Infrastructure Details

### Multi-Region Deployment
- **US East 2 (Ohio)**: Optimal for Eastern US and Canada
- **US West 2 (Oregon)**: Optimal for Western US and Pacific regions
- **EU Central 1 (Frankfurt)**: Optimal for Europe, Middle East, and Africa

### EC2 Instances
- **Instance Type**: `t4g.micro` (ARM64 architecture)
- **AMI**: Latest Amazon Linux 2023 (ARM64) in each region
- **Networking**: Default VPC, first available subnet in each region
- **Access**: SSM Session Manager (no SSH keys required)

### Web Server Configuration
Each instance runs Apache HTTP server with:
- **US East 2**: Blue-themed page indicating "US EAST 2 (OHIO) SERVER"
- **US West 2**: Orange-themed page indicating "US WEST 2 (OREGON) SERVER"
- **EU Central 1**: Purple-themed page indicating "EU CENTRAL 1 (FRANKFURT) SERVER"
- **Health Check Endpoint**: `/health` path for Route 53 monitoring
- **Performance Information**: Each page explains the routing optimization

### Security Groups
- **Inbound**: HTTP (80), HTTPS (443) from anywhere
- **Outbound**: All traffic allowed
- **Separate security groups** for each region

### IAM Configuration
- **Role**: `EC2-SSM-Role-Performance-Demo` with SSM managed instance core policy
- **Instance Profile**: `EC2-SSM-Profile-Performance-Demo` attached to all instances
- **Created in**: `us-east-1` (IAM resources are global but created in us-east-1 by convention)
- **Used by**: All EC2 instances across all regions

## Using the Infrastructure

### 1. Test All Web Servers
After deployment, test all servers using the output URLs:
```bash
# Get all URLs
terraform output web_server_urls

# Test each server
curl $(terraform output -json web_server_urls | jq -r '.us_east_2')
curl $(terraform output -json web_server_urls | jq -r '.us_west_2')
curl $(terraform output -json web_server_urls | jq -r '.eu_central_1')
```

### 2. Test Health Check Endpoints
```bash
terraform output health_check_urls

# Test health endpoints
curl $(terraform output -json health_check_urls | jq -r '.us_east_2')
curl $(terraform output -json health_check_urls | jq -r '.us_west_2')
curl $(terraform output -json health_check_urls | jq -r '.eu_central_1')
```

### 3. Connect via SSM Session Manager
```bash
# Connect to US East 2 server
aws ssm start-session --target $(terraform output -json ssm_connection_info | jq -r '.us_east_2_instance_id') --region us-east-2

# Connect to US West 2 server
aws ssm start-session --target $(terraform output -json ssm_connection_info | jq -r '.us_west_2_instance_id') --region us-west-2

# Connect to EU Central 1 server
aws ssm start-session --target $(terraform output -json ssm_connection_info | jq -r '.eu_central_1_instance_id') --region eu-central-1
```

### 4. Get IP Addresses for Route 53
Use these IP addresses when configuring Route 53 routing policies:
```bash
# For latency-based routing
terraform output route53_latency_routing_ips

# For geolocation routing
terraform output route53_geolocation_routing_ips
```

## Route 53 Configuration

After the infrastructure is deployed, use the IP addresses from the output to configure Route 53:

### Latency-Based Routing
1. **US East 2 Record**: Use `us_east_2` IP with region `us-east-2`
2. **US West 2 Record**: Use `us_west_2` IP with region `us-west-2`
3. **EU Central 1 Record**: Use `eu_central_1` IP with region `eu-central-1`

### Geolocation Routing
1. **North America Record**: Use `us_east_2` IP with location "North America"
2. **Europe Record**: Use `eu_central_1` IP with location "Europe"
3. **Default Record**: Use `us_west_2` IP with location "Default"

Follow the main [README.md](../README.md) for detailed Route 53 configuration steps.

## Performance Testing

### Response Time Testing
Create a curl format file for response time testing:
```bash
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF
```

Then test response times:
```bash
# Test each server's response time
curl -w "@curl-format.txt" -o /dev/null -s http://[SERVER_IP]
```

### Geographic Testing
Use online tools or VPN services to test from different geographic locations:
- **From US East Coast**: Should route to US East 2
- **From US West Coast**: Should route to US West 2  
- **From Europe**: Should route to EU Central 1

## Customization

### Variables
You can customize the deployment by modifying variables:

```bash
# Custom instance type
terraform apply -var="instance_type=t4g.small"

# Custom regions (requires code changes for additional regions)
terraform apply -var='regions={"us_east_1"="us-east-1","us_east_2"="us-east-2","us_west_2"="us-west-1","eu_central_1"="eu-west-1"}'

# Custom TTL for DNS records
terraform apply -var="ttl_seconds=60"
```

### Variable File
Create a `terraform.tfvars` file for persistent customization:
```hcl
regions = {
  us_east_1    = "us-east-1"  # For IAM resources
  us_east_2    = "us-east-2"  # For EC2 instances
  us_west_2    = "us-west-1"  # Changed to us-west-1
  eu_central_1 = "eu-west-1"  # Changed to eu-west-1
}

instance_type = "t4g.small"
ttl_seconds   = 60

common_tags = {
  Environment = "Production"
  Owner       = "TeamName"
  CostCenter  = "12345"
}
```

## Monitoring and Troubleshooting

### Check Instance Status
```bash
# US East 2 instance
aws ec2 describe-instances --instance-ids $(terraform output -json us_east_2_server_info | jq -r '.instance_id') --region us-east-2

# US West 2 instance
aws ec2 describe-instances --instance-ids $(terraform output -json us_west_2_server_info | jq -r '.instance_id') --region us-west-2

# EU Central 1 instance
aws ec2 describe-instances --instance-ids $(terraform output -json eu_central_1_server_info | jq -r '.instance_id') --region eu-central-1
```

### View Instance Logs
Connect via SSM and check Apache logs:
```bash
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log
```

### Test Connectivity from Different Locations
```bash
# Use online tools or different VPN endpoints
curl -I http://[SERVER_IP]

# Check DNS resolution from different locations
dig @8.8.8.8 yourdomain.com
nslookup yourdomain.com 8.8.8.8
```

## Cost Considerations

This infrastructure uses:
- 3x `t4g.micro` instances (eligible for free tier)
- Standard EBS storage in 3 regions
- Data transfer charges apply (especially cross-region)
- SSM Session Manager (no additional cost)

Estimated monthly cost: ~$0-60 depending on usage and free tier eligibility.

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## Troubleshooting

### Common Issues

1. **Instances not accessible**
   - Check security group rules in each region
   - Verify instances are in running state
   - Ensure SSM agent is running

2. **Web server not responding**
   - Wait 2-3 minutes for user data script to complete
   - Check instance system logs in each region
   - Verify Apache service status via SSM

3. **SSM connection fails**
   - Ensure IAM role is properly attached
   - Check VPC endpoints for SSM (if using private subnets)
   - Verify AWS CLI configuration and region

4. **Health checks failing**
   - Confirm security groups allow traffic on port 80
   - Test health check endpoints manually
   - Check Route 53 health checker IP ranges

5. **Cross-region deployment issues**
   - Verify AWS credentials have permissions in all regions
   - Check region availability for t4g.micro instances
   - Ensure default VPCs exist in all target regions

### Getting Help

1. Check Terraform state: `terraform show`
2. View detailed outputs: `terraform output -json`
3. Check AWS CloudTrail for API calls in each region
4. Review instance system logs in EC2 console for each region

## Security Notes

- Instances use SSM Session Manager (no SSH keys)
- Security groups restrict access to HTTP/HTTPS only
- IAM roles follow least privilege principle
- No hardcoded credentials in configuration
- Separate security groups per region for isolation

## Performance Optimization Tips

1. **Use CloudFront** for additional performance improvements
2. **Enable compression** in Apache configuration
3. **Monitor CloudWatch metrics** for each region
4. **Use Application Load Balancers** for production workloads
5. **Implement caching strategies** for dynamic content

## Next Steps

1. Deploy this infrastructure
2. Test all three web servers
3. Measure response times from different locations
4. Follow the main demonstration guide for Route 53 configuration
5. Practice with different routing policies
6. Test failover scenarios by stopping instances
7. Clean up resources when done

---

This infrastructure provides a comprehensive foundation for demonstrating DNS performance optimization concepts with Amazon Route 53 across multiple geographic regions.
