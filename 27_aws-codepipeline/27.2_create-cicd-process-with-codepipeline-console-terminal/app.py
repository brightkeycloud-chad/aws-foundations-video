#!/usr/bin/env python3
import aws_cdk as cdk
import boto3
import os
from codepipeline_demo.codepipeline_demo_stack import CodepipelineDemoStack

def get_aws_environment():
    """
    Automatically determine AWS account ID and region using STS and boto3
    """
    try:
        # Get AWS account ID using STS
        sts_client = boto3.client('sts')
        account_id = sts_client.get_caller_identity()['Account']
        
        # Get region from multiple sources in order of preference
        region = None
        
        # 1. Check CDK context
        region = os.environ.get('CDK_DEFAULT_REGION')
        
        # 2. Check AWS CLI default region
        if not region:
            try:
                session = boto3.Session()
                region = session.region_name
            except:
                pass
        
        # 3. Check environment variable
        if not region:
            region = os.environ.get('AWS_DEFAULT_REGION')
        
        # 4. Fall back to us-east-1
        if not region:
            region = 'us-east-1'
            print(f"⚠️  No region found in AWS config, defaulting to {region}")
        
        print(f"🔧 Using AWS Account: {account_id}")
        print(f"🌍 Using AWS Region: {region}")
        
        return account_id, region
        
    except Exception as e:
        print(f"❌ Error getting AWS environment: {e}")
        print("💡 Make sure AWS CLI is configured with 'aws configure'")
        raise

# Get AWS environment automatically
account_id, region = get_aws_environment()

app = cdk.App()
CodepipelineDemoStack(app, "CodepipelineDemoStack",
    env=cdk.Environment(
        account=account_id,
        region=region
    )
)

app.synth()
