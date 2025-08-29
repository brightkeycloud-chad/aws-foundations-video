# AWS CodeDeploy Lambda Demo

A 5-minute demonstration of using AWS CodeDeploy to deploy updates to a Lambda function.

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- jq installed (for JSON processing)

## Demo Structure

```
.
├── README.md                 # This file
├── terraform/               # Initial Lambda deployment
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── lambda-code/             # Lambda function code
│   ├── v1/
│   │   └── index.js        # Initial version
│   └── v2/
│       └── index.js        # Updated version
├── scripts/                 # Automation scripts
│   ├── deploy.sh           # Initial deployment
│   ├── update.sh           # CodeDeploy update
│   └── cleanup.sh          # Cleanup resources
└── codedeploy/             # CodeDeploy configuration
    └── appspec.yml         # Application specification
```

## Quick Start (5-minute demo)

1. **Initial Setup** (1 minute)
   ```bash
   ./scripts/deploy.sh
   ```

2. **Test Initial Function** (1 minute)
   ```bash
   aws lambda invoke --function-name codedeploy-lambda-demo response.json
   cat response.json
   ```

3. **Deploy Update via CodeDeploy** (2 minutes)
   ```bash
   ./scripts/update.sh
   ```

4. **Verify Update** (30 seconds)
   ```bash
   aws lambda invoke --function-name codedeploy-lambda-demo:live response.json
   cat response.json
   ```

5. **Cleanup** (30 seconds)
   ```bash
   ./scripts/cleanup.sh
   ```

## What This Demo Shows

- Initial Lambda function deployment with Terraform
- CodeDeploy application and deployment group setup
- Automated deployment of Lambda function updates via CodeDeploy
- Blue/green deployment strategy for Lambda
- Rollback capabilities with CodeDeploy

## Key AWS Services Used

- AWS Lambda (functions, versions, aliases)
- AWS CodeDeploy (applications, deployment groups)
- AWS IAM (roles and policies)
- AWS S3 (for deployment artifacts)

## Demo Flow

1. Terraform creates the initial Lambda function (v1) with "Hello World" response
2. CodeDeploy application and deployment group are configured
3. Updated Lambda code (v2) is packaged and deployed via CodeDeploy
4. CodeDeploy performs blue/green deployment with automatic rollback capability
5. Function now returns "Hello from CodeDeploy!" response via the alias

## Key Concepts Demonstrated

- **AWS CodeDeploy**: Automated deployment service for Lambda functions
- **Blue/Green Deployments**: CodeDeploy manages traffic shifting between versions
- **AppSpec Configuration**: Defines deployment behavior and target versions
- **Rollback Capability**: Automatic rollback on deployment failures
- **Zero Downtime**: CodeDeploy ensures no service interruption

## Notes

- The demo uses a simple Node.js Lambda function
- CodeDeploy uses "AllAtOnce" deployment configuration for speed
- All resources are tagged for easy identification and cleanup
- S3 bucket stores deployment artifacts with versioning enabled
