# 5-Minute CodePipeline Demo - Quick Reference Guide

## Pre-Demo Setup (Do this before the presentation)
1. Ensure AWS CLI is configured with appropriate permissions
2. Have the demo directory ready with all files
3. Test the deployment once to ensure everything works
4. Clean up the test deployment: `cdk destroy`

## Demo Flow (5 minutes total)

### 1. Introduction (30 seconds)
**Script:** "Today I'll show you how to create a complete CI/CD pipeline using AWS CodePipeline and Python CDK. This pipeline will automatically build and deploy a web application with just a few lines of infrastructure code."

**Show:** Open the project directory in your IDE/terminal

### 2. Code Walkthrough (90 seconds)
**Show the key files:**

#### app.py (15 seconds)
```python
# Point out the automatic AWS environment detection
def get_aws_environment():
    # Get AWS account ID using STS
    sts_client = boto3.client('sts')
    account_id = sts_client.get_caller_identity()['Account']
```
"The app automatically detects your AWS account and region using STS - no manual configuration needed"

#### codepipeline_demo_stack.py (75 seconds)
**Highlight these sections:**

1. **Artifact Bucket** (15 seconds)
```python
artifact_bucket = s3.Bucket(self, "PipelineArtifacts", ...)
```
"First, we create an S3 bucket to store our pipeline artifacts"

2. **Build Project** (20 seconds)
```python
build_project = codebuild.Project(self, "BuildProject", ...)
```
"Next, we define a CodeBuild project with a simple build specification"

3. **Pipeline Stages** (40 seconds)
```python
# Source stage
pipeline.add_stage(stage_name="Source", actions=[source_action])
# Build stage  
pipeline.add_stage(stage_name="Build", actions=[build_action])
# Deploy stage
pipeline.add_stage(stage_name="Deploy", actions=[deploy_action])
```
"The pipeline has three stages: Source pulls code from S3, Build compiles it, and Deploy publishes to a static website"

### 3. Deployment (2 minutes)
**Run the automated deployment:**

```bash
# Show the command
./deploy.sh
```

**While it's running, explain:**
- "The script is bootstrapping CDK and deploying our infrastructure"
- "CDK converts our Python code into CloudFormation templates"
- "This creates all the AWS resources: S3 buckets, CodeBuild project, CodePipeline, and IAM roles"

**Show in AWS Console:**
1. Open CloudFormation console - show stack being created
2. Open CodePipeline console - show pipeline being created

### 4. Pipeline Execution (60 seconds)
**Once deployment completes:**

1. **Show Pipeline Console** (30 seconds)
   - Navigate to CodePipeline console
   - Show the three stages: Source, Build, Deploy
   - Point out that it's already running because we uploaded source.zip

2. **Show Build Logs** (30 seconds)
   - Click on the Build stage
   - Show CodeBuild logs
   - Explain what's happening in each phase

### 5. Results & Wrap-up (60 seconds)
**Show the results:**

1. **Website URL** (30 seconds)
   - Get the website URL from CloudFormation outputs
   - Open the deployed website
   - Show that it's live and working

2. **Key Benefits** (30 seconds)
   - "Infrastructure as Code - everything is version controlled"
   - "Automated deployment - no manual steps"
   - "Scalable - easy to add more stages like testing or staging"
   - "Cost-effective - pay only for what you use"

## Demo Commands Cheat Sheet

```bash
# If you need to deploy manually
cdk bootstrap
cdk deploy

# To trigger pipeline manually
aws s3 cp source.zip s3://[SOURCE-BUCKET-NAME]/source.zip

# To check pipeline status
aws codepipeline get-pipeline-state --name demo-cicd-pipeline

# To clean up
cdk destroy
```

## Troubleshooting During Demo

### If deployment fails:
- Check AWS credentials: `aws sts get-caller-identity`
- Verify region: `aws configure get region`
- Check CDK bootstrap: `cdk bootstrap`

### If pipeline doesn't start:
- Manually upload source.zip to the source bucket
- Check S3 bucket permissions
- Verify CodePipeline service role

### If website doesn't load:
- Check S3 bucket public access settings
- Verify website configuration
- Check CloudFormation outputs for correct URL

## Backup Slides/Talking Points

If you have extra time or questions:

1. **Security Best Practices:**
   - IAM roles with least privilege
   - Encrypted artifact storage
   - VPC integration for private builds

2. **Advanced Features:**
   - Manual approval gates
   - Parallel execution
   - Cross-region deployments
   - Integration with other AWS services

3. **Cost Optimization:**
   - Disabled cross-account keys for demo
   - Small compute instances
   - Lifecycle policies for artifacts

## Post-Demo Cleanup
```bash
cdk destroy
# Confirm when prompted
```

## Files Created During Demo
- CloudFormation stack: `CodepipelineDemoStack`
- S3 buckets: artifact, source, and deploy buckets
- CodeBuild project: `demo-build-project`
- CodePipeline: `demo-cicd-pipeline`
- IAM roles: Various service roles for pipeline execution
