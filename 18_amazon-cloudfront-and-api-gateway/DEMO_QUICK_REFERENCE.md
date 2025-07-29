# AWS Foundations - CloudFront & API Gateway Demonstrations
## Quick Reference Guide

### Demo 18.3: Deploy CloudFront Distribution (Console)
**Duration**: 5 minutes  
**Tools**: AWS Management Console

#### Quick Steps:
1. **S3 Setup** (1 min): Create bucket → Upload content
2. **CloudFront** (2 min): Create distribution → Select S3 origin → Use recommended settings
3. **Security** (1.5 min): Configure WAF (optional) → Deploy
4. **Test** (0.5 min): Access via CloudFront domain

#### Key URLs:
- S3 Console: https://console.aws.amazon.com/s3/
- CloudFront Console: https://console.aws.amazon.com/cloudfront/v4/home

#### Sample Files:
- `sample-index.html` - Ready-to-use HTML file for demo

---

### Demo 18.5: Deploy API Gateway (Console)
**Duration**: 5 minutes  
**Tools**: AWS Management Console

#### Quick Steps:
1. **Lambda** (1.5 min): Create function → Update code
2. **API Gateway** (1.5 min): Create REST API → Configure settings
3. **Integration** (1.5 min): Create ANY method → Lambda proxy integration
4. **Deploy & Test** (0.5 min): Deploy to stage → Test invoke URL

#### Key URLs:
- Lambda Console: https://console.aws.amazon.com/lambda
- API Gateway Console: https://console.aws.amazon.com/apigateway

#### Sample Files:
- `lambda-function.js` - Enhanced Lambda function code for demo

---

### Common Demo Tips:
- **Preparation**: Have AWS console tabs open beforehand
- **Naming**: Use consistent, descriptive names (include "demo" or timestamp)
- **Timing**: Practice transitions between services
- **Cleanup**: Always demonstrate resource cleanup to avoid charges

### Troubleshooting Quick Fixes:
- **CloudFront 403**: Check S3 bucket policy and OAC
- **API Gateway 502**: Verify Lambda response format
- **Slow deployment**: CloudFront takes 5-15 minutes to fully deploy

### Cost Considerations:
- **CloudFront**: Free tier includes 1TB data transfer out
- **API Gateway**: Free tier includes 1M API calls per month
- **Lambda**: Free tier includes 1M requests per month
- **S3**: Free tier includes 5GB storage

---
*Quick reference for AWS Foundations training demonstrations*
