# AWS Transit Gateway Quick Reference Guide

## Prerequisites Checklist
- [ ] Two or more VPCs with non-overlapping CIDR blocks
- [ ] EC2 instances in each VPC for testing
- [ ] Security groups allow required traffic
- [ ] Appropriate IAM permissions
- [ ] Subnets in multiple AZs for redundancy

## Step-by-Step Commands

### 1. Create Transit Gateway
```
Console Path: VPC → Transit Gateways → Create transit gateway
- Name tag: Demo-Transit-Gateway
- Description: Demo Transit Gateway for VPC connectivity
- Amazon side ASN: 64512 (default)
- DNS support: Enabled
- Default route table association: Enabled
- Default route table propagation: Enabled
```

### 2. Create VPC Attachments
```
Console Path: VPC → Transit Gateway Attachments → Create transit gateway attachment

For each VPC:
- Name tag: VPC-[A/B]-Attachment
- Transit gateway ID: [Select your TGW]
- Attachment type: VPC
- DNS support: Enabled
- VPC ID: [Select VPC]
- Subnet IDs: [Select subnets in different AZs]
```

### 3. Configure VPC Route Tables
```
Console Path: VPC → Route Tables → [Select route table] → Routes → Edit routes

For each VPC route table:
- Destination: [Other VPC CIDR blocks]
- Target: Transit Gateway → [Select your TGW]
```

### 4. Test Connectivity
```bash
# From EC2 instance in VPC A
ping [private-ip-of-instance-in-VPC-B]
```

## Transit Gateway States
- **Pending**: Being created
- **Available**: Ready for attachments
- **Modifying**: Configuration being updated
- **Deleting**: Being deleted
- **Deleted**: Removed from account

## Attachment States
- **Initiating**: Being created
- **PendingAcceptance**: Waiting for acceptance (cross-account)
- **RollingBack**: Creation failed, rolling back
- **Pending**: Being processed
- **Available**: Ready for traffic
- **Modifying**: Being updated
- **Deleting**: Being removed
- **Deleted**: Removed

## Cost Structure
- **Hourly charge**: ~$36/month per Transit Gateway
- **Data processing**: $0.02 per GB processed
- **Cross-AZ traffic**: Standard rates apply
- **Break-even**: ~3 VPCs vs VPC peering

## Route Table Types
- **Default Route Table**: Automatically created
- **Custom Route Tables**: For traffic segmentation
- **Propagation**: Automatic route learning
- **Association**: Links attachments to route tables

## Common Configuration Patterns

### Full Mesh (Default)
```
All VPCs can communicate with each other
Uses default route table with propagation enabled
```

### Hub and Spoke
```
Central VPC (hub) communicates with all others
Spoke VPCs cannot communicate with each other
Requires custom route tables
```

### Segmented Networks
```
Different route tables for different environments
Example: Prod, Dev, Test isolation
```

## Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| TGW creation slow | Normal - can take 10+ minutes |
| Attachment fails | Check subnet selection and AZs |
| No connectivity | Verify VPC route tables point to TGW |
| Partial connectivity | Check security groups and NACLs |
| Route conflicts | Review TGW route table entries |

## Security Best Practices
- Use custom route tables for traffic segmentation
- Implement least privilege security group rules
- Monitor with VPC Flow Logs
- Use AWS Network Manager for visibility
- Regular audit of route tables and attachments

## Scaling Considerations
- Maximum 5,000 attachments per Transit Gateway
- Maximum 10,000 routes per route table
- Cross-region peering for global connectivity
- Multiple Transit Gateways for very large deployments

## Integration Options
- **VPN**: Connect on-premises networks
- **Direct Connect**: Dedicated network connection
- **Peering**: Connect to other Transit Gateways
- **Connect (GRE)**: Third-party network appliances

## Monitoring and Logging
- CloudWatch metrics for Transit Gateway
- VPC Flow Logs for traffic analysis
- AWS Network Manager for topology visualization
- CloudTrail for API call logging
