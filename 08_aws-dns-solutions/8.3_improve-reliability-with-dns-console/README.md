# Improve Reliability with DNS - Console Demonstration

## Overview
This 5-minute demonstration shows how to configure DNS failover using Amazon Route 53 to improve application reliability. You'll learn to set up health checks and failover routing to ensure traffic is automatically redirected to healthy resources when primary resources become unavailable.

## Prerequisites
- AWS Account with appropriate permissions for Route 53
- A registered domain name or Route 53 hosted zone
- Two web servers or load balancers in different AWS regions (for demonstration purposes)
- Basic understanding of DNS concepts

## Terraform Infrastructure
This demonstration includes Terraform configuration that deploys:
- **Multi-region EC2 instances**: Primary server in us-east-2, secondary in us-west-2
- **Security groups**: HTTP/HTTPS access for web servers
- **IAM roles**: SSM Session Manager access for instance management
- **Web servers**: Apache with custom HTML pages showing failover status
- **Health check endpoints**: `/health` endpoints for Route 53 monitoring

## Demonstration Scenario
We'll configure a simple active-passive failover setup where:
- Primary resource: Web server in US East (N. Virginia)
- Secondary resource: Web server in US West (Oregon)
- Route 53 will automatically failover to the secondary resource if the primary becomes unhealthy

## Step-by-Step Instructions

### Step 1: Access Route 53 Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **Route 53** service
3. Click on **Hosted zones** in the left navigation panel
4. Select your domain's hosted zone

### Step 2: Create Health Checks (2 minutes)

#### Create Primary Health Check
1. In the Route 53 console, click **Health checks** in the left navigation
2. Click **Create health check**
3. Configure the health check:
   - **Name**: `Primary-Web-Server-Health-Check`
   - **What to monitor**: Endpoint
   - **Specify endpoint by**: IP address or domain name
   - **Protocol**: HTTP or HTTPS
   - **IP address**: Enter your primary server's IP address
   - **Port**: 80 (or 443 for HTTPS)
   - **Path**: `/` (or specific health check endpoint)
4. Click **Next**
5. Configure notifications (optional):
   - **Create alarm**: Yes (recommended)
   - **Send notification to**: Create new SNS topic or select existing
   - **Topic name**: `Route53-Health-Alerts`
   - **Recipient email**: Your email address
6. Click **Create health check**

#### Create Secondary Health Check
1. Repeat the above process for your secondary server:
   - **Name**: `Secondary-Web-Server-Health-Check`
   - Use the secondary server's IP address
   - Configure same protocol and path settings

### Step 3: Create DNS Records with Failover Routing (2 minutes)

#### Create Primary Record
1. Go back to **Hosted zones** and select your domain
2. Click **Create record**
3. Configure the primary record:
   - **Record name**: `www` (or leave blank for root domain)
   - **Record type**: A
   - **Value**: IP address of your primary server
   - **TTL**: 60 seconds (for faster failover)
   - **Routing policy**: Failover
   - **Failover record type**: Primary
   - **Health check**: Select `Primary-Web-Server-Health-Check`
   - **Record ID**: `Primary-Server`
4. Click **Create records**

#### Create Secondary Record
1. Click **Create record** again
2. Configure the secondary record:
   - **Record name**: `www` (same as primary)
   - **Record type**: A
   - **Value**: IP address of your secondary server
   - **TTL**: 60 seconds
   - **Routing policy**: Failover
   - **Failover record type**: Secondary
   - **Health check**: Select `Secondary-Web-Server-Health-Check`
   - **Record ID**: `Secondary-Server`
3. Click **Create records**

### Step 4: Test the Failover Configuration (30 seconds)
1. Open a web browser and navigate to your domain (e.g., `www.yourdomain.com`)
2. Verify the primary server is responding
3. In the Route 53 console, monitor the health check status:
   - Go to **Health checks**
   - Verify both health checks show "Success" status
4. Explain how Route 53 will automatically failover if the primary health check fails

## Key Points to Emphasize During Demonstration

### Reliability Benefits
- **Automatic failover**: No manual intervention required during outages
- **Health monitoring**: Continuous monitoring of endpoint availability
- **Fast recovery**: Low TTL values enable quick DNS propagation
- **Multi-region resilience**: Resources in different regions provide geographic redundancy

### Best Practices Highlighted
- Use short TTL values (60 seconds) for faster failover
- Monitor health checks with CloudWatch alarms
- Test failover scenarios regularly
- Consider using Elastic Load Balancers as targets for better health checking

### Route 53 Features Demonstrated
- Health checks with endpoint monitoring
- Failover routing policy (active-passive)
- DNS record management
- Integration with CloudWatch for monitoring

## Expected Outcomes
By the end of this demonstration, participants will understand:
- How DNS failover improves application reliability
- The relationship between health checks and DNS routing
- How to configure active-passive failover in Route 53
- The importance of TTL values in failover scenarios

## Troubleshooting Tips
- **Health checks failing**: Verify security groups allow Route 53 health checker IPs
- **Slow failover**: Check TTL values and DNS caching
- **Records not resolving**: Verify record configuration and hosted zone settings

## Additional Considerations
- For production environments, consider using Application Load Balancers with health checks
- Implement monitoring and alerting for health check status changes
- Test failover scenarios during maintenance windows
- Consider geographic routing for global applications

## Citations and Documentation References

1. **Configuring DNS failover - Amazon Route 53**  
   https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-configuring.html

2. **Task list for configuring DNS failover - Amazon Route 53**  
   https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-how-to.html

3. **Active-active and active-passive failover - Amazon Route 53**  
   https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-types.html

4. **Creating, updating, and deleting health checks - Amazon Route 53**  
   https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-creating-deleting.html

5. **How health checks work in simple Amazon Route 53 configurations**  
   https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-simple-configs.html

---

*This demonstration is designed to be completed in approximately 5 minutes, focusing on the core concepts of DNS failover and reliability improvements using Amazon Route 53.*
