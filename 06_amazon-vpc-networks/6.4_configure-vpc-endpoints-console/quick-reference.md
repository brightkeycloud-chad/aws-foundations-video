# Quick Reference: Configure VPC Endpoints Console

## Essential Steps Checklist

### Gateway Endpoint (S3/DynamoDB)
- [ ] VPC Console → Endpoints → Create endpoint
- [ ] Select AWS services → S3 service
- [ ] Choose target VPC
- [ ] Select route tables (usually private)
- [ ] Set policy (Full access for demo)
- [ ] Create endpoint

### Interface Endpoint (Most AWS Services)
- [ ] VPC Console → Endpoints → Create endpoint  
- [ ] Select AWS services → Choose service (e.g., EC2)
- [ ] Choose target VPC
- [ ] Select subnets (private, multi-AZ)
- [ ] Configure security group (allow HTTPS/443)
- [ ] Keep DNS name enabled
- [ ] Create endpoint

## Endpoint Types Comparison
| Feature | Gateway | Interface |
|---------|---------|-----------|
| **Cost** | Free | ~$7.20/month + data |
| **Services** | S3, DynamoDB only | Most AWS services |
| **Implementation** | Route table entries | Network interfaces |
| **DNS** | Not applicable | Private DNS names |
| **Security Groups** | Not applicable | Required |

## Supported Services
### Gateway Endpoints (Free)
- Amazon S3
- Amazon DynamoDB

### Interface Endpoints (Paid)
- EC2, Lambda, SNS, SQS
- RDS, CloudWatch, KMS
- Systems Manager, Secrets Manager
- And 100+ other AWS services

## Security Group Rules for Interface Endpoints
```
Type: HTTPS
Protocol: TCP
Port: 443
Source: VPC CIDR (e.g., 10.0.0.0/16)
```

## Cost Optimization Tips
- Use Gateway endpoints for S3/DynamoDB (free)
- Compare Interface endpoint costs vs NAT gateway data charges
- Deploy Interface endpoints only in subnets that need them
- Use endpoint policies to restrict access

## Testing Commands
```bash
# Test S3 Gateway endpoint
aws s3 ls

# Test EC2 Interface endpoint  
aws ec2 describe-instances

# Check endpoint DNS resolution
nslookup ec2.region.amazonaws.com
```

## Common Configuration Patterns
### Web Application Tier
- S3 Gateway endpoint (static content)
- EC2 Interface endpoint (instance management)
- RDS Interface endpoint (database connectivity)

### Data Processing
- S3 Gateway endpoint (data storage)
- Lambda Interface endpoint (serverless functions)
- SQS Interface endpoint (message queuing)

## Troubleshooting
| Issue | Solution |
|-------|----------|
| DNS resolution fails | Enable VPC DNS hostnames/resolution |
| Connection timeout | Check security group rules (port 443) |
| Access denied | Review endpoint policies |
| High costs | Evaluate usage vs NAT gateway costs |

## Monitoring and Logging
- Enable VPC Flow Logs to monitor endpoint traffic
- Use CloudWatch metrics for endpoint usage
- Monitor data processing charges
- Set up billing alerts for cost control

## Best Practices
✅ Deploy Interface endpoints in multiple AZs  
✅ Use specific security groups for endpoints  
✅ Enable private DNS for seamless integration  
✅ Apply least-privilege endpoint policies  
✅ Monitor usage and costs regularly  
✅ Document endpoint purposes and dependencies  
