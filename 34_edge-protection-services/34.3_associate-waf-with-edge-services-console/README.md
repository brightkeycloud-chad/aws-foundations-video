# Demo 34.3: Associate WAF with Edge Services using AWS Console

## Overview
This 5-minute demonstration shows how to associate an existing AWS WAF Web ACL or Protection Pack with edge services (CloudFront distribution) using the AWS Management Console. You'll learn to apply web application firewall protection to your content delivery network.

**Note**: This demo works with both traditional Web ACLs and the new Protection Packs from AWS WAF's updated console experience.

## Prerequisites
- AWS account with appropriate permissions for AWS WAF and CloudFront
- Access to AWS Management Console
- An existing WAF Web ACL or Protection Pack (can be created using Demo 34.2)
- An existing CloudFront distribution (or willingness to create a simple one)

## Demonstration Steps (5 minutes)

### Step 1: Prepare CloudFront Distribution (1 minute)
1. Navigate to **Services** → **Networking & Content Delivery** → **CloudFront**
2. If no distribution exists, click **Create Distribution**:
   - **Origin Domain**: Use any public website (e.g., `example.com`)
   - **Default Cache Behavior**: Keep defaults
   - **Web Application Firewall (WAF)**: Leave as "Do not enable security protections" for now
   - Click **Create Distribution**
   - Wait for deployment (this can take 10-15 minutes, but we'll proceed for demo purposes)
3. Note the Distribution ID for later use

### Step 2: Navigate to WAF Console (30 seconds)
1. Navigate to **Services** → **Security, Identity, & Compliance** → **WAF & Shield**
2. Ensure you're in **US East (N. Virginia)** region for CloudFront resources
3. Choose either:
   - **Web ACLs** (for traditional Web ACLs)
   - **Resources & protections** (for Protection Packs and new experience)

### Method A: Associate from WAF Console (Traditional Web ACL)

#### Step 3A: Select and Associate Web ACL (2 minutes)
1. Click on **Web ACLs** in the left navigation
2. Click on an existing Web ACL (e.g., `demo-web-acl` from previous demo)
3. Click on the **Associated AWS resources** tab
4. Click **Add AWS resources**
5. Select **CloudFront distributions** from the resource type dropdown
6. Select your CloudFront distribution from the list
7. Click **Add**

#### Step 4A: Verify Association (1 minute)
1. Confirm the CloudFront distribution appears in the **Associated AWS resources** list
2. Note the association status (should show as "Associated")
3. Click on the distribution ID to view details in CloudFront console

### Method B: Associate from Resources & Protections (New Experience)

#### Step 3B: Associate Protection Pack (2 minutes)
1. Click on **Resources & protections** in the left navigation
2. Find your Protection Pack or Web ACL in the list
3. Click on the protection name to open details
4. In the **Associated resources** section, click **Associate resources**
5. Select **CloudFront distributions**
6. Choose your distribution from the list
7. Click **Associate**

#### Step 4B: Verify Association (1 minute)
1. Confirm the distribution appears in the **Associated resources** section
2. Note the protection status and any applied rules
3. Click on the distribution link to view in CloudFront console

### Step 5: Test from CloudFront Console (30 seconds)
1. Navigate back to **CloudFront** console
2. Select your distribution
3. Click on the **Security** tab
4. Verify that the WAF Web ACL or Protection Pack is listed under **AWS WAF web ACL**
5. Note the Web ACL ARN is displayed

## Alternative Method: Associate from CloudFront Console

### CloudFront Security Dashboard Method (2 minutes)
1. In **CloudFront** console, select your distribution
2. Click on the **Security** tab
3. In the **AWS WAF** section, click **Edit**
4. Select your Web ACL or Protection Pack from the dropdown
5. Click **Save changes**
6. Wait for distribution to update (Status: "In Progress" → "Deployed")

### Traditional CloudFront Distribution Edit Method (2 minutes)
1. In **CloudFront** console, select your distribution
2. Click **Edit** on the distribution settings
3. Scroll to **Settings** section
4. Under **AWS WAF web ACL**, select your Web ACL from dropdown
5. Click **Save changes**
6. Wait for distribution to update (Status: "In Progress" → "Deployed")

## CloudFront One-Click Protection (New Feature)

AWS CloudFront now offers **one-click protection** that automatically creates and associates a WAF configuration:

### Enable One-Click Protection (Alternative Approach)
1. In CloudFront console, select your distribution
2. Click on the **Security** tab
3. Click **Enable AWS WAF** 
4. Choose **One-click protection**
5. Select protection level:
   - **Basic**: Core protections against common threats
   - **Enhanced**: Includes bot control and advanced rules
6. Click **Enable protection**
7. AWS automatically creates and associates a Web ACL

## Key Learning Points
- WAF Web ACLs and Protection Packs can be associated with multiple CloudFront distributions
- Association can be done from either WAF or CloudFront console
- CloudFront now offers one-click protection for simplified setup
- Changes to CloudFront distributions take time to propagate globally (10-15 minutes)
- WAF rules are applied at CloudFront edge locations worldwide
- One Web ACL can protect multiple distributions, but each distribution can only have one Web ACL
- **New Security Dashboard**: CloudFront's Security tab provides centralized security management
- **Protection Packs**: Offer simplified, application-aware security configurations

## Monitoring and Verification
After association, you can monitor WAF activity through multiple interfaces:

### CloudFront Security Dashboard
1. **Security Metrics**: View blocked requests, allowed requests, and threat patterns
2. **Top Threats**: See most common attack types and sources
3. **Geographic Analysis**: Understand traffic patterns by region
4. **Real-time Monitoring**: Track security events as they happen

### Traditional Monitoring
1. **CloudWatch Metrics**: View detailed WAF metrics and create alarms
2. **WAF Logs**: Enable logging to see detailed request analysis
3. **Sampled Requests**: Real-time view of requests and rule matches
4. **CloudFront Reports**: Access security reports in CloudFront console

## Post-Demo Cleanup
Run the cleanup script to remove associations and resources:
```bash
./cleanup.sh
```

## Troubleshooting
- **Distribution not visible**: Ensure you're in the correct region (US East for CloudFront)
- **Permission errors**: Verify IAM permissions for both WAF and CloudFront
- **Association fails**: Check if distribution is in "Deployed" status
- **Changes not taking effect**: CloudFront changes can take 10-15 minutes to propagate
- **Protection Pack not found**: Ensure you're looking in the correct console section (Resources & protections vs Web ACLs)
- **One-click protection issues**: Verify CloudFront distribution is fully deployed before enabling
- **Security dashboard empty**: WAF must be enabled to view security metrics

## Testing WAF Rules
To test if WAF is working:
1. Try accessing your CloudFront distribution URL
2. Attempt requests that should trigger WAF rules
3. Check CloudWatch metrics for blocked requests
4. Review WAF logs if enabled

## Additional Resources and Citations

### AWS Documentation
- [Associating or disassociating protection with an AWS resource](https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-associating-aws-resource.html)
- [Using AWS WAF with CloudFront](https://docs.aws.amazon.com/waf/latest/developerguide/cloudfront-features.html)
- [CloudFront Security Dashboard](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/security-dashboard.html)
- [Enable AWS WAF for CloudFront Distributions](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/WAF-one-click.html)
- [Use AWS WAF Protections with CloudFront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-awswaf.html)
- [Working with the Updated Console Experience](https://docs.aws.amazon.com/waf/latest/developerguide/working-with-console.html)
- [Monitoring AWS WAF](https://docs.aws.amazon.com/waf/latest/developerguide/monitoring-cloudwatch.html)

### Best Practices
- [AWS WAF Security Best Practices](https://docs.aws.amazon.com/waf/latest/developerguide/security-best-practices.html)
- [CloudFront Security Best Practices](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/SecurityAndPrivateContent.html)
- [AWS WAF and CloudFront Integration Guide](https://docs.aws.amazon.com/waf/latest/developerguide/cloudfront-features.html)
- [Guidelines for Implementing AWS WAF](https://docs.aws.amazon.com/whitepapers/latest/guidelines-for-implementing-aws-waf/guidelines-for-implementing-aws-waf.html)

### Pricing Information
- [AWS WAF Pricing](https://aws.amazon.com/waf/pricing/)
- [CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/)
- [AWS WAF Bot Control Pricing](https://aws.amazon.com/waf/pricing/#AWS_WAF_Bot_Control)

---
*Demo created for AWS Foundations training - Edge Protection Services module*
