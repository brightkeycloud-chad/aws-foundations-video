import boto3
from botocore.exceptions import ClientError, NoCredentialsError

def list_s3_buckets():
    """List all S3 buckets in the account"""
    try:
        # Create S3 client
        s3_client = boto3.client('s3')
        
        print("Hello, Amazon S3! Let's list your buckets:")
        
        # List buckets
        response = s3_client.list_buckets()
        
        if 'Buckets' in response and response['Buckets']:
            for bucket in response['Buckets']:
                print(f"  - {bucket['Name']} (Created: {bucket['CreationDate']})")
        else:
            print("  No buckets found!")
            
    except NoCredentialsError:
        print("Error: AWS credentials not found. Please configure your credentials.")
    except ClientError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")

if __name__ == "__main__":
    list_s3_buckets()