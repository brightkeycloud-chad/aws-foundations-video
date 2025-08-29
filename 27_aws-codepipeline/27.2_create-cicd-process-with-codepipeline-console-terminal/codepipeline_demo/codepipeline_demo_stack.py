from aws_cdk import (
    Stack,
    aws_codepipeline as codepipeline,
    aws_codepipeline_actions as codepipeline_actions,
    aws_codebuild as codebuild,
    aws_s3 as s3,
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
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True
        )

        # Create S3 bucket for source code
        source_bucket = s3.Bucket(
            self, "SourceBucket",
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True
        )

        # Create CodeBuild project
        build_project = codebuild.Project(
            self, "BuildProject",
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
                            "echo Build started on `date`"
                        ]
                    },
                    "build": {
                        "commands": [
                            "echo Building the application",
                            "ls -la"
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
            artifact_bucket=artifact_bucket
        )

        # Define artifacts
        source_output = codepipeline.Artifact("SourceOutput")
        build_output = codepipeline.Artifact("BuildOutput")

        # Source stage - S3 source
        source_action = codepipeline_actions.S3SourceAction(
            action_name="S3_Source",
            bucket=source_bucket,
            bucket_key="source.zip",
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

        # Deploy stage - S3 static website hosting
        deploy_bucket = s3.Bucket(
            self, "DeployBucket",
            website_index_document="index.html",
            website_error_document="error.html",
            public_read_access=True,
            block_public_access=s3.BlockPublicAccess.BLOCK_ACLS,
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

        # Output the website URL
        CfnOutput(
            self, "WebsiteURL",
            value=deploy_bucket.bucket_website_url,
            description="URL of the deployed website"
        )

        # Output the source bucket name for the deploy script
        CfnOutput(
            self, "SourceBucketName",
            value=source_bucket.bucket_name,
            description="Name of the source S3 bucket"
        )
