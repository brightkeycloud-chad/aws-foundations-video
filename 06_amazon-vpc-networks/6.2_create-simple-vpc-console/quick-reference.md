# Quick Reference: Create Simple VPC Console

## Essential Steps Checklist
- [ ] Navigate to VPC Console
- [ ] Click "Create VPC" → "VPC and more"
- [ ] Set IPv4 CIDR: `10.0.0.0/16`
- [ ] Configure: 2 AZs, 2 public subnets, 2 private subnets
- [ ] Enable: NAT gateways (1 per AZ), S3 Gateway endpoint
- [ ] Keep DNS options enabled
- [ ] Review preview and create

## Key Configuration Values
| Setting | Recommended Value | Notes |
|---------|------------------|-------|
| IPv4 CIDR | `10.0.0.0/16` | 65,536 IP addresses |
| Availability Zones | 2 | Minimum for production |
| Public Subnets | 2 | For load balancers, bastion hosts |
| Private Subnets | 2 | For app servers, databases |
| NAT Gateways | 1 per AZ | High availability |
| Tenancy | Default | Cost-effective |

## Auto-Generated Resources
✅ Internet Gateway  
✅ Public Route Tables (with 0.0.0.0/0 → IGW)  
✅ Private Route Tables (with 0.0.0.0/0 → NAT)  
✅ NAT Gateways (in public subnets)  
✅ S3 Gateway Endpoint (if selected)  

## Cost Breakdown
- **VPC**: Free
- **Internet Gateway**: Free
- **Route Tables**: Free
- **NAT Gateway**: ~$45/month each + data charges
- **S3 Gateway Endpoint**: Free

## Common CIDR Blocks
- Small: `10.0.0.0/24` (256 IPs)
- Medium: `10.0.0.0/20` (4,096 IPs)
- Large: `10.0.0.0/16` (65,536 IPs)
- Enterprise: `10.0.0.0/8` (16M IPs)

## Troubleshooting
| Issue | Solution |
|-------|----------|
| CIDR overlap error | Choose non-overlapping range |
| Creation fails | Check account limits |
| No internet access | Verify route tables and IGW |
| High costs | Review NAT gateway necessity |

## Next Steps After Creation
1. Launch EC2 instances in appropriate subnets
2. Configure Security Groups
3. Set up Network ACLs (if needed)
4. Create additional VPC endpoints
5. Configure VPC Flow Logs for monitoring
