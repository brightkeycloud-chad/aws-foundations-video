import boto3
from botocore.exceptions import ClientError

def demo_aws_services():
    """Demonstrate connecting to multiple AWS services"""
    
    print("=== AWS Services Demo ===\n")
    
    # S3 Service
    print("1. S3 Service:")
    try:
        s3 = boto3.client('s3')
        buckets = s3.list_buckets()
        print(f"   Found {len(buckets.get('Buckets', []))} S3 buckets")
    except Exception as e:
        print(f"   S3 Error: {e}")
    
    # EC2 Service
    print("\n2. EC2 Service:")
    try:
        ec2 = boto3.client('ec2')
        regions = ec2.describe_regions()
        print(f"   Available regions: {len(regions['Regions'])}")
        print(f"   Current region: {ec2.meta.region_name}")
    except Exception as e:
        print(f"   EC2 Error: {e}")
    
    # IAM Service
    print("\n3. IAM Service:")
    try:
        iam = boto3.client('iam')
        user = iam.get_user()
        print(f"   Current user: {user['User']['UserName']}")
    except Exception as e:
        print(f"   IAM Error: {e}")
    
    # STS Service (always works if credentials are valid)
    print("\n4. STS Service:")
    try:
        sts = boto3.client('sts')
        identity = sts.get_caller_identity()
        print(f"   Account ID: {identity['Account']}")
        print(f"   User ARN: {identity['Arn']}")
    except Exception as e:
        print(f"   STS Error: {e}")

if __name__ == "__main__":
    demo_aws_services()