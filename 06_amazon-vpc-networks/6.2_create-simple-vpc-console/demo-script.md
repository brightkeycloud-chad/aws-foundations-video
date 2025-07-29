# Demo Script: Create Simple VPC Console (5 minutes)

## Pre-Demo Setup
- [ ] AWS Console logged in and ready
- [ ] VPC service page open
- [ ] Region set to us-east-1 (or preferred region)
- [ ] Screen sharing/recording ready

## Demo Script with Timing

### Opening (30 seconds)
**Say:** "Today I'll show you how to create a simple VPC using the AWS Console. This is a fundamental skill for building secure, isolated networks in AWS. We'll create a production-ready VPC with public and private subnets across multiple availability zones."

**Action:** Show VPC dashboard

### Step 1: Start VPC Creation (30 seconds)
**Say:** "Let's start by clicking 'Create VPC'. I'll choose 'VPC and more' because this creates not just the VPC, but all the supporting resources we need."

**Actions:**
- Click "Create VPC"
- Select "VPC and more"
- Point out the preview diagram

### Step 2: Basic Configuration (1 minute)
**Say:** "For the IPv4 CIDR block, I'm using 10.0.0.0/16. This gives us over 65,000 IP addresses to work with. I'll keep tenancy as 'Default' for cost efficiency."

**Actions:**
- Enter `10.0.0.0/16` in IPv4 CIDR
- Explain CIDR notation briefly
- Keep other defaults

### Step 3: Availability Zones and Subnets (1.5 minutes)
**Say:** "For production workloads, always use multiple availability zones. I'm selecting 2 AZs with 2 public and 2 private subnets. Public subnets will host resources that need direct internet access, like load balancers. Private subnets will host our application servers and databases."

**Actions:**
- Set AZs to 2
- Set public subnets to 2
- Set private subnets to 2
- Show the automatic CIDR allocation
- Explain public vs private subnet concepts

### Step 4: Internet Connectivity (1 minute)
**Say:** "NAT gateways allow resources in private subnets to access the internet for updates and patches. I'm choosing '1 per AZ' for high availability. The S3 gateway endpoint provides direct access to S3 without internet routing."

**Actions:**
- Select "1 per AZ" for NAT gateways
- Select "S3 Gateway" for VPC endpoints
- Mention cost implications
- Keep DNS options enabled

### Step 5: Review and Create (1 minute)
**Say:** "The preview shows our architecture - notice how the private subnets connect to the internet through NAT gateways, while public subnets use the internet gateway directly. This is a typical 3-tier architecture pattern."

**Actions:**
- Review the preview diagram
- Point out key connections
- Click "Create VPC"
- Show creation progress

### Wrap-up (30 seconds)
**Say:** "While this creates, remember that this VPC provides the foundation for secure, scalable applications. You can now launch EC2 instances, RDS databases, and other resources into these subnets with appropriate network isolation."

**Actions:**
- Show final resource map
- Mention next steps
- Highlight key resources created

## Key Points to Emphasize
- Multi-AZ design for high availability
- Public vs private subnet use cases
- Cost implications of NAT gateways
- Security benefits of private subnets
- Scalability of the chosen CIDR block

## Common Questions & Answers
**Q:** "Why not use the default VPC?"
**A:** "Default VPCs are convenient but lack the security and customization needed for production workloads."

**Q:** "Can I change the CIDR block later?"
**A:** "You can add additional CIDR blocks, but you cannot modify the primary CIDR block after creation."

**Q:** "What's the cost of this setup?"
**A:** "The VPC itself is free, but NAT gateways cost about $45/month each plus data processing charges."
