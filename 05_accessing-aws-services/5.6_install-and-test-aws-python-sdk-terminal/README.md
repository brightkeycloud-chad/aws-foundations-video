# AWS Python SDK (Boto3) Installation and Testing Demonstration

## Overview
This 5-minute demonstration shows how to install the AWS SDK for Python (Boto3) and create simple scripts to interact with AWS services. Boto3 is the official AWS SDK for Python, allowing developers to write software that uses AWS services.

## Prerequisites
- Python 3.7 or later installed
- pip (Python package installer)
- AWS credentials configured (via AWS CLI, environment variables, or IAM roles)
- Terminal/command line access
- Basic Python knowledge

## Demonstration Steps (5 minutes)

### Step 1: Verify Python Installation (30 seconds)
1. Check Python version:
   ```bash
   python3 --version
   # or
   python --version
   ```
2. Check pip installation:
   ```bash
   pip3 --version
   # or  
   pip --version
   ```

### Step 2: Install Boto3 (1 minute)
1. Install Boto3 using pip:
   ```bash
   pip3 install boto3
   # or for user-specific installation
   pip3 install --user boto3
   ```

2. Verify installation:
   ```bash
   python3 -c "import boto3; print(boto3.__version__)"
   ```

3. Optional: Install with specific version:
   ```bash
   pip3 install boto3==1.34.0
   ```

### Step 3: Create a Simple S3 Test Script (1.5 minutes)
1. Create a test directory and file:
   ```bash
   mkdir boto3-demo
   cd boto3-demo
   ```

2. Create a simple S3 listing script:
   ```bash
   cat > list_buckets.py << 'EOF'
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
   EOF
   ```

### Step 4: Test AWS Credentials and Run Script (1 minute)
1. Test the S3 script:
   ```bash
   python3 list_buckets.py
   ```

2. Check AWS credentials configuration:
   ```bash
   python3 -c "
   import boto3
   try:
       sts = boto3.client('sts')
       identity = sts.get_caller_identity()
       print(f'Account: {identity[\"Account\"]}')
       print(f'User/Role: {identity[\"Arn\"]}')
   except Exception as e:
       print(f'Credential error: {e}')
   "
   ```

### Step 5: Create an EC2 Instance Listing Script (1 minute)
1. Create an EC2 script:
   ```bash
   cat > list_instances.py << 'EOF'
   import boto3
   from botocore.exceptions import ClientError

   def list_ec2_instances():
       """List EC2 instances in the default region"""
       try:
           # Create EC2 client
           ec2_client = boto3.client('ec2')
           
           print("Listing EC2 instances:")
           
           # Describe instances
           response = ec2_client.describe_instances()
           
           instance_count = 0
           for reservation in response['Reservations']:
               for instance in reservation['Instances']:
                   instance_count += 1
                   instance_id = instance['InstanceId']
                   instance_type = instance['InstanceType']
                   state = instance['State']['Name']
                   
                   # Get instance name from tags
                   name = 'N/A'
                   if 'Tags' in instance:
                       for tag in instance['Tags']:
                           if tag['Key'] == 'Name':
                               name = tag['Value']
                               break
                   
                   print(f"  - {instance_id} ({name}) - {instance_type} - {state}")
           
           if instance_count == 0:
               print("  No instances found!")
           else:
               print(f"Total instances: {instance_count}")
               
       except ClientError as e:
           print(f"Error: {e}")
       except Exception as e:
           print(f"Unexpected error: {e}")

   if __name__ == "__main__":
       list_ec2_instances()
   EOF
   ```

2. Run the EC2 script:
   ```bash
   python3 list_instances.py
   ```

### Step 6: Demonstrate Different AWS Service Clients (1 minute)
1. Create a multi-service demo:
   ```bash
   cat > aws_services_demo.py << 'EOF'
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
   EOF
   ```

2. Run the multi-service demo:
   ```bash
   python3 aws_services_demo.py
   ```

## Key Boto3 Concepts

### Client vs Resource
- **Client**: Low-level interface, maps 1:1 with AWS service APIs
- **Resource**: Higher-level, object-oriented interface

```python
# Client example
s3_client = boto3.client('s3')
response = s3_client.list_buckets()

# Resource example  
s3_resource = boto3.resource('s3')
for bucket in s3_resource.buckets.all():
    print(bucket.name)
```

### Session Management
```python
# Default session
client = boto3.client('s3')

# Custom session with specific profile
session = boto3.Session(profile_name='production')
client = session.client('s3')

# Custom session with explicit credentials
session = boto3.Session(
    aws_access_key_id='YOUR_ACCESS_KEY',
    aws_secret_access_key='YOUR_SECRET_KEY',
    region_name='us-west-2'
)
```

### Error Handling
```python
from botocore.exceptions import ClientError, NoCredentialsError

try:
    s3 = boto3.client('s3')
    response = s3.list_buckets()
except NoCredentialsError:
    print("Credentials not available")
except ClientError as e:
    error_code = e.response['Error']['Code']
    if error_code == 'AccessDenied':
        print("Access denied")
    else:
        print(f"Client error: {e}")
```

## Best Practices

### 1. Credential Management
- Use IAM roles when running on EC2
- Use AWS profiles for local development
- Never hardcode credentials in source code
- Use environment variables for CI/CD

### 2. Region Configuration
```python
# Explicit region
client = boto3.client('s3', region_name='us-west-2')

# From environment variable
import os
region = os.environ.get('AWS_DEFAULT_REGION', 'us-east-1')
client = boto3.client('s3', region_name=region)
```

### 3. Resource Management
```python
# Use context managers when possible
import boto3

# For file operations
s3 = boto3.client('s3')
with open('file.txt', 'rb') as f:
    s3.upload_fileobj(f, 'bucket-name', 'key')
```

### 4. Pagination
```python
# Handle paginated responses
s3 = boto3.client('s3')
paginator = s3.get_paginator('list_objects_v2')

for page in paginator.paginate(Bucket='my-bucket'):
    for obj in page.get('Contents', []):
        print(obj['Key'])
```

## Common Installation Issues

### 1. Permission Errors
```bash
# Use --user flag
pip3 install --user boto3

# Or use virtual environment
python3 -m venv aws-env
source aws-env/bin/activate  # On Windows: aws-env\Scripts\activate
pip install boto3
```

### 2. SSL Certificate Issues
```bash
# For corporate networks
pip3 install --trusted-host pypi.org --trusted-host pypi.python.org boto3
```

### 3. Version Conflicts
```bash
# Check installed version
pip3 show boto3

# Upgrade to latest
pip3 install --upgrade boto3

# Install specific version
pip3 install boto3==1.34.0
```

## Testing Your Installation

### Quick Test Script
```python
import boto3
import sys

def test_boto3():
    print(f"Boto3 version: {boto3.__version__}")
    print(f"Python version: {sys.version}")
    
    try:
        sts = boto3.client('sts')
        identity = sts.get_caller_identity()
        print("✅ AWS credentials are working")
        print(f"Account: {identity['Account']}")
        return True
    except Exception as e:
        print("❌ AWS credentials issue:")
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    test_boto3()
```

## Documentation References
1. [Amazon S3 examples using SDK for Python (Boto3)](https://docs.aws.amazon.com/code-library/latest/ug/python_3_s3_code_examples.html) - S3 code examples and patterns
2. [Amazon EC2 examples using SDK for Python (Boto3)](https://docs.aws.amazon.com/code-library/latest/ug/python_3_ec2_code_examples.html) - EC2 code examples
3. [DynamoDB examples using SDK for Python (Boto3)](https://docs.aws.amazon.com/code-library/latest/ug/python_3_dynamodb_code_examples.html) - DynamoDB code examples
4. [AWS SDK for Python (Boto3) Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) - Complete API reference
5. [AWS Doc SDK Examples Repository](https://github.com/awsdocs/aws-doc-sdk-examples/tree/main/python) - Complete code examples on GitHub

## Additional Resources
- [Boto3 GitHub Repository](https://github.com/boto/boto3) - Source code and issues
- [AWS SDK for Python Developer Guide](https://aws.amazon.com/sdk-for-python/) - Official SDK page
- [Boto3 Configuration Guide](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/configuration.html) - Advanced configuration options
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) - Credential setup guide
