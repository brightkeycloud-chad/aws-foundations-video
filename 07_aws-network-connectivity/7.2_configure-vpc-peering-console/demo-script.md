# VPC Peering Demonstration Script

## Pre-Demo Setup Checklist
- [ ] Two VPCs created with non-overlapping CIDR blocks (e.g., 10.0.0.0/16 and 10.1.0.0/16)
- [ ] One EC2 instance launched in each VPC
- [ ] Security groups configured to allow ICMP (ping) traffic
- [ ] AWS Console open and ready
- [ ] Demo environment tested

## Timing Guide (5 minutes total)

### Opening (30 seconds)
**Script**: "Welcome to this demonstration on configuring VPC peering using the AWS Console. VPC peering creates a private network connection between two VPCs, allowing resources to communicate as if they're in the same network. This is particularly useful for connecting development and production environments, or sharing resources across different VPCs."

**Actions**:
- Show AWS Console homepage
- Navigate to VPC service

### Demo Section 1: Create VPC Peering Connection (2 minutes)

**Script**: "Let's start by creating the peering connection. I'll navigate to the Peering connections section and create a new connection between our two VPCs."

**Actions**:
1. Click "Peering connections" in left navigation
2. Click "Create peering connection"
3. Enter name: "Demo-VPC-Peering"
4. Select first VPC as requester
5. Select second VPC as accepter
6. Click "Create peering connection"

**Script**: "Notice the connection is in 'Pending Acceptance' state. Even though both VPCs are in the same account, we still need to accept the connection."

**Actions**:
7. Select the peering connection
8. Click "Actions" → "Accept request"
9. Click "Accept request" to confirm

**Script**: "Great! The connection is now active. But we're not done yet - we need to configure routing."

### Demo Section 2: Configure Route Tables (2 minutes)

**Script**: "Now we need to update the route tables in both VPCs to direct traffic through our peering connection. This is a critical step that's often overlooked."

**Actions**:
1. Navigate to "Route Tables"
2. Select route table for first VPC
3. Click "Routes" tab
4. Click "Edit routes"
5. Click "Add route"
6. Enter destination CIDR of second VPC (10.1.0.0/16)
7. Select "Peering Connection" as target
8. Select the peering connection
9. Click "Save changes"

**Script**: "Now I'll do the same for the second VPC's route table."

**Actions**:
10. Select route table for second VPC
11. Click "Routes" tab
12. Click "Edit routes"
13. Click "Add route"
14. Enter destination CIDR of first VPC (10.0.0.0/16)
15. Select "Peering Connection" as target
16. Select the peering connection
17. Click "Save changes"

### Demo Section 3: Test Connectivity (30 seconds)

**Script**: "Let's test our connection by pinging between instances in the two VPCs."

**Actions**:
1. Connect to EC2 instance in first VPC (show connection method briefly)
2. Execute ping command to private IP of instance in second VPC
3. Show successful ping responses

**Script**: "Perfect! The ping is successful, confirming our VPC peering connection is working correctly."

### Closing (30 seconds)

**Script**: "We've successfully created a VPC peering connection and configured the necessary routing. Key takeaways: VPC peering requires non-overlapping CIDR blocks, both VPCs need route table updates, and don't forget to configure security groups appropriately. This setup enables secure, private communication between VPCs without internet gateway dependencies."

**Actions**:
- Show final architecture diagram or summary slide

## Key Talking Points to Remember

1. **CIDR Block Importance**: Emphasize that overlapping CIDR blocks will cause the peering to fail immediately
2. **Bidirectional Configuration**: Both VPCs need route table updates - it's not automatic
3. **Security Groups**: Mention that security groups still apply and need appropriate rules
4. **Cost**: Same-region VPC peering has no additional charges
5. **Limitations**: VPC peering is not transitive - if A peers with B and B peers with C, A cannot reach C through B

## Troubleshooting Tips During Demo

- If peering creation fails: Check for CIDR overlap
- If ping fails: Verify security groups allow ICMP
- If routing doesn't work: Double-check route table associations
- If DNS doesn't resolve: Mention DNS resolution settings for peering

## Recovery Strategies

- Have backup VPCs ready in case of issues
- Keep screenshots of successful configurations
- Have a pre-configured environment as fallback
- Practice the demo multiple times beforehand

## Post-Demo Cleanup

1. Delete routes from route tables
2. Delete VPC peering connection
3. Optionally terminate test instances
4. Document any issues encountered for future improvements
