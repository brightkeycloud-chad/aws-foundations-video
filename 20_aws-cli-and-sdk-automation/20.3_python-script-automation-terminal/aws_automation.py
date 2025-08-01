#!/usr/bin/env python3
"""
AWS Resource Monitoring Script using Boto3
Demonstrates Python-based AWS resource management and monitoring
"""

import boto3
import json
import logging
from datetime import datetime
from botocore.exceptions import ClientError, NoCredentialsError

class AWSResourceMonitor:
    """AWS Resource Monitoring Class - Python equivalent of bash monitoring script"""
    
    def __init__(self, region='us-east-1'):
        """Initialize AWS clients"""
        self.region = region
        self.timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        
        # Setup logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
        
        try:
            # Initialize AWS clients
            self.s3_client = boto3.client('s3', region_name=region)
            self.ec2_client = boto3.client('ec2', region_name=region)
            self.iam_client = boto3.client('iam')
            self.sts_client = boto3.client('sts')
            
            # Verify credentials
            self.verify_credentials()
            
        except NoCredentialsError:
            self.logger.error("AWS credentials not found. Please configure AWS CLI.")
            raise
        except Exception as e:
            self.logger.error(f"Failed to initialize AWS clients: {str(e)}")
            raise
    
    def verify_credentials(self):
        """Verify AWS credentials and permissions"""
        try:
            identity = self.sts_client.get_caller_identity()
            self.account_id = identity['Account']
            self.user_arn = identity['Arn']
            
            self.logger.info(f"Connected as: {self.user_arn}")
            self.logger.info(f"Account ID: {self.account_id}")
            
        except ClientError as e:
            self.logger.error(f"Failed to verify credentials: {str(e)}")
            raise
    
    def get_resource_summary(self):
        """
        Get comprehensive resource summary
        PYTHON ADVANTAGE: Better error handling and data structure manipulation
        """
        try:
            self.logger.info("=== AWS Resource Summary ===")
            self.logger.info(f"Timestamp: {datetime.now()}")
            self.logger.info("")
            
            summary = {
                'timestamp': datetime.now().isoformat(),
                'account_id': self.account_id,
                'region': self.region
            }
            
            # S3 buckets - Python makes JSON parsing much easier
            try:
                s3_response = self.s3_client.list_buckets()
                bucket_count = len(s3_response['Buckets'])
                summary['s3_buckets'] = bucket_count
                self.logger.info(f"S3 Buckets: {bucket_count}")
            except ClientError as e:
                self.logger.warning(f"Could not retrieve S3 buckets: {e}")
                summary['s3_buckets'] = 'Error'
            
            # EC2 instances - Python's data processing is more robust
            try:
                ec2_response = self.ec2_client.describe_instances()
                
                total_instances = 0
                running_instances = 0
                
                for reservation in ec2_response['Reservations']:
                    for instance in reservation['Instances']:
                        total_instances += 1
                        if instance['State']['Name'] == 'running':
                            running_instances += 1
                
                summary['ec2_total'] = total_instances
                summary['ec2_running'] = running_instances
                self.logger.info(f"Running EC2 Instances: {running_instances}")
                
            except ClientError as e:
                self.logger.warning(f"Could not retrieve EC2 instances: {e}")
                summary['ec2_running'] = 'Error'
            
            # IAM users - Python handles pagination automatically with boto3
            try:
                iam_response = self.iam_client.list_users()
                user_count = len(iam_response['Users'])
                summary['iam_users'] = user_count
                self.logger.info(f"IAM Users: {user_count}")
            except ClientError as e:
                self.logger.warning(f"Could not retrieve IAM users: {e}")
                summary['iam_users'] = 'Error'
            
            self.logger.info("=" * 30)
            
            return summary
            
        except Exception as e:
            self.logger.error(f"Failed to generate resource summary: {str(e)}")
            raise

def main():
    """Main function to demonstrate resource monitoring"""
    try:
        # Initialize monitor
        monitor = AWSResourceMonitor()
        
        # Get and display resource summary
        summary = monitor.get_resource_summary()
        
        # Python advantage: Easy JSON serialization for further processing
        print("\n=== Summary as JSON (Python advantage) ===")
        print(json.dumps(summary, indent=2, default=str))
        
        return summary
        
    except Exception as e:
        print(f"Monitoring failed: {str(e)}")
        return None

if __name__ == "__main__":
    main()
