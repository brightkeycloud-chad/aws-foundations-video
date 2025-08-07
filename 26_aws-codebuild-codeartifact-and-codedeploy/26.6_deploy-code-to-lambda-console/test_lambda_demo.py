#!/usr/bin/env python3
"""
Test script to validate the Lambda demonstration instructions.
This script uses AWS CLI and boto3 to programmatically test the Lambda function
creation, deployment, and testing process described in the README.
"""

import json
import time
import boto3
import sys
from botocore.exceptions import ClientError

# Configuration
FUNCTION_NAME = "myLambdaFunction"
RUNTIME_PYTHON = "python3.13"
RUNTIME_NODEJS = "nodejs22.x"
TEST_EVENT = {
    "length": 6,
    "width": 7
}
EXPECTED_RESULT = 42

# Python Lambda function code
PYTHON_CODE = '''import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    
    # Get the length and width parameters from the event object
    length = event['length']
    width = event['width']
    
    area = calculate_area(length, width)
    print(f"The area is {area}")
        
    logger.info(f"CloudWatch logs group: {context.log_group_name}")
    
    # return the calculated area as a JSON string
    data = {"area": area}
    return json.dumps(data)
    
def calculate_area(length, width):
    return length*width
'''

# Node.js Lambda function code
NODEJS_CODE = '''export const handler = async (event, context) => {
  
  const length = event.length;
  const width = event.width;
  let area = calculateArea(length, width);
  console.log(`The area is ${area}`);
        
  console.log('CloudWatch log group: ', context.logGroupName);
  
  let data = {
    "area": area,
  };
    return JSON.stringify(data);
    
  function calculateArea(length, width) {
    return length * width;
  }
};
'''

def create_lambda_client():
    """Create and return a Lambda client."""
    try:
        return boto3.client('lambda')
    except Exception as e:
        print(f"Error creating Lambda client: {e}")
        return None

def create_iam_role(iam_client):
    """Create an IAM role for Lambda execution."""
    trust_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    
    role_name = f"{FUNCTION_NAME}-role"
    
    try:
        # Create the role
        response = iam_client.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(trust_policy),
            Description='Lambda execution role for demonstration'
        )
        
        # Attach the basic execution policy
        iam_client.attach_role_policy(
            RoleName=role_name,
            PolicyArn='arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
        )
        
        # Wait for role to be available
        time.sleep(10)
        
        return response['Role']['Arn']
    except ClientError as e:
        if e.response['Error']['Code'] == 'EntityAlreadyExists':
            # Role already exists, get its ARN
            response = iam_client.get_role(RoleName=role_name)
            return response['Role']['Arn']
        else:
            print(f"Error creating IAM role: {e}")
            return None

def test_lambda_function(runtime="python"):
    """Test the Lambda function creation and execution process."""
    print(f"Testing Lambda function with {runtime} runtime...")
    
    lambda_client = create_lambda_client()
    if not lambda_client:
        return False
    
    iam_client = boto3.client('iam')
    
    try:
        # Step 1: Create IAM role
        print("Creating IAM execution role...")
        role_arn = create_iam_role(iam_client)
        if not role_arn:
            return False
        print(f"✓ IAM role created: {role_arn}")
        
        # Step 2: Create Lambda function
        print("Creating Lambda function...")
        
        if runtime == "python":
            function_code = PYTHON_CODE
            runtime_version = RUNTIME_PYTHON
            handler = "lambda_function.lambda_handler"
        else:
            function_code = NODEJS_CODE
            runtime_version = RUNTIME_NODEJS
            handler = "index.handler"
        
        # Create zip file content
        import zipfile
        import io
        
        zip_buffer = io.BytesIO()
        with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
            if runtime == "python":
                zip_file.writestr("lambda_function.py", function_code)
            else:
                zip_file.writestr("index.mjs", function_code)
        
        zip_buffer.seek(0)
        
        response = lambda_client.create_function(
            FunctionName=FUNCTION_NAME,
            Runtime=runtime_version,
            Role=role_arn,
            Handler=handler,
            Code={'ZipFile': zip_buffer.read()},
            Description='Test function for demonstration',
            Timeout=30,
            MemorySize=128
        )
        print(f"✓ Lambda function created: {response['FunctionArn']}")
        
        # Step 3: Wait for function to be active
        print("Waiting for function to be active...")
        waiter = lambda_client.get_waiter('function_active')
        waiter.wait(FunctionName=FUNCTION_NAME)
        print("✓ Function is active")
        
        # Step 4: Test the function
        print("Testing function with test event...")
        response = lambda_client.invoke(
            FunctionName=FUNCTION_NAME,
            InvocationType='RequestResponse',
            Payload=json.dumps(TEST_EVENT)
        )
        
        # Parse response
        payload = response['Payload'].read().decode('utf-8')
        result = json.loads(payload)
        
        if isinstance(result, str):
            result = json.loads(result)
        
        print(f"Function response: {result}")
        
        # Verify result
        if result.get('area') == EXPECTED_RESULT:
            print("✓ Function returned correct result!")
            return True
        else:
            print(f"✗ Function returned incorrect result. Expected: {EXPECTED_RESULT}, Got: {result.get('area')}")
            return False
            
    except ClientError as e:
        print(f"AWS Error: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error: {e}")
        return False
    finally:
        # Cleanup
        cleanup_resources(lambda_client, iam_client)

def cleanup_resources(lambda_client, iam_client):
    """Clean up created resources."""
    print("\nCleaning up resources...")
    
    try:
        # Delete Lambda function
        lambda_client.delete_function(FunctionName=FUNCTION_NAME)
        print("✓ Lambda function deleted")
    except ClientError as e:
        if e.response['Error']['Code'] != 'ResourceNotFoundException':
            print(f"Error deleting Lambda function: {e}")
    
    try:
        # Detach policy and delete IAM role
        role_name = f"{FUNCTION_NAME}-role"
        iam_client.detach_role_policy(
            RoleName=role_name,
            PolicyArn='arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
        )
        iam_client.delete_role(RoleName=role_name)
        print("✓ IAM role deleted")
    except ClientError as e:
        if e.response['Error']['Code'] != 'NoSuchEntity':
            print(f"Error deleting IAM role: {e}")

def main():
    """Main function to run tests."""
    print("Lambda Demonstration Test Script")
    print("=" * 40)
    
    # Test both runtimes
    runtimes = ["python", "nodejs"]
    results = {}
    
    for runtime in runtimes:
        print(f"\n--- Testing {runtime.upper()} Runtime ---")
        results[runtime] = test_lambda_function(runtime)
        time.sleep(5)  # Brief pause between tests
    
    # Summary
    print("\n" + "=" * 40)
    print("TEST SUMMARY")
    print("=" * 40)
    
    all_passed = True
    for runtime, passed in results.items():
        status = "PASS" if passed else "FAIL"
        print(f"{runtime.upper()} Runtime: {status}")
        if not passed:
            all_passed = False
    
    if all_passed:
        print("\n✓ All tests passed! The demonstration instructions are valid.")
        sys.exit(0)
    else:
        print("\n✗ Some tests failed. Please review the demonstration instructions.")
        sys.exit(1)

if __name__ == "__main__":
    main()
