# Deploy CloudFront Distribution - Console Demonstration

## Overview
This 5-minute demonstration shows how to create and deploy an Amazon CloudFront distribution using the AWS Management Console. You'll learn to set up a content delivery network (CDN) that accelerates the delivery of your web content to users worldwide.

## Prerequisites
- AWS account with appropriate permissions
- Basic understanding of web content delivery
- Access to AWS Management Console

## Demonstration Objectives
By the end of this demonstration, you will:
- Understand CloudFront's role in content delivery
- Create a CloudFront distribution using the console
- Configure basic distribution settings
- Test the distribution deployment

## Step-by-Step Instructions

### Step 1: Prepare Content Source (1 minute)
1. **Create an S3 bucket** (if you don't have one):
   - Navigate to the S3 console at https://console.aws.amazon.com/s3/
   - Click **Create bucket**
   - Enter a unique bucket name (e.g., `my-cloudfront-demo-bucket-[random-number]`)
   - Choose a region close to you
   - Leave default settings and click **Create bucket**

2. **Upload sample content**:
   - Select your bucket
   - Click **Upload**
   - Upload a simple HTML file or image for testing
   - Make note of the object key (filename)

### Step 2: Create CloudFront Distribution (2 minutes)
1. **Access CloudFront Console**:
   - Navigate to https://console.aws.amazon.com/cloudfront/v4/home
   - Click **Create distribution**

2. **Configure Distribution**:
   - Enter a **Distribution name** (e.g., `my-demo-distribution`)
   - Choose **Single website or app**
   - Click **Next**

3. **Select Origin**:
   - For **Origin type**, select **Amazon S3**
   - Click **Browse S3** and select your bucket
   - For **Settings**, choose **Use recommended origin settings**
   - Click **Next**

### Step 3: Configure Security and Deploy (1.5 minutes)
1. **Security Settings**:
   - On the **Enable security protections** page
   - Choose whether to enable AWS WAF (optional for demo)
   - Click **Next**

2. **Create Distribution**:
   - Review your settings
   - Click **Create distribution**
   - CloudFront will automatically update the S3 bucket policy

3. **Monitor Deployment**:
   - Note the distribution domain name (e.g., `d111111abcdef8.cloudfront.net`)
   - Wait for the **Last modified** field to change from **Deploying** to a timestamp

### Step 4: Test the Distribution (0.5 minutes)
1. **Access Content**:
   - Copy the CloudFront domain name
   - In a new browser tab, navigate to: `https://[domain-name]/[your-file-name]`
   - Verify that your content loads through CloudFront

2. **Verify Headers** (Optional):
   - Use browser developer tools to check response headers
   - Look for `x-cache` header indicating CloudFront served the content

## Key Points to Highlight During Demo
- **Global Edge Locations**: CloudFront uses 400+ edge locations worldwide
- **Origin Access Control (OAC)**: Automatically configured to secure S3 access
- **Caching**: Content is cached at edge locations for faster delivery
- **Domain Name**: CloudFront provides a unique domain name for your distribution
- **Deployment Time**: Initial deployment takes 5-15 minutes

## Common Issues and Troubleshooting
- **403 Forbidden Error**: Check S3 bucket policy and OAC configuration
- **Slow Initial Load**: First request to edge location may be slower (cache miss)
- **Content Not Updating**: CloudFront caches content; use invalidations for immediate updates

## Cleanup Instructions
To avoid ongoing charges:
1. Delete the CloudFront distribution:
   - Select the distribution
   - Click **Disable** first, wait for deployment
   - Then click **Delete**
2. Delete the S3 bucket and its contents

## Additional Resources and Citations

### AWS Documentation References
- [Create a distribution - Amazon CloudFront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-creating-console.html)
- [Get started with a CloudFront standard distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GettingStarted.SimpleDistribution.html)
- [Restrict access to an Amazon S3 origin](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)

### Additional Learning
- [CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/)
- [CloudFront Use Cases](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/IntroductionUseCases.html)
- [CloudFront Best Practices](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/best-practices.html)

---
*Last updated: July 2025*
*Documentation sources: AWS Official Documentation*
