# Deploy Application Load Balancer (ALB) - Console Demonstration

## Overview
This 5-minute demonstration shows how to create and configure an Application Load Balancer using the AWS Management Console. You'll learn to set up a target group, register EC2 instances, and configure the load balancer to distribute HTTP traffic across multiple targets.

## Prerequisites
- AWS account with appropriate permissions
- At least 2 EC2 instances running in different Availability Zones
- VPC with public subnets in multiple AZs
- Security groups configured to allow HTTP traffic (port 80)

### Option 1: Use Provided Terraform Infrastructure
For convenience, this demo includes Terraform configuration to automatically create the required EC2 instances:

```bash
cd terraform/
terraform init
terraform apply
```

The Terraform infrastructure creates:
- 2 EC2 instances in us-west-2 (different AZs)
- Web servers with unique identification pages
- Proper security groups and IAM roles
- Health check endpoints

See `terraform/README.md` for detailed instructions.

### Option 2: Use Existing EC2 Instances
If you have existing EC2 instances, ensure they:
- Run web servers on port 80
- Are in different Availability Zones
- Have security groups allowing HTTP traffic
- Have unique content to demonstrate load balancing

## Demonstration Steps (5 minutes)

### Step 1: Create Target Group (1.5 minutes)

1. **Navigate to EC2 Console**
   - Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/
   - In the navigation pane, choose **Target Groups**

2. **Configure Target Group**
   - Choose **Create target group**
   - Set **Choose a target type** to **Instances**
   - Enter **Target group name**: `demo-alb-targets`
   - Keep **Protocol**: HTTP and **Port**: 80
   - Select your **VPC**
   - Keep default health check settings
   - Choose **Next**

3. **Register Targets**
   - Select your EC2 instances
   - Ensure port is set to 80
   - Choose **Include as pending below**
   - Choose **Create target group**

### Step 2: Create Application Load Balancer (2.5 minutes)

1. **Navigate to Load Balancers**
   - In the EC2 console navigation pane, choose **Load Balancers**
   - Choose **Create Load Balancer**

2. **Select Load Balancer Type**
   - Under **Application Load Balancer**, choose **Create**

3. **Basic Configuration**
   - **Load balancer name**: `demo-application-lb`
   - **Scheme**: Internet-facing
   - **IP address type**: IPv4

4. **Network Mapping**
   - Select your **VPC**
   - Choose at least 2 **Availability Zones** with public subnets
   - AWS will automatically assign subnets

5. **Security Groups**
   - Create or select a security group that allows:
     - Inbound HTTP (port 80) from 0.0.0.0/0
     - Outbound traffic to targets

6. **Listeners and Routing**
   - Keep default **Protocol**: HTTP, **Port**: 80
   - **Default action**: Forward to target group
   - Select the target group created in Step 1: `demo-alb-targets`

7. **Create Load Balancer**
   - Review configuration
   - Choose **Create load balancer**

### Step 3: Test the Load Balancer (1 minute)

1. **Wait for Provisioning**
   - Wait for load balancer state to change to **Active** (2-3 minutes)
   - Note the **DNS name** of the load balancer

2. **Test Load Balancing**
   - Copy the DNS name
   - Open in web browser or use curl:
     ```bash
     curl http://your-alb-dns-name.region.elb.amazonaws.com
     ```
   - Refresh multiple times to see traffic distributed across targets

3. **Monitor Target Health**
   - Go to **Target Groups** → Select your target group
   - Check **Targets** tab to verify all targets are **healthy**

## Key Points to Highlight

- **Layer 7 Load Balancing**: ALB operates at the application layer (HTTP/HTTPS)
- **Path-based Routing**: Can route based on URL paths (not demonstrated but mention)
- **Health Checks**: Automatically removes unhealthy targets from rotation
- **High Availability**: Distributes traffic across multiple AZs
- **Scalability**: Automatically scales to handle traffic demands

## Cleanup (Optional)
1. Delete the Application Load Balancer
2. Delete the Target Group
3. Terminate EC2 instances if created for demo

## Troubleshooting Tips
- Ensure security groups allow traffic on port 80
- Verify EC2 instances are running and healthy
- Check that subnets are in different AZs
- Confirm VPC has internet gateway for internet-facing ALB

## Additional Resources and Citations

This demonstration is based on official AWS documentation:

1. **Create an Application Load Balancer** - AWS Documentation  
   https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-application-load-balancer.html

2. **Target groups for your Application Load Balancers** - AWS Documentation  
   https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html

3. **What is an Application Load Balancer?** - AWS Documentation  
   https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html

4. **Health checks for Application Load Balancer target groups** - AWS Documentation  
   https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html

---
*Last updated: July 2025*
*Demonstration duration: 5 minutes*
