# Demo 34.2: Create WAF Web ACL using AWS Console or CLI

## Overview
This demonstration shows how to create an AWS WAF (Web Application Firewall) Web ACL using either the AWS Management Console or AWS CLI automation. You'll learn to configure basic security rules including bot protection to protect web applications from common threats.

**Note**: AWS has introduced a new console experience with "Protection Packs" as the recommended approach. This demo covers both the traditional Web ACL creation method and automated CLI approach, both of which remain fully supported.

## Prerequisites
- AWS account with appropriate permissions for AWS WAF
- AWS CLI configured with appropriate credentials
- Access to AWS Management Console (for manual approach)
- Basic understanding of web security concepts

## Quick Start (Automated Setup)

For a quick automated setup, run the provided script:

```bash
./setup.sh
```

This script creates a WAF Web ACL named `demo-web-acl` with the following managed rule groups:
- AWS Core Rule Set (Priority 1)
- AWS Known Bad Inputs (Priority 2) 
- AWS Bot Control (Priority 3)

The Web ACL will be created in the `us-east-1` region with `CLOUDFRONT` scope and configured with a default `Allow` action.

## Demonstration Options

You can complete this demonstration using either:

1. **Automated CLI Approach** (Recommended for quick setup): Use the provided `setup.sh` script
2. **Manual Console Approach** (Educational): Follow the step-by-step console instructions below

### Option 1: Automated CLI Setup (2 minutes)

The automated approach creates the same Web ACL configuration using AWS CLI:

```bash
./setup.sh
```

**What the script creates:**
- Web ACL named `demo-web-acl` in `us-east-1` region
- Scope: `CLOUDFRONT` (for global edge protection)
- Default action: `Allow` (allows traffic that doesn't match any rules)
- Three managed rule groups with proper priorities:
  - **AWS Core Rule Set** (Priority 1) - Protects against OWASP Top 10 vulnerabilities
  - **AWS Known Bad Inputs** (Priority 2) - Blocks known malicious request patterns
  - **AWS Bot Control** (Priority 3) - Intelligent bot detection and management

**Script output example:**
```
✅ WAF Web ACL created successfully!
Web ACL ARN: arn:aws:wafv2:us-east-1:123456789012:global/webacl/demo-web-acl/abc123...
Web ACL Name: demo-web-acl
Region: us-east-1

The Web ACL includes the following managed rule groups:
  - AWS Core Rule Set (Priority 1)
  - AWS Known Bad Inputs (Priority 2)
  - AWS Bot Control (Priority 3)
```

### Option 2: Manual Console Approach (5 minutes)

### Step 1: Navigate to AWS WAF Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **Services** → **Security, Identity, & Compliance** → **WAF & Shield**
3. Ensure you're in the correct AWS region (US East N. Virginia for CloudFront)
4. In the navigation pane, choose **Web ACLs** (traditional approach)

### Step 2: Create Web ACL (2 minutes)
1. Click **Create web ACL**
2. Configure basic settings:
   - **Name**: `demo-web-acl`
   - **Description**: `Demo Web ACL for edge protection`
   - **CloudWatch metric name**: `demoWebACL` (auto-populated)
   - **Resource type**: Select **CloudFront distributions**
   - **Region**: Automatically set to **Global (CloudFront)**
3. Click **Next**

### Step 3: Add Rules and Bot Protection (2.5 minutes)
1. Click **Add rules** → **Add managed rule groups**
2. Select **AWS managed rule groups**:
   - **Core rule set**: Toggle **Add to web ACL**
   - **Known bad inputs**: Toggle **Add to web ACL**
   - **Bot Control**: Toggle **Add to web ACL** (explore bot protection)
3. **Explore Bot Control Rule Group**:
   - Click on **Bot Control** to expand details
   - Note the **Capacity**: 50 WCUs (Web ACL Capacity Units)
   - **Protection Level**: Choose **Common** (default) or **Targeted** (advanced ML-based detection)
   - Review **Rule descriptions**:
     - `CategoryHttpLibrary` - Blocks HTTP libraries and tools
     - `CategoryLinkChecker` - Manages link checker bots
     - `CategorySEO` - Handles SEO and monitoring bots
     - `CategorySocialMedia` - Controls social media bots
     - `CategorySearchEngine` - Manages search engine crawlers
   - **Action Override**: Keep as **Use rule group configuration**
4. **Bot Protection Explanation** (30 seconds):
   - Bot Control identifies and categorizes automated traffic
   - **Common Level**: Uses traditional detection (static analysis, self-identifying bots)
   - **Targeted Level**: Adds ML-based detection, CAPTCHA, and browser challenges
   - Differentiates between good bots (search engines) and bad bots (scrapers)
   - Uses machine learning and behavioral analysis for sophisticated threats
   - Provides granular control over bot categories
5. Review total capacity units (should be under 1,500 limit)
6. Click **Add rules**
7. Review the complete rules list and click **Next**

### Step 4: Set Default Action (30 seconds)
1. Under **Default web ACL action for requests that don't match any rules**:
   - Select **Allow**
2. Click **Next**

### Step 5: Review and Create (1 minute)
1. Review all configurations:
   - Web ACL details
   - Rules and rule groups
   - Default action
2. Click **Create web ACL**
3. Wait for creation to complete (usually 30-60 seconds)
4. Note the Web ACL ARN for future reference

## Script Technical Details

### Setup Script (`setup.sh`)
The automated setup script uses the AWS CLI `wafv2 create-web-acl` command with the following configuration:

- **Scope**: `CLOUDFRONT` (required for global edge protection)
- **Region**: `us-east-1` (required for CloudFront WAF resources)
- **Default Action**: `Allow` (permits traffic that doesn't match any rules)
- **Managed Rule Groups**: Three AWS-managed rule groups with specific priorities

### Verification
After running the setup script, you can verify the Web ACL creation:

```bash
# List all Web ACLs
aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1

# Get detailed Web ACL information
aws wafv2 get-web-acl --scope CLOUDFRONT --name demo-web-acl --id <web-acl-id> --region us-east-1
```

### Capacity Usage
The created Web ACL uses approximately 950 Web ACL Capacity Units (WCUs):
- Core Rule Set: ~700 WCUs
- Known Bad Inputs: ~200 WCUs  
- Bot Control: ~50 WCUs

This is well within the default limit of 1,500 WCUs per Web ACL.

## Understanding Bot Protection in AWS WAF

### What is Bot Control?
AWS WAF Bot Control is an intelligent managed rule group that helps identify and manage automated traffic (bots) accessing your web applications. It uses machine learning, behavioral analysis, and threat intelligence to distinguish between legitimate and malicious bots.

### Protection Levels
- **Common Level**: 
  - Detects self-identifying bots using traditional techniques
  - Analyzes static request data
  - Labels and blocks unverified bots
  - Lower cost, basic protection
  
- **Targeted Level**: 
  - Includes all Common level protections
  - Adds sophisticated ML-based detection for advanced bots
  - Uses browser interrogation and fingerprinting
  - Implements CAPTCHA and challenge mechanisms
  - Rules prefixed with `TGT_` (targeted) and `TGT_ML_` (machine learning)

### Bot Categories Explained
- **CategoryHttpLibrary**: HTTP client libraries and automated tools
- **CategoryLinkChecker**: Link validation and website monitoring bots
- **CategorySEO**: Search engine optimization and website analysis tools
- **CategorySocialMedia**: Social media platform bots and crawlers
- **CategorySearchEngine**: Search engine crawlers (Google, Bing, etc.)
- **CategoryMonitoring**: Website monitoring and uptime checking services

### Bot Control Benefits
1. **Intelligent Detection**: Uses AWS's machine learning models trained on global traffic patterns
2. **Granular Control**: Manage different bot categories with specific actions
3. **Legitimate Bot Protection**: Allows beneficial bots (search engines) while blocking malicious ones
4. **Real-time Analysis**: Evaluates requests in real-time at edge locations
5. **Cost Optimization**: Reduces bandwidth costs by blocking unwanted automated traffic
6. **Token Management**: Uses AWS WAF tokens for client session tracking and verification

### Common Use Cases
- **E-commerce**: Prevent price scraping and inventory hoarding bots
- **Content Sites**: Allow search engine crawlers while blocking content scrapers
- **APIs**: Protect against automated abuse while allowing legitimate integrations
- **Gaming**: Prevent cheating bots and automated gameplay
- **Media Streaming**: Block unauthorized content access bots

### Monitoring Bot Activity
After enabling Bot Control, monitor activity through:
- **CloudWatch Metrics**: View bot detection and blocking statistics
- **WAF Logs**: Detailed logs showing bot categories and actions taken
- **Sampled Requests**: Real-time view of bot traffic patterns
- **Label Metrics**: Track specific bot categories and behaviors

## Key Learning Points
- AWS WAF Web ACLs provide application-layer protection
- Managed rule groups offer pre-configured security rules
- **Bot Control provides intelligent bot management**:
  - Distinguishes between legitimate and malicious bots
  - Uses behavioral analysis and machine learning
  - Offers category-based bot filtering
  - Protects against automated attacks while allowing good bots
- Web ACLs can be associated with CloudFront, Application Load Balancer, or API Gateway
- Default actions determine behavior for non-matching requests
- CloudWatch metrics help monitor WAF activity and bot detection

## Post-Demo Cleanup
Run the cleanup script to remove resources created during this demonstration:
```bash
./cleanup.sh
```

The cleanup script will:
- Locate the `demo-web-acl` Web ACL
- Display the configured rules (including Bot Control)
- Check for associated CloudFront distributions
- Safely delete the Web ACL and all its rules
- Verify successful deletion

## Optional: Testing Bot Detection
After associating the Web ACL with a CloudFront distribution (Demo 34.3), you can test bot detection:
```bash
./test-bot-detection.sh https://your-cloudfront-domain.cloudfront.net
```
This script simulates various types of automated requests to demonstrate how Bot Control categorizes and handles different user agents.

## Alternative: New Protection Pack Approach

AWS has introduced a new console experience that emphasizes **Protection Packs** as the recommended approach for new users. Here's a quick overview:

### Protection Pack Benefits
- **Simplified Setup**: Pre-configured security rules tailored to specific workload types
- **Application-Aware**: Rules optimized based on your app category (API, Web, or Both)
- **Best Practices**: Implements AWS security recommendations automatically
- **Guided Configuration**: Streamlined wizard-based setup process

### Quick Protection Pack Creation (Alternative Method)
1. Navigate to **Resources & protections** in the WAF console
2. Choose **Add protection pack**
3. Select your **App category** and **Traffic source**
4. Add resources to protect
5. Choose **Recommended** protection level
6. Review and create

### When to Use Each Approach
- **Protection Packs**: Best for new deployments, standard use cases, simplified management
- **Traditional Web ACLs**: Better for custom configurations, advanced rule management, existing deployments

Both approaches provide the same underlying security capabilities and can be managed through the same console interface.

## Troubleshooting
- **Permission errors**: Ensure your IAM user/role has `WAFv2FullAccess` permissions
- **Region issues**: WAF for CloudFront must be created in US East (N. Virginia)
- **Capacity limits**: Each Web ACL has a default capacity of 1,500 WCUs (Web ACL Capacity Units)
- **Bot Control capacity**: Bot Control uses 50 WCUs, plan accordingly with other rules
- **False positives**: Monitor bot detection carefully; legitimate tools may be blocked
- **Cost considerations**: Bot Control has additional per-request charges beyond base WAF pricing

## Additional Resources and Citations

### AWS Documentation
- [AWS WAF Developer Guide](https://docs.aws.amazon.com/waf/latest/developerguide/waf-chapter.html)
- [Creating a Web ACL](https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-creating.html)
- [Getting Started with Protection Packs](https://docs.aws.amazon.com/waf/latest/developerguide/setup-iap-console.html)
- [AWS Managed Rules for AWS WAF](https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups.html)
- [AWS WAF Bot Control](https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-bot.html)
- [Bot Control Rule Group Reference](https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html#aws-managed-rule-groups-bot)
- [Working with the Updated Console Experience](https://docs.aws.amazon.com/waf/latest/developerguide/working-with-console.html)
- [AWS WAF Pricing](https://aws.amazon.com/waf/pricing/)

### Bot Protection Resources
- [AWS WAF Bot Control Overview](https://aws.amazon.com/waf/features/bot-control/)
- [Adding Bot Control to Web ACL](https://docs.aws.amazon.com/waf/latest/developerguide/waf-bot-control-rg-using.html)
- [Bot Management Best Practices](https://docs.aws.amazon.com/waf/latest/developerguide/waf-managed-protections-best-practices.html)
- [Understanding Bot Traffic Patterns](https://docs.aws.amazon.com/waf/latest/developerguide/monitoring-cloudwatch.html)
- [Token Management in Bot Control](https://docs.aws.amazon.com/waf/latest/developerguide/waf-tokens.html)

### Best Practices
- [AWS WAF Security Best Practices](https://docs.aws.amazon.com/waf/latest/developerguide/security-best-practices.html)
- [Monitoring AWS WAF](https://docs.aws.amazon.com/waf/latest/developerguide/monitoring-cloudwatch.html)

---
*Demo created for AWS Foundations training - Edge Protection Services module*
