# Demo Script: Configure VPC Endpoints Console (5 minutes)

## Pre-Demo Setup
- [ ] AWS Console logged in with existing VPC
- [ ] VPC Endpoints page open
- [ ] EC2 instance in private subnet (optional for testing)
- [ ] Screen sharing/recording ready

## Demo Script with Timing

### Opening (30 seconds)
**Say:** "VPC endpoints enable private connectivity to AWS services without routing traffic over the internet. This improves security and can reduce costs. I'll show you how to create both Gateway and Interface endpoints."

**Action:** Show VPC Endpoints dashboard

### Step 1: Create S3 Gateway Endpoint (2 minutes)
**Say:** "Let's start with a Gateway endpoint for S3. These are free and perfect for accessing S3 buckets from private subnets."

**Actions:**
- Click "Create endpoint"
- Select "AWS services"
- Search for and select S3 service
- **Say:** "Notice this is a Gateway type - it uses route table entries rather than network interfaces"
- Select target VPC
- Select private route tables
- **Say:** "By selecting these route tables, we're telling AWS to automatically add routes that direct S3 traffic through this endpoint"
- Keep "Full access" policy
- Click "Create endpoint"

**Key Point:** "Gateway endpoints are free and only support S3 and DynamoDB"

### Step 2: Create EC2 Interface Endpoint (2 minutes)
**Say:** "Now let's create an Interface endpoint for EC2. These create actual network interfaces in your subnets and support most AWS services."

**Actions:**
- Click "Create endpoint"
- Select "AWS services"  
- Search for and select EC2 service
- **Say:** "This is an Interface type - it will create network interfaces in our subnets"
- Select target VPC
- Select private subnets (preferably in different AZs)
- **Say:** "I'm choosing private subnets because we want secure access to the EC2 API"
- Select IPv4
- Create/select security group allowing HTTPS (443) from VPC CIDR
- **Say:** "The security group must allow HTTPS traffic for API calls to work"
- Keep DNS name enabled
- **Say:** "This allows standard AWS SDK calls to automatically use our private endpoint"
- Click "Create endpoint"

**Key Point:** "Interface endpoints cost about $7.20/month plus data processing charges"

### Step 3: Verify and Test (1 minute)
**Say:** "Let's verify our endpoints are working. The S3 endpoint automatically added routes to our route tables, while the EC2 endpoint created network interfaces with private IPs."

**Actions:**
- Show S3 endpoint details - Route tables tab
- **Say:** "See how routes were automatically added pointing S3 traffic to our endpoint"
- Show EC2 endpoint details - Subnets tab
- **Say:** "Each network interface has a private IP and enables private API access"
- Show DNS names tab
- **Say:** "These private DNS names allow seamless integration with AWS SDKs"

### Step 4: Demonstrate Usage (30 seconds)
**Say:** "From an EC2 instance in a private subnet, S3 and EC2 API calls now use these private endpoints instead of routing over the internet."

**Actions (if EC2 instance available):**
- Show command: `aws s3 ls` (uses S3 endpoint)
- Show command: `aws ec2 describe-instances` (uses EC2 endpoint)
- **Say:** "Notice these commands work even though we're in a private subnet with no internet gateway access"

### Wrap-up (30 seconds)
**Say:** "VPC endpoints provide secure, private access to AWS services. Use Gateway endpoints for S3 and DynamoDB since they're free. Use Interface endpoints for other services when you need private connectivity or want to reduce NAT gateway costs."

**Actions:**
- Summarize the two endpoint types
- Mention security and cost benefits
- Point out the endpoints in the console

## Key Points to Emphasize
- Gateway vs Interface endpoint differences
- Cost implications ($0 vs ~$7.20/month)
- Security benefits of private connectivity
- Automatic DNS resolution with Interface endpoints
- Route table automation with Gateway endpoints

## Common Questions & Answers
**Q:** "When should I use VPC endpoints vs NAT gateways?"
**A:** "Use VPC endpoints for AWS service access to improve security and potentially reduce costs. NAT gateways are still needed for internet access to non-AWS services."

**Q:** "Can I use the same endpoint from multiple VPCs?"
**A:** "No, VPC endpoints are VPC-specific. You need separate endpoints for each VPC."

**Q:** "Do endpoints work across regions?"
**A:** "No, VPC endpoints only provide access to services in the same region."

**Q:** "What happens if I delete an endpoint?"
**A:** "Traffic will route through your internet gateway/NAT gateway instead. No service disruption, but traffic leaves your VPC."

## Demo Variations
- **Short Version (3 min):** Focus on S3 Gateway endpoint only
- **Extended Version (7 min):** Add demonstration of endpoint policies and monitoring
- **Advanced Version:** Show cross-AZ endpoint deployment and failover scenarios
