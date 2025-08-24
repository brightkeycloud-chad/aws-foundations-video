import boto3
from botocore.exceptions import ClientError, NoCredentialsError

def check_aws_credentials():
    """Check AWS credentials configuration"""
    try:
        sts = boto3.client('sts')
        identity = sts.get_caller_identity()
        print(f'Account: {identity["Account"]}')
        print(f'User/Role: {identity["Arn"]}')
        return True
    except NoCredentialsError:
        print('Credential error: AWS credentials not found. Please configure your credentials.')
        return False
    except Exception as e:
        print(f'Credential error: {e}')
        return False

if __name__ == "__main__":
    check_aws_credentials()