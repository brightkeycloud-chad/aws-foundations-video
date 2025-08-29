# AWS CodePipeline CI/CD Process with Python CDK

## Demonstration Overview
**Duration:** 5 minutes  
**Tools:** AWS CDK (Python), Terminal, AWS Console  
**Objective:** Create a complete CI/CD pipeline using AWS CodePipeline with Python CDK that automatically builds and deploys a simple web application.

## Prerequisites
- AWS CLI configured with appropriate permissions
- Python 3.6+ installed
- Node.js 14+ installed (required for CDK)
- AWS CDK v2 installed (`npm install -g aws-cdk`)

## Architecture Overview
This demonstration creates:
- **Source Stage**: S3 bucket with versioning for source code
- **Build Stage**: AWS CodeBuild project for building the application
- **Deploy Stage**: S3 deployment for application artifacts
- **S3 Buckets**: Source, artifacts, and deployment buckets
- **IAM Roles**: For pipeline execution permissions

## Quick Start

### Deploy the Pipeline
```bash
./deploy.sh
```

### Clean Up Resources
```bash
./cleanup.sh
```

## What the Scripts Do

### deploy.sh
1. Sets up Python virtual environment
2. Installs CDK dependencies
3. Detects AWS account and region automatically
4. Bootstraps CDK environment
5. Deploys the pipeline stack
6. Creates sample source package
7. Uploads source to trigger pipeline
8. Enables S3 versioning (required for CodePipeline)

### cleanup.sh
1. Destroys the CDK stack
2. Removes all created resources
3. Cleans up local files

## Pipeline Architecture

```
Source (S3) → Build (CodeBuild) → Deploy (S3)
```

### Source Stage
- S3 bucket with versioning enabled
- Monitors `source.zip` file for changes
- Automatically triggers pipeline on updates

### Build Stage
- CodeBuild project with Node.js 14 runtime
- Simple build process that lists files
- Passes artifacts to deploy stage

### Deploy Stage
- Deploys build artifacts to S3 bucket
- Private bucket (no public access)

## Key Features

- **Automatic AWS Detection**: Uses STS to detect account and region
- **Versioned Source**: S3 versioning enabled for proper pipeline operation
- **Simple Build Process**: Minimal buildspec for demonstration
- **Private Deployment**: No public access requirements
- **Easy Cleanup**: Single command to remove all resources

## Demonstration Script

### Introduction (30 seconds)
"We'll create a complete CI/CD pipeline using AWS CodePipeline and Python CDK. The pipeline automatically builds and deploys when we upload source code."

### Deployment (2 minutes)
1. Run `./deploy.sh`
2. Show CloudFormation stack creation
3. Navigate to CodePipeline console
4. Show pipeline execution

### Pipeline Trigger (1.5 minutes)
1. Upload new source.zip to trigger pipeline
2. Watch pipeline stages execute
3. Verify deployment in target S3 bucket

### Cleanup (1 minute)
1. Run `./cleanup.sh`
2. Confirm resource deletion

## Troubleshooting

### Common Issues
- **S3 Versioning**: Automatically enabled by deploy script
- **Permissions**: Ensure AWS credentials have sufficient permissions
- **Region**: Script auto-detects region from AWS configuration

### Manual Fixes
If pipeline fails:
```bash
# Check pipeline status
aws codepipeline get-pipeline-state --name <pipeline-name>

# Restart pipeline
aws codepipeline start-pipeline-execution --name <pipeline-name>
```

## File Structure
```
.
├── app.py                          # CDK app entry point
├── codepipeline_demo/
│   ├── __init__.py                 # Python package marker
│   └── codepipeline_demo_stack.py  # CDK stack definition
├── deploy.sh                       # Deployment script
├── cleanup.sh                      # Cleanup script
├── requirements.txt                # Python dependencies
├── cdk.json                        # CDK configuration
└── sample-source/
    └── index.html                  # Sample web page
```

## Learning Points
- **Infrastructure as Code**: CDK manages all AWS resources
- **Automatic Configuration**: STS-based account/region detection
- **Pipeline Automation**: Triggered by S3 object changes
- **Versioning Requirements**: S3 versioning needed for CodePipeline
- **Security**: IAM roles provide least-privilege access

---
*This demonstration uses current AWS documentation and best practices as of August 2025.*
