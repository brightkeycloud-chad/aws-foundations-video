# AWS Python SDK (Boto3) Installation and Testing Demonstration

## Overview
This 5-minute demonstration shows how to install the AWS SDK for Python (Boto3) using a virtual environment and run simple scripts to interact with AWS services. Boto3 is the official AWS SDK for Python, allowing developers to write software that uses AWS services.

## Prerequisites
- Python 3.7 or later installed
- pip (Python package installer)
- AWS credentials configured (via AWS CLI, environment variables, or IAM roles)
- Terminal/command line access
- Basic Python knowledge

## Quick Start

### Option 1: Automated Setup and Demo
```bash
# Set up virtual environment and install dependencies
./setup_venv.sh

# Run all demonstration scripts
./run_demo.sh
```

### Option 2: Manual Setup
```bash
# Create and activate virtual environment
python3 -m venv aws-sdk-env
source aws-sdk-env/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run individual scripts
python check_credentials.py
python list_buckets.py
python list_instances.py
python aws_services_demo.py
```

## Project Structure
```
.
├── README.md                 # This file
├── requirements.txt          # Python dependencies
├── setup_venv.sh            # Virtual environment setup script
├── run_demo.sh              # Demo runner script
├── check_credentials.py     # AWS credential verification
├── list_buckets.py          # S3 bucket listing demo
├── list_instances.py        # EC2 instance listing demo
└── aws_services_demo.py     # Multi-service demonstration
```

## Demonstration Steps (5 minutes)

### Step 1: Set Up Virtual Environment (1 minute)
1. Run the setup script:
   ```bash
   ./setup_venv.sh
   ```
   
2. Activate the virtual environment:
   ```bash
   source aws-sdk-env/bin/activate
   ```

3. Verify installation:
   ```bash
   python -c "import boto3; print(boto3.__version__)"
   ```

### Step 2: Test AWS Credentials (30 seconds)
1. Run the credential check script:
   ```bash
   python check_credentials.py
   ```

### Step 3: Run S3 Bucket Demo (1 minute)
1. Test the S3 script:
   ```bash
   python list_buckets.py
   ```

### Step 4: Run EC2 Instance Demo (1 minute)
1. Run the EC2 script:
   ```bash
   python list_instances.py
   ```

### Step 5: Run Multi-Service Demo (1.5 minutes)
1. Run the multi-service demo:
   ```bash
   python aws_services_demo.py
   ```

### Step 6: Run Complete Demo (30 seconds)
1. Run all demos in sequence:
   ```bash
   ./run_demo.sh
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
