# Deploy Network Load Balancer (NLB) - Console Demonstration

## Overview
This 5-minute demonstration shows how to create and configure a Network Load Balancer using the AWS Management Console. You'll learn to set up a target group, register EC2 instances, and configure the load balancer to distribute TCP traffic with ultra-low latency and high performance.

## Prerequisites
- AWS account with appropriate permissions
- At least 2 EC2 instances running in different Availability Zones
- VPC with public subnets in multiple AZs
- Security groups configured to allow TCP traffic (port 80 or custom port)
- Applications running on target instances (web servers, databases, etc.)

## Demonstration Steps (5 minutes)

### Step 1: Create Target Group (1.5 minutes)

1. **Navigate to EC2 Console**
   - Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/
   - In the navigation pane, choose **Target Groups**

2. **Configure Target Group**
   - Choose **Create target group**
   - Set **Choose a target type** to **Instances**
   - Enter **Target group name**: `demo-nlb-targets`
   - **Protocol**: TCP
   - **Port**: 80 (or your application port)
   - **IP address type**: IPv4
   - Select your **VPC**

3. **Health Check Configuration**
   - **Health check protocol**: TCP (for basic connectivity) or HTTP (for application-level checks)
   - **Health check port**: Traffic port
   - Keep default intervals and thresholds
   - Choose **Next**

4. **Register Targets**
   - Select your EC2 instances
   - Ensure port matches your application port (80)
   - Choose **Include as pending below**
   - Choose **Create target group**

### Step 2: Create Network Load Balancer (2.5 minutes)

1. **Navigate to Load Balancers**
   - In the EC2 console navigation pane, choose **Load Balancers**
   - Choose **Create Load Balancer**

2. **Select Load Balancer Type**
   - Under **Network Load Balancer**, choose **Create**

3. **Basic Configuration**
   - **Load balancer name**: `demo-network-lb`
   - **Scheme**: Internet-facing
   - **IP address type**: IPv4

4. **Network Mapping**
   - Select your **VPC**
   - Choose at least 2 **Availability Zones**
   - For each AZ, select a public subnet
   - **Optional**: Assign Elastic IP addresses for static IPs

5. **Security Groups** (Note: NLB doesn't use security groups by default)
   - Security groups are applied at the target level
   - Ensure target instances have appropriate security group rules

6. **Listeners and Routing**
   - **Protocol**: TCP
   - **Port**: 80
   - **Default action**: Forward to target group
   - Select the target group created in Step 1: `demo-nlb-targets`

7. **Create Load Balancer**
   - Review configuration
   - Choose **Create load balancer**

### Step 3: Test the Network Load Balancer (1 minute)

1. **Wait for Provisioning**
   - Wait for load balancer state to change to **Active** (2-3 minutes)
   - Note the **DNS name** of the load balancer

2. **Test Load Balancing**
   - Copy the DNS name
   - Test with telnet, curl, or application client:
     ```bash
     # For HTTP applications
     curl http://your-nlb-dns-name.region.elb.amazonaws.com
     
     # For TCP connectivity test
     telnet your-nlb-dns-name.region.elb.amazonaws.com 80
     ```
   - Multiple requests should be distributed across targets

3. **Monitor Target Health**
   - Go to **Target Groups** → Select your target group
   - Check **Targets** tab to verify all targets are **healthy**
   - Health checks may take a few minutes to complete

## Key Points to Highlight

- **Layer 4 Load Balancing**: NLB operates at the transport layer (TCP/UDP)
- **Ultra-Low Latency**: Minimal processing overhead for maximum performance
- **Static IP Addresses**: Can assign Elastic IPs for consistent endpoint addresses
- **High Performance**: Handles millions of requests per second
- **Source IP Preservation**: Client IP addresses are preserved to targets
- **Connection-based**: Maintains connection state for TCP traffic

## Performance Characteristics
- **Latency**: Ultra-low latency (microseconds)
- **Throughput**: Millions of requests per second
- **Connections**: Handles long-lived TCP connections efficiently
- **Scaling**: Automatic scaling without pre-warming

## Cleanup (Optional)
1. Delete the Network Load Balancer
2. Delete the Target Group
3. Release any Elastic IP addresses if assigned
4. Terminate EC2 instances if created for demo

## Troubleshooting Tips
- Ensure target instances have correct security group rules
- Verify applications are listening on the specified ports
- Check that subnets are in different AZs for high availability
- For internet-facing NLB, ensure subnets have internet gateway route
- Monitor CloudWatch metrics for connection and target health

## Use Cases Mentioned
- **High-performance applications**: Gaming, IoT, real-time communications
- **TCP/UDP applications**: Databases, message queues, custom protocols
- **Static IP requirements**: Firewall whitelisting, DNS configurations
- **Extreme scale**: Applications requiring millions of connections

## Additional Resources and Citations

This demonstration is based on official AWS documentation:

1. **Create a Network Load Balancer** - AWS Documentation  
   https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-network-load-balancer.html

2. **Network Load Balancers** - AWS Documentation  
   https://docs.aws.amazon.com/elasticloadbalancing/latest/network/network-load-balancers.html

3. **Target groups for your Network Load Balancers** - AWS Documentation  
   https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html

4. **Health checks for Network Load Balancer target groups** - AWS Documentation  
   https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-health-checks.html

5. **Listener configuration** - AWS Documentation  
   https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html

---
*Last updated: July 2025*
*Demonstration duration: 5 minutes*
