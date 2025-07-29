# VPC Peering Quick Reference Guide

## Prerequisites Checklist
- [ ] Two VPCs with non-overlapping CIDR blocks
- [ ] EC2 instances in each VPC for testing
- [ ] Security groups allow ICMP traffic
- [ ] Appropriate IAM permissions

## Step-by-Step Commands

### 1. Create VPC Peering Connection
```
Console Path: VPC → Peering connections → Create peering connection
- Name: Demo-VPC-Peering
- VPC ID (Requester): [Select VPC A]
- Account: My account
- Region: This Region
- VPC ID (Accepter): [Select VPC B]
```

### 2. Accept Peering Connection
```
Console Path: VPC → Peering connections → [Select connection] → Actions → Accept request
```

### 3. Configure Route Tables
```
Console Path: VPC → Route Tables → [Select route table] → Routes → Edit routes

VPC A Route Table:
- Destination: [VPC B CIDR]
- Target: Peering Connection → [Select peering connection]

VPC B Route Table:
- Destination: [VPC A CIDR]  
- Target: Peering Connection → [Select peering connection]
```

### 4. Test Connectivity
```bash
# From EC2 instance in VPC A
ping [private-ip-of-instance-in-VPC-B]
```

## Common CIDR Examples
- VPC A: 10.0.0.0/16
- VPC B: 10.1.0.0/16
- VPC C: 172.16.0.0/16
- VPC D: 192.168.0.0/16

## Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| Peering creation fails | Check for CIDR overlap |
| No connectivity | Verify route tables in both VPCs |
| Ping fails | Check security groups for ICMP rules |
| DNS doesn't resolve | Enable DNS resolution for peering |

## Key Limitations
- Not transitive (A-B-C doesn't allow A-C communication)
- No overlapping CIDR blocks allowed
- Maximum 125 peering connections per VPC
- Cross-region peering has data transfer charges

## Cost Information
- Same region: No additional charges
- Cross-region: Standard data transfer rates apply
- No hourly charges for VPC peering connections

## Security Best Practices
- Use least privilege security group rules
- Consider NACLs for additional security
- Monitor VPC Flow Logs for traffic analysis
- Regularly audit peering connections
