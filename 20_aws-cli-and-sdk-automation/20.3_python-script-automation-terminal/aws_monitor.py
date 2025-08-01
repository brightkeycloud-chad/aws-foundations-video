#!/usr/bin/env python3
"""
Simple AWS Resource Monitor - Python equivalent of bash version
Demonstrates basic Python automation with comparison to bash approach
"""

import boto3
from datetime import datetime
from botocore.exceptions import ClientError

def monitor_resources():
    """
    Monitor AWS resources across services
    PYTHON ADVANTAGE: Better error handling and data structure manipulation
    """
    try:
        # Initialize clients - Python handles this more elegantly than bash
        s3 = boto3.client('s3')
        ec2 = boto3.client('ec2')
        iam = boto3.client('iam')
        
        print("=== AWS Resource Monitor (Python) ===")
        print(f"Timestamp: {datetime.now()}")
        print()
        
        # S3 Buckets - Python makes JSON parsing much easier than bash
        try:
            buckets = s3.list_buckets()['Buckets']
            print(f"S3 Buckets: {len(buckets)}")
            
            # Python advantage: Easy to show additional details
            if buckets:
                print("  Recent buckets:")
                for bucket in sorted(buckets, key=lambda x: x['CreationDate'], reverse=True)[:3]:
                    print(f"    - {bucket['Name']} (Created: {bucket['CreationDate'].strftime('%Y-%m-%d')})")
        except ClientError as e:
            print(f"S3 Buckets: Error - {e}")
        
        # EC2 Instances - Python's data processing is more robust than bash
        try:
            instances = ec2.describe_instances()
            total_instances = 0
            running_instances = 0
            instance_types = {}
            
            for reservation in instances['Reservations']:
                for instance in reservation['Instances']:
                    total_instances += 1
                    if instance['State']['Name'] == 'running':
                        running_instances += 1
                        # Python advantage: Easy data aggregation
                        instance_type = instance['InstanceType']
                        instance_types[instance_type] = instance_types.get(instance_type, 0) + 1
            
            print(f"EC2 Instances: {total_instances} total, {running_instances} running")
            
            # Python advantage: Easy to show breakdown by instance type
            if instance_types:
                print("  Running instance types:")
                for itype, count in sorted(instance_types.items()):
                    print(f"    - {itype}: {count}")
                    
        except ClientError as e:
            print(f"EC2 Instances: Error - {e}")
        
        # IAM Users - Python handles pagination automatically with boto3
        try:
            users = iam.list_users()['Users']
            print(f"IAM Users: {len(users)}")
            
            # Python advantage: Easy date calculations and filtering
            recent_users = [u for u in users if (datetime.now(u['CreateDate'].tzinfo) - u['CreateDate']).days < 30]
            if recent_users:
                print(f"  Users created in last 30 days: {len(recent_users)}")
                
        except ClientError as e:
            print(f"IAM Users: Error - {e}")
        
        print("=" * 40)
        
        # Python advantage: Return structured data for further processing
        return {
            'timestamp': datetime.now().isoformat(),
            's3_buckets': len(buckets) if 'buckets' in locals() else 0,
            'ec2_total': total_instances if 'total_instances' in locals() else 0,
            'ec2_running': running_instances if 'running_instances' in locals() else 0,
            'iam_users': len(users) if 'users' in locals() else 0
        }
        
    except Exception as e:
        print(f"Error monitoring resources: {e}")
        return None

if __name__ == "__main__":
    result = monitor_resources()
    if result:
        print("\n=== Structured Output (Python Advantage) ===")
        import json
        print(json.dumps(result, indent=2))
