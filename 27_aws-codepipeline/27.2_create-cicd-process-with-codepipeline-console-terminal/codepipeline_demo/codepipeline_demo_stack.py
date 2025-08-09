from aws_cdk import (
    Stack,
    Duration,
    aws_codepipeline as codepipeline,
    aws_codepipeline_actions as codepipeline_actions,
    aws_codebuild as codebuild,
    aws_s3 as s3,
    aws_iam as iam,
    RemovalPolicy,
    CfnOutput,
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
            auto_delete_objects=True,
            versioned=True,
            encryption=s3.BucketEncryption.S3_MANAGED
        )

        # Create CodeBuild project
        build_project = codebuild.Project(
            self, "BuildProject",
            project_name="demo-build-project",
            description="Demo build project for CodePipeline",
            environment=codebuild.BuildEnvironment(
                build_image=codebuild.LinuxBuildImage.STANDARD_5_0,
                compute_type=codebuild.ComputeType.SMALL,
                privileged=False
            ),
            build_spec=codebuild.BuildSpec.from_object({
                "version": "0.2",
                "phases": {
                    "install": {
                        "runtime-versions": {
                            "nodejs": "14"
                        },
                        "commands": [
                            "echo Installing dependencies..."
                        ]
                    },
                    "pre_build": {
                        "commands": [
                            "echo Pre-build phase started on `date`",
                            "echo Installing application dependencies...",
                            "# npm install  # Uncomment if you have a package.json"
                        ]
                    },
                    "build": {
                        "commands": [
                            "echo Build started on `date`",
                            "echo Creating a simple HTML file for demo...",
                            "mkdir -p dist",
                            "echo '<html><head><title>Demo App</title></head><body><h1>Hello from CodePipeline!</h1><p>Build completed at: '$(date)'</p></body></html>' > dist/index.html",
                            "echo Build completed successfully"
                        ]
                    },
                    "post_build": {
                        "commands": [
                            "echo Post-build phase completed on `date`"
                        ]
                    }
                },
                "artifacts": {
                    "files": [
                        "**/*"
                    ],
                    "base-directory": "dist"
                }
            }),
            timeout=Duration.minutes(10)
        )

        # Create pipeline
        pipeline = codepipeline.Pipeline(
            self, "DemoPipeline",
            pipeline_name="demo-cicd-pipeline",
            artifact_bucket=artifact_bucket,
            cross_account_keys=False,  # Disable for cost optimization in demo
            restart_execution_on_update=True
        )

        # Define artifacts
        source_output = codepipeline.Artifact("SourceOutput")
        build_output = codepipeline.Artifact("BuildOutput")

        # Source stage - Using S3 source for simplicity in demo
        # In real scenarios, you would use GitHub, CodeCommit, etc.
        source_bucket = s3.Bucket(
            self, "SourceBucket",
            bucket_name=f"demo-source-{self.account}-{self.region}",
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
            versioned=True
        )

        source_action = codepipeline_actions.S3SourceAction(
            action_name="S3_Source",
            bucket=source_bucket,
            bucket_key="source.zip",
            output=source_output,
            trigger=codepipeline_actions.S3Trigger.POLL  # Check for changes
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

        # Deploy stage - Deploy to S3 static website
        deploy_bucket = s3.Bucket(
            self, "DeployBucket",
            bucket_name=f"demo-deploy-{self.account}-{self.region}",
            website_index_document="index.html",
            website_error_document="error.html",
            public_read_access=True,
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
            block_public_access=s3.BlockPublicAccess(
                block_public_acls=False,
                block_public_policy=False,
                ignore_public_acls=False,
                restrict_public_buckets=False
            )
        )

        deploy_action = codepipeline_actions.S3DeployAction(
            action_name="S3Deploy",
            bucket=deploy_bucket,
            input=build_output,
            extract=True  # Extract the build artifacts
        )

        pipeline.add_stage(
            stage_name="Deploy",
            actions=[deploy_action]
        )

        # Outputs for easy reference
        CfnOutput(
            self, "PipelineName",
            value=pipeline.pipeline_name,
            description="Name of the CodePipeline"
        )

        CfnOutput(
            self, "SourceBucketName",
            value=source_bucket.bucket_name,
            description="S3 bucket for source code (upload source.zip here)"
        )

        CfnOutput(
            self, "WebsiteURL",
            value=deploy_bucket.bucket_website_url,
            description="URL of the deployed website"
        )

        CfnOutput(
            self, "ArtifactBucketName",
            value=artifact_bucket.bucket_name,
            description="S3 bucket for pipeline artifacts"
        )
