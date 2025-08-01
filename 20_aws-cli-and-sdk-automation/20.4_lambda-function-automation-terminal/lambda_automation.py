#!/usr/bin/env python3
"""
AWS Lambda Function Automation Script
Demonstrates automated Lambda deployment, management, and monitoring
"""

import boto3
import json
import time
import zipfile
import os
import logging
from datetime import datetime
from botocore.exceptions import ClientError

class LambdaAutomation:
    """AWS Lambda automation and management class"""
    
    def __init__(self, region='us-east-1'):
        self.region = region
        self.timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        
        # Setup logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
        
        # Initialize AWS clients
        self.lambda_client = boto3.client('lambda', region_name=region)
        self.iam_client = boto3.client('iam')
        self.logs_client = boto3.client('logs', region_name=region)
        self.sts_client = boto3.client('sts')
        
        # Configuration
        self.function_name = f'demo-lambda-function-{self.timestamp}'
        self.role_name = f'demo-lambda-role-{self.timestamp}'
        
        self.verify_credentials()
    
    def verify_credentials(self):
        """Verify AWS credentials"""
        try:
            identity = self.sts_client.get_caller_identity()
            self.account_id = identity['Account']
            self.logger.info(f"Connected as: {identity['Arn']}")
        except ClientError as e:
            self.logger.error(f"Failed to verify credentials: {e}")
            raise
    
    def create_lambda_role(self):
        """Create IAM role for Lambda execution"""
        try:
            self.logger.info(f"Creating Lambda execution role: {self.role_name}")
            
            # Trust policy for Lambda
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
            
            # Create role
            response = self.iam_client.create_role(
                RoleName=self.role_name,
                AssumeRolePolicyDocument=json.dumps(trust_policy),
                Description='Demo Lambda execution role'
            )
            
            role_arn = response['Role']['Arn']
            
            # Attach basic Lambda execution policy
            self.iam_client.attach_role_policy(
                RoleName=self.role_name,
                PolicyArn='arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
            )
            
            # Attach S3 and DynamoDB permissions
            self.iam_client.attach_role_policy(
                RoleName=self.role_name,
                PolicyArn='arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess'
            )
            
            self.logger.info(f"Created role: {role_arn}")
            
            # Wait for role to be available
            time.sleep(10)
            
            return role_arn
            
        except ClientError as e:
            self.logger.error(f"Failed to create Lambda role: {e}")
            raise
    
    def create_deployment_package(self):
        """Create Lambda deployment package"""
        try:
            self.logger.info("Creating Lambda deployment package")
            
            zip_filename = f'{self.function_name}.zip'
            
            with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
                zipf.write('lambda_function.py')
            
            self.logger.info(f"Created deployment package: {zip_filename}")
            return zip_filename
            
        except Exception as e:
            self.logger.error(f"Failed to create deployment package: {e}")
            raise
    
    def deploy_lambda_function(self, role_arn, zip_filename):
        """Deploy Lambda function"""
        try:
            self.logger.info(f"Deploying Lambda function: {self.function_name}")
            
            with open(zip_filename, 'rb') as zip_file:
                zip_content = zip_file.read()
            
            response = self.lambda_client.create_function(
                FunctionName=self.function_name,
                Runtime='python3.9',
                Role=role_arn,
                Handler='lambda_function.lambda_handler',
                Code={'ZipFile': zip_content},
                Description='Demo Lambda function for automation',
                Timeout=30,
                MemorySize=128,
                Environment={
                    'Variables': {
                        'ENVIRONMENT': 'demo',
                        'TIMESTAMP': self.timestamp
                    }
                },
                Tags={
                    'Environment': 'Demo',
                    'CreatedBy': 'LambdaAutomation',
                    'Timestamp': self.timestamp
                }
            )
            
            function_arn = response['FunctionArn']
            self.logger.info(f"Deployed function: {function_arn}")
            
            return function_arn
            
        except ClientError as e:
            self.logger.error(f"Failed to deploy Lambda function: {e}")
            raise
    
    def test_lambda_function(self):
        """Test Lambda function with different event types"""
        try:
            self.logger.info("Testing Lambda function")
            
            # Test 1: Direct invocation
            test_event_1 = {
                'action': 'process_data',
                'data': {
                    'items': ['hello', 'world', 'lambda', 'automation']
                }
            }
            
            response_1 = self.lambda_client.invoke(
                FunctionName=self.function_name,
                InvocationType='RequestResponse',
                Payload=json.dumps(test_event_1)
            )
            
            result_1 = json.loads(response_1['Payload'].read())
            self.logger.info(f"Test 1 result: {result_1}")
            
            # Test 2: Health check
            test_event_2 = {
                'action': 'health_check'
            }
            
            response_2 = self.lambda_client.invoke(
                FunctionName=self.function_name,
                InvocationType='RequestResponse',
                Payload=json.dumps(test_event_2)
            )
            
            result_2 = json.loads(response_2['Payload'].read())
            self.logger.info(f"Test 2 result: {result_2}")
            
            return [result_1, result_2]
            
        except ClientError as e:
            self.logger.error(f"Failed to test Lambda function: {e}")
            raise
    
    def monitor_lambda_function(self):
        """Monitor Lambda function metrics and logs"""
        try:
            self.logger.info("Monitoring Lambda function")
            
            # Get function configuration
            config = self.lambda_client.get_function(FunctionName=self.function_name)
            self.logger.info(f"Function state: {config['Configuration']['State']}")
            self.logger.info(f"Last modified: {config['Configuration']['LastModified']}")
            
            # Get recent log events
            log_group_name = f'/aws/lambda/{self.function_name}'
            
            try:
                log_streams = self.logs_client.describe_log_streams(
                    logGroupName=log_group_name,
                    orderBy='LastEventTime',
                    descending=True,
                    limit=1
                )
                
                if log_streams['logStreams']:
                    stream_name = log_streams['logStreams'][0]['logStreamName']
                    
                    events = self.logs_client.get_log_events(
                        logGroupName=log_group_name,
                        logStreamName=stream_name,
                        limit=10
                    )
                    
                    self.logger.info("Recent log events:")
                    for event in events['events'][-5:]:  # Show last 5 events
                        timestamp = datetime.fromtimestamp(event['timestamp'] / 1000)
                        self.logger.info(f"  {timestamp}: {event['message'].strip()}")
                
            except ClientError as e:
                self.logger.warning(f"Could not retrieve logs: {e}")
            
        except ClientError as e:
            self.logger.error(f"Failed to monitor Lambda function: {e}")
            raise
    
    def update_lambda_function(self):
        """Demonstrate function updates"""
        try:
            self.logger.info("Updating Lambda function configuration")
            
            # Update environment variables
            self.lambda_client.update_function_configuration(
                FunctionName=self.function_name,
                Environment={
                    'Variables': {
                        'ENVIRONMENT': 'demo',
                        'TIMESTAMP': self.timestamp,
                        'UPDATED_AT': datetime.utcnow().isoformat()
                    }
                },
                Description='Updated demo Lambda function'
            )
            
            self.logger.info("Function configuration updated")
            
        except ClientError as e:
            self.logger.error(f"Failed to update Lambda function: {e}")
            raise
    
    def cleanup_resources(self):
        """Clean up created resources"""
        try:
            self.logger.info("Starting cleanup")
            
            # Delete Lambda function
            try:
                self.lambda_client.delete_function(FunctionName=self.function_name)
                self.logger.info(f"Deleted Lambda function: {self.function_name}")
            except ClientError as e:
                self.logger.warning(f"Could not delete function: {e}")
            
            # Wait a moment for function deletion
            time.sleep(5)
            
            # Detach policies and delete role
            try:
                policies = [
                    'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole',
                    'arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess'
                ]
                
                for policy in policies:
                    try:
                        self.iam_client.detach_role_policy(
                            RoleName=self.role_name,
                            PolicyArn=policy
                        )
                    except ClientError:
                        pass
                
                self.iam_client.delete_role(RoleName=self.role_name)
                self.logger.info(f"Deleted IAM role: {self.role_name}")
                
            except ClientError as e:
                self.logger.warning(f"Could not delete role: {e}")
            
            # Clean up local files
            zip_filename = f'{self.function_name}.zip'
            if os.path.exists(zip_filename):
                os.remove(zip_filename)
                self.logger.info(f"Removed local file: {zip_filename}")
            
        except Exception as e:
            self.logger.error(f"Cleanup failed: {e}")

def main():
    """Main demonstration function"""
    try:
        # Initialize automation
        lambda_automation = LambdaAutomation()
        
        print("\n=== AWS Lambda Automation Demonstration ===")
        
        # Step 1: Create IAM role
        print("\n1. Creating IAM role for Lambda execution...")
        role_arn = lambda_automation.create_lambda_role()
        
        # Step 2: Create deployment package
        print("\n2. Creating deployment package...")
        zip_filename = lambda_automation.create_deployment_package()
        
        # Step 3: Deploy Lambda function
        print("\n3. Deploying Lambda function...")
        function_arn = lambda_automation.deploy_lambda_function(role_arn, zip_filename)
        
        # Step 4: Test Lambda function
        print("\n4. Testing Lambda function...")
        test_results = lambda_automation.test_lambda_function()
        
        # Step 5: Monitor function
        print("\n5. Monitoring Lambda function...")
        lambda_automation.monitor_lambda_function()
        
        # Step 6: Update function
        print("\n6. Updating Lambda function...")
        lambda_automation.update_lambda_function()
        
        print("\n=== Demonstration completed successfully! ===")
        
        # Cleanup prompt
        cleanup = input("\nDo you want to clean up resources? (y/N): ").lower()
        if cleanup == 'y':
            lambda_automation.cleanup_resources()
            print("Cleanup completed!")
        else:
            print(f"Resources left in place:")
            print(f"  - Lambda function: {lambda_automation.function_name}")
            print(f"  - IAM role: {lambda_automation.role_name}")
        
    except Exception as e:
        print(f"Demonstration failed: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
