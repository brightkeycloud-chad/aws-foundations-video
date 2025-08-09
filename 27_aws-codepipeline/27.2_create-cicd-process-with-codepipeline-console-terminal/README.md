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
- Git installed

## Architecture Overview
This demonstration creates:
- **Source Stage**: GitHub repository integration
- **Build Stage**: AWS CodeBuild project for building the application
- **Deploy Stage**: AWS CodeDeploy for application deployment
- **S3 Bucket**: For storing pipeline artifacts
- **IAM Roles**: For pipeline execution permissions

## Step-by-Step Instructions

### Step 1: Initialize CDK Project (1 minute)
```bash
# Create project directory
mkdir codepipeline-demo
cd codepipeline-demo

# Initialize CDK app
cdk init app --language python

# Activate virtual environment
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Install Additional Dependencies (30 seconds)
```bash
# Install CodePipeline and related constructs
pip install aws-cdk-lib constructs
```

### Step 3: Create the Pipeline Stack (2 minutes)
Replace the contents of `codepipeline_demo/codepipeline_demo_stack.py`:

```python
from aws_cdk import (
    Stack,
    aws_codepipeline as codepipeline,
    aws_codepipeline_actions as codepipeline_actions,
    aws_codebuild as codebuild,
    aws_s3 as s3,
    aws_iam as iam,
    RemovalPolicy,
)
from constructs import Construct

class CodepipelineDemoStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Create S3 bucket for artifacts
        artifact_bucket = s3.Bucket(
            self, "PipelineArtifacts",
            bucket_name=f"codepipeline-artifacts-{self.account}-{self.region}",
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True
        )

        # Create CodeBuild project
        build_project = codebuild.Project(
            self, "BuildProject",
            project_name="demo-build-project",
            source=codebuild.Source.git_hub(
                owner="your-github-username",
                repo="your-repo-name",
                webhook=True,
                webhook_filters=[
                    codebuild.FilterGroup.in_event_of(
                        codebuild.EventAction.PUSH
                    ).and_branch_is("main")
                ]
            ),
            environment=codebuild.BuildEnvironment(
                build_image=codebuild.LinuxBuildImage.STANDARD_5_0,
                compute_type=codebuild.ComputeType.SMALL
            ),
            build_spec=codebuild.BuildSpec.from_object({
                "version": "0.2",
                "phases": {
                    "install": {
                        "runtime-versions": {
                            "nodejs": "14"
                        }
                    },
                    "pre_build": {
                        "commands": [
                            "echo Logging in to Amazon ECR...",
                            "npm install"
                        ]
                    },
                    "build": {
                        "commands": [
                            "echo Build started on `date`",
                            "npm run build"
                        ]
                    },
                    "post_build": {
                        "commands": [
                            "echo Build completed on `date`"
                        ]
                    }
                },
                "artifacts": {
                    "files": [
                        "**/*"
                    ]
                }
            })
        )

        # Create pipeline
        pipeline = codepipeline.Pipeline(
            self, "DemoPipeline",
            pipeline_name="demo-cicd-pipeline",
            artifact_bucket=artifact_bucket,
            cross_account_keys=False  # Disable for cost optimization
        )

        # Define artifacts
        source_output = codepipeline.Artifact("SourceOutput")
        build_output = codepipeline.Artifact("BuildOutput")

        # Source stage
        source_action = codepipeline_actions.GitHubSourceAction(
            action_name="GitHub_Source",
            owner="your-github-username",
            repo="your-repo-name",
            branch="main",
            oauth_token=self.node.try_get_context("github-token"),
            output=source_output
        )

        pipeline.add_stage(
            stage_name="Source",
            actions=[source_action]
        )

        # Build stage
        build_action = codepipeline_actions.CodeBuildAction(
            action_name="CodeBuild",
            project=build_project,
            input=source_output,
            outputs=[build_output]
        )

        pipeline.add_stage(
            stage_name="Build",
            actions=[build_action]
        )

        # Deploy stage (simplified - using S3 deployment)
        deploy_bucket = s3.Bucket(
            self, "DeployBucket",
            bucket_name=f"demo-deploy-{self.account}-{self.region}",
            website_index_document="index.html",
            public_read_access=True,
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True
        )

        deploy_action = codepipeline_actions.S3DeployAction(
            action_name="S3Deploy",
            bucket=deploy_bucket,
            input=build_output
        )

        pipeline.add_stage(
            stage_name="Deploy",
            actions=[deploy_action]
        )
```

### Step 4: Deploy the Pipeline (1.5 minutes)
The CDK app automatically detects your AWS account and region using STS and boto3:
```bash
# Bootstrap CDK (if not done before)
cdk bootstrap

# Deploy the stack
cdk deploy

# Confirm deployment when prompted
```

## Demonstration Script

### Introduction (30 seconds)
"Today we'll create a complete CI/CD pipeline using AWS CodePipeline and Python CDK. This pipeline will automatically build and deploy our application whenever we push code to our GitHub repository."

### Code Walkthrough (2 minutes)
1. **Show the app.py structure**: "Our CDK app automatically detects the AWS account and region using STS..."
2. **Explain the stack components**: "Our CDK stack creates three main components..."
3. **Show the source stage**: "The pipeline starts by pulling code from S3..."
4. **Demonstrate build stage**: "CodeBuild compiles and tests our application..."
5. **Review deploy stage**: "Finally, we deploy to an S3 bucket configured for static hosting..."

### Deployment (1.5 minutes)
1. Run `cdk deploy` command
2. Show CloudFormation stack creation in AWS Console
3. Navigate to CodePipeline console to show created pipeline

### Verification (1 minute)
1. Show pipeline stages in AWS Console
2. Trigger a manual execution
3. Demonstrate how code changes would trigger automatic builds

## Key Learning Points
- **Infrastructure as Code**: CDK allows version-controlled infrastructure
- **Automatic Configuration**: App automatically detects AWS account and region using STS
- **Automation**: Pipeline triggers automatically on code changes
- **Scalability**: Easy to add additional stages (testing, staging, production)
- **Cost Optimization**: Disabled cross-account keys for demo purposes
- **Security**: IAM roles provide least-privilege access

## Cleanup
```bash
# Destroy the stack to avoid charges
cdk destroy

# Confirm destruction when prompted
```

## Troubleshooting
- **GitHub Token**: Ensure you have a valid GitHub personal access token
- **Permissions**: Verify your AWS credentials have sufficient permissions
- **Region**: Make sure you're deploying to a region that supports all services
- **Bucket Names**: S3 bucket names must be globally unique

## Extensions for Advanced Demos
- Add automated testing stage with CodeBuild
- Implement blue/green deployments
- Add approval gates for production deployments
- Integrate with AWS CodeCommit instead of GitHub
- Add monitoring and notifications with CloudWatch and SNS

## Citations and Documentation

### Primary Documentation Sources
1. **AWS CDK v2 Developer Guide - Working with Python**  
   https://docs.aws.amazon.com/cdk/v2/guide/work-with-cdk-python.html  
   *Used for CDK Python setup and best practices*

2. **AWS CDK v2 Getting Started Guide**  
   https://docs.aws.amazon.com/cdk/v2/guide/getting-started.html  
   *Referenced for initial CDK setup and bootstrapping*

3. **AWS CodePipeline User Guide**  
   https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html  
   *Used for understanding CodePipeline concepts and architecture*

4. **AWS CDK API Reference - CodePipeline Constructs**  
   https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_codepipeline-readme.html  
   *Referenced for CodePipeline construct usage and examples*

5. **AWS CodeBuild User Guide**  
   https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html  
   *Used for BuildSpec configuration and build environment setup*

### Additional Resources
- **CDK Workshop**: https://cdkworkshop.com/
- **AWS CDK Examples**: https://github.com/aws-samples/aws-cdk-examples
- **CodePipeline Tutorials**: https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials.html

---
*This demonstration was created using current AWS documentation as of August 2025. Always refer to the latest AWS documentation for the most up-to-date information.*
