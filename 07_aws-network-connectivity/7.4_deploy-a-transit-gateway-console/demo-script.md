# AWS Transit Gateway Deployment Demonstration Script

## Pre-Demo Setup Checklist
- [ ] Two VPCs created with non-overlapping CIDR blocks (e.g., 10.0.0.0/16 and 10.1.0.0/16)
- [ ] One EC2 instance launched in each VPC
- [ ] Security groups configured to allow ICMP (ping) traffic
- [ ] AWS Console open and ready
- [ ] Demo environment tested
- [ ] Architecture diagram prepared

## Timing Guide (5 minutes total)

### Opening (30 seconds)
**Script**: "Welcome to this demonstration on deploying AWS Transit Gateway using the console. Transit Gateway is a cloud router that simplifies network connectivity by providing a hub-and-spoke architecture. Instead of creating multiple VPC peering connections, Transit Gateway acts as a central hub that all your VPCs can connect to. This dramatically simplifies network management as you scale."

**Actions**:
- Show architecture diagram comparing VPC peering mesh vs Transit Gateway hub-and-spoke
- Navigate to VPC service in AWS Console

### Demo Section 1: Create Transit Gateway (1.5 minutes)

**Script**: "Let's start by creating our Transit Gateway. This will serve as the central hub for our network connectivity."

**Actions**:
1. Click "Transit Gateways" in left navigation
2. Click "Create transit gateway"
3. Enter name: "Demo-Transit-Gateway"
4. Enter description: "Demo Transit Gateway for VPC connectivity"
5. Keep default ASN (64512)
6. Ensure DNS support is enabled
7. Keep default route table association enabled
8. Keep default route table propagation enabled

**Script**: "I'm keeping the default settings which enable automatic route table association and propagation. This simplifies management by automatically handling routing for us."

**Actions**:
9. Click "Create transit gateway"
10. Show the "Pending" state

**Script**: "The Transit Gateway is now being created. This typically takes a few minutes. In a real scenario, we'd wait for it to become available, but for this demo, I'll show you the next steps."

### Demo Section 2: Attach VPCs to Transit Gateway (2 minutes)

**Script**: "Once our Transit Gateway is available, we need to attach our VPCs to it. Each attachment creates a connection point for the VPC."

**Actions**:
1. Navigate to "Transit Gateway Attachments"
2. Click "Create transit gateway attachment"
3. Enter name: "VPC-A-Attachment"
4. Select the Transit Gateway
5. Select "VPC" as attachment type
6. Enable DNS support
7. Select first VPC
8. Select subnet from the VPC

**Script**: "I'm selecting a subnet in each availability zone for redundancy. The Transit Gateway will use these subnets to route traffic."

**Actions**:
9. Click "Create transit gateway attachment"
10. Immediately start creating second attachment
11. Click "Create transit gateway attachment"
12. Enter name: "VPC-B-Attachment"
13. Select the Transit Gateway
14. Select "VPC" as attachment type
15. Enable DNS support
16. Select second VPC
17. Select subnet from the VPC
18. Click "Create transit gateway attachment"

**Script**: "Now we have both VPCs attached to our Transit Gateway. The attachments will show as 'Available' once they're ready."

### Demo Section 3: Configure VPC Route Tables (1 minute)

**Script**: "The final step is updating our VPC route tables to direct traffic through the Transit Gateway."

**Actions**:
1. Navigate to "Route Tables"
2. Select route table for first VPC
3. Click "Routes" tab
4. Click "Edit routes"
5. Click "Add route"
6. Enter destination CIDR of second VPC (10.1.0.0/16)
7. Select "Transit Gateway" as target
8. Select the Transit Gateway
9. Click "Save changes"

**Script**: "Now for the second VPC's route table."

**Actions**:
10. Select route table for second VPC
11. Click "Routes" tab
12. Click "Edit routes"
13. Click "Add route"
14. Enter destination CIDR of first VPC (10.0.0.0/16)
15. Select "Transit Gateway" as target
16. Select the Transit Gateway
17. Click "Save changes"

### Demo Section 4: Test Connectivity (30 seconds)

**Script**: "Let's verify our Transit Gateway is working by testing connectivity between our VPCs."

**Actions**:
1. Connect to EC2 instance in first VPC
2. Execute ping command to private IP of instance in second VPC
3. Show successful ping responses

**Script**: "Excellent! Traffic is flowing through our Transit Gateway successfully."

### Closing (30 seconds)

**Script**: "We've successfully deployed a Transit Gateway and connected two VPCs through it. The key advantages are scalability - as we add more VPCs, we just attach them to the Transit Gateway rather than creating multiple peering connections. We also get centralized routing management and the ability to connect on-premises networks through VPN or Direct Connect. This architecture scales much better than VPC peering for complex network topologies."

**Actions**:
- Show final architecture diagram
- Highlight the hub-and-spoke model

## Key Talking Points to Remember

1. **Scalability**: Transit Gateway scales better than VPC peering (mention the n(n-1)/2 peering problem)
2. **Centralized Management**: Single point of control for routing policies
3. **Cost Model**: Hourly charges plus data processing fees - cost-effective for 3+ VPCs
4. **Route Propagation**: Automatic route learning reduces manual configuration
5. **Multi-Account Support**: Can be shared across AWS accounts
6. **On-Premises Integration**: Supports VPN and Direct Connect attachments

## Advanced Features to Mention (if time permits)

- Custom route tables for traffic segmentation
- Cross-region peering for global connectivity
- Multicast support for specialized applications
- Integration with AWS Network Manager for monitoring

## Troubleshooting Tips During Demo

- If Transit Gateway creation is slow: Explain this is normal and show pre-created one
- If attachments fail: Check subnet selection and AZ requirements
- If ping fails: Verify security groups and route table configurations
- If routing doesn't work: Check Transit Gateway route tables

## Recovery Strategies

- Have a pre-created Transit Gateway ready as backup
- Keep screenshots of successful configurations
- Practice timing to ensure demo fits in 5 minutes
- Have fallback slides if live demo fails

## Comparison Points with VPC Peering

| Aspect | VPC Peering | Transit Gateway |
|--------|-------------|-----------------|
| Scalability | Limited (mesh complexity) | High (hub-and-spoke) |
| Management | Distributed | Centralized |
| Cost | Free (same region) | Hourly + data processing |
| On-premises | Not supported | Supported |
| Route propagation | Manual | Automatic |

## Post-Demo Cleanup

1. Delete routes from VPC route tables
2. Delete Transit Gateway attachments
3. Delete Transit Gateway
4. Optionally terminate test instances
5. Document lessons learned

## Demo Variations

- **Extended Version**: Show Transit Gateway route tables and custom routing
- **Multi-Region**: Demonstrate cross-region Transit Gateway peering
- **Hybrid**: Show VPN attachment for on-premises connectivity
- **Troubleshooting**: Intentionally create an issue and resolve it
