#!/usr/bin/env python3
import boto3
import json
import os
import sys
from datetime import datetime

def assume_role(role_arn, session_name=None, duration=3600):
    """Assume an IAM role and return temporary credentials"""
    
    if not session_name:
        session_name = f"python-session-{int(datetime.now().timestamp())}"
    
    try:
        # Create STS client
        sts_client = boto3.client('sts')
        
        # Assume the role
        response = sts_client.assume_role(
            RoleArn=role_arn,
            RoleSessionName=session_name,
            DurationSeconds=duration
        )
        
        credentials = response['Credentials']
        
        # Set environment variables
        os.environ['AWS_ACCESS_KEY_ID'] = credentials['AccessKeyId']
        os.environ['AWS_SECRET_ACCESS_KEY'] = credentials['SecretAccessKey']
        os.environ['AWS_SESSION_TOKEN'] = credentials['SessionToken']
        
        print(f"✅ Successfully assumed role: {role_arn}")
        print(f"Session expires: {credentials['Expiration']}")
        
        # Verify the assumption
        identity = sts_client.get_caller_identity()
        print(f"Current identity: {identity['Arn']}")
        
        return credentials
        
    except Exception as e:
        print(f"❌ Failed to assume role: {e}")
        return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 assume_role.py <role-arn> [session-name] [duration]")
        sys.exit(1)
    
    role_arn = sys.argv[1]
    session_name = sys.argv[2] if len(sys.argv) > 2 else None
    duration = int(sys.argv[3]) if len(sys.argv) > 3 else 3600
    
    assume_role(role_arn, session_name, duration)