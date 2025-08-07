#!/usr/bin/env python3
"""
Cleanup script for Lambda demonstration resources.
This script removes any Lambda functions, IAM roles, and CloudWatch log groups
that may have been created during the demonstration or testing.
"""

import boto3
import json
import time
from botocore.exceptions import ClientError, NoCredentialsError

# Configuration
FUNCTION_NAME = "myLambdaFunction"
ROLE_NAME = f"{FUNCTION_NAME}-role"
LOG_GROUP_NAME = f"/aws/lambda/{FUNCTION_NAME}"

def create_clients():
    """Create AWS service clients."""
    try:
        lambda_client = boto3.client('lambda')
        iam_client = boto3.client('iam')
        logs_client = boto3.client('logs')
        return lambda_client, iam_client, logs_client
    except NoCredentialsError:
        print("❌ Error: AWS credentials not configured.")
        print("Please run 'aws configure' to set up your credentials.")
        return None, None, None
    except Exception as e:
        print(f"❌ Error creating AWS clients: {e}")
        return None, None, None

def cleanup_lambda_function(lambda_client):
    """Delete the Lambda function if it exists."""
    try:
        # Check if function exists
        lambda_client.get_function(FunctionName=FUNCTION_NAME)
        
        # Function exists, delete it
        lambda_client.delete_function(FunctionName=FUNCTION_NAME)
        print(f"✅ Deleted Lambda function: {FUNCTION_NAME}")
        return True
        
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print(f"ℹ️  Lambda function '{FUNCTION_NAME}' not found (already deleted or never created)")
            return False
        else:
            print(f"❌ Error deleting Lambda function: {e}")
            return False
    except Exception as e:
        print(f"❌ Unexpected error deleting Lambda function: {e}")
        return False

def cleanup_iam_role(iam_client):
    """Delete the IAM role and detach policies if it exists."""
    try:
        # Check if role exists
        iam_client.get_role(RoleName=ROLE_NAME)
        
        # Role exists, detach policies first
        try:
            # List attached policies
            response = iam_client.list_attached_role_policies(RoleName=ROLE_NAME)
            
            # Detach each policy
            for policy in response['AttachedPolicies']:
                iam_client.detach_role_policy(
                    RoleName=ROLE_NAME,
                    PolicyArn=policy['PolicyArn']
                )
                print(f"✅ Detached policy: {policy['PolicyName']}")
            
            # Delete the role
            iam_client.delete_role(RoleName=ROLE_NAME)
            print(f"✅ Deleted IAM role: {ROLE_NAME}")
            return True
            
        except ClientError as e:
            print(f"❌ Error managing IAM role policies: {e}")
            return False
            
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchEntity':
            print(f"ℹ️  IAM role '{ROLE_NAME}' not found (already deleted or never created)")
            return False
        else:
            print(f"❌ Error accessing IAM role: {e}")
            return False
    except Exception as e:
        print(f"❌ Unexpected error deleting IAM role: {e}")
        return False

def cleanup_cloudwatch_logs(logs_client):
    """Delete the CloudWatch log group if it exists."""
    try:
        # Check if log group exists
        response = logs_client.describe_log_groups(
            logGroupNamePrefix=LOG_GROUP_NAME,
            limit=1
        )
        
        if response['logGroups']:
            # Log group exists, delete it
            logs_client.delete_log_group(logGroupName=LOG_GROUP_NAME)
            print(f"✅ Deleted CloudWatch log group: {LOG_GROUP_NAME}")
            return True
        else:
            print(f"ℹ️  CloudWatch log group '{LOG_GROUP_NAME}' not found (already deleted or never created)")
            return False
            
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print(f"ℹ️  CloudWatch log group '{LOG_GROUP_NAME}' not found (already deleted or never created)")
            return False
        else:
            print(f"❌ Error deleting CloudWatch log group: {e}")
            return False
    except Exception as e:
        print(f"❌ Unexpected error deleting CloudWatch log group: {e}")
        return False

def list_related_resources(lambda_client, iam_client, logs_client):
    """List any resources that might be related to the demonstration."""
    print("\n🔍 Scanning for related resources...")
    
    found_resources = []
    
    # Check for Lambda functions with similar names
    try:
        response = lambda_client.list_functions()
        demo_functions = [f for f in response['Functions'] 
                         if 'lambda' in f['FunctionName'].lower() and 
                         ('demo' in f['FunctionName'].lower() or 
                          'test' in f['FunctionName'].lower() or
                          'my' in f['FunctionName'].lower())]
        
        if demo_functions:
            print(f"📋 Found {len(demo_functions)} potentially related Lambda functions:")
            for func in demo_functions:
                print(f"   - {func['FunctionName']} (Runtime: {func['Runtime']})")
                found_resources.append(('lambda', func['FunctionName']))
    except Exception as e:
        print(f"❌ Error listing Lambda functions: {e}")
    
    # Check for IAM roles with similar names
    try:
        response = iam_client.list_roles()
        demo_roles = [r for r in response['Roles'] 
                     if 'lambda' in r['RoleName'].lower() and 
                     ('demo' in r['RoleName'].lower() or 
                      'test' in r['RoleName'].lower() or
                      'my' in r['RoleName'].lower())]
        
        if demo_roles:
            print(f"📋 Found {len(demo_roles)} potentially related IAM roles:")
            for role in demo_roles:
                print(f"   - {role['RoleName']}")
                found_resources.append(('iam', role['RoleName']))
    except Exception as e:
        print(f"❌ Error listing IAM roles: {e}")
    
    # Check for CloudWatch log groups
    try:
        response = logs_client.describe_log_groups(
            logGroupNamePrefix="/aws/lambda/"
        )
        demo_logs = [lg for lg in response['logGroups'] 
                    if 'lambda' in lg['logGroupName'].lower() and 
                    ('demo' in lg['logGroupName'].lower() or 
                     'test' in lg['logGroupName'].lower() or
                     'my' in lg['logGroupName'].lower())]
        
        if demo_logs:
            print(f"📋 Found {len(demo_logs)} potentially related CloudWatch log groups:")
            for log_group in demo_logs:
                print(f"   - {log_group['logGroupName']}")
                found_resources.append(('logs', log_group['logGroupName']))
    except Exception as e:
        print(f"❌ Error listing CloudWatch log groups: {e}")
    
    return found_resources

def interactive_cleanup(lambda_client, iam_client, logs_client):
    """Interactively clean up additional resources."""
    related_resources = list_related_resources(lambda_client, iam_client, logs_client)
    
    if not related_resources:
        print("✅ No additional related resources found.")
        return
    
    print(f"\n❓ Found {len(related_resources)} additional resources that might be related to demonstrations.")
    response = input("Would you like to clean these up as well? (y/N): ").strip().lower()
    
    if response in ['y', 'yes']:
        for resource_type, resource_name in related_resources:
            try:
                if resource_type == 'lambda':
                    lambda_client.delete_function(FunctionName=resource_name)
                    print(f"✅ Deleted Lambda function: {resource_name}")
                elif resource_type == 'iam':
                    # Detach policies first
                    try:
                        policies = iam_client.list_attached_role_policies(RoleName=resource_name)
                        for policy in policies['AttachedPolicies']:
                            iam_client.detach_role_policy(
                                RoleName=resource_name,
                                PolicyArn=policy['PolicyArn']
                            )
                    except:
                        pass
                    iam_client.delete_role(RoleName=resource_name)
                    print(f"✅ Deleted IAM role: {resource_name}")
                elif resource_type == 'logs':
                    logs_client.delete_log_group(logGroupName=resource_name)
                    print(f"✅ Deleted CloudWatch log group: {resource_name}")
            except Exception as e:
                print(f"❌ Error deleting {resource_type} resource '{resource_name}': {e}")

def cleanup_local_files():
    """Clean up local test files and directories."""
    import os
    import shutil
    
    print("\n🧹 Cleaning up local files...")
    
    # Remove virtual environment
    venv_path = "venv"
    if os.path.exists(venv_path):
        try:
            shutil.rmtree(venv_path)
            print("✅ Removed virtual environment directory")
        except Exception as e:
            print(f"❌ Error removing virtual environment: {e}")
    else:
        print("ℹ️  Virtual environment directory not found")
    
    # Remove Python cache
    pycache_path = "__pycache__"
    if os.path.exists(pycache_path):
        try:
            shutil.rmtree(pycache_path)
            print("✅ Removed Python cache directory")
        except Exception as e:
            print(f"❌ Error removing Python cache: {e}")
    else:
        print("ℹ️  Python cache directory not found")

def main():
    """Main cleanup function."""
    print("🧹 Lambda Demonstration Cleanup Script")
    print("=" * 50)
    
    # Get current AWS identity
    try:
        sts_client = boto3.client('sts')
        identity = sts_client.get_caller_identity()
        print(f"🔐 AWS Account: {identity['Account']}")
        print(f"👤 User/Role: {identity['Arn'].split('/')[-1]}")
    except Exception as e:
        print(f"❌ Error getting AWS identity: {e}")
        return
    
    # Create AWS clients
    lambda_client, iam_client, logs_client = create_clients()
    if not all([lambda_client, iam_client, logs_client]):
        return
    
    print(f"\n🎯 Cleaning up demonstration resources...")
    print(f"   - Lambda function: {FUNCTION_NAME}")
    print(f"   - IAM role: {ROLE_NAME}")
    print(f"   - CloudWatch log group: {LOG_GROUP_NAME}")
    
    # Confirm cleanup
    response = input("\nProceed with cleanup? (y/N): ").strip().lower()
    if response not in ['y', 'yes']:
        print("❌ Cleanup cancelled.")
        return
    
    print("\n🚀 Starting cleanup...")
    
    # Track cleanup results
    results = {
        'lambda': False,
        'iam': False,
        'logs': False
    }
    
    # Clean up Lambda function
    results['lambda'] = cleanup_lambda_function(lambda_client)
    
    # Clean up IAM role
    results['iam'] = cleanup_iam_role(iam_client)
    
    # Clean up CloudWatch logs
    results['logs'] = cleanup_cloudwatch_logs(logs_client)
    
    # Interactive cleanup for additional resources
    interactive_cleanup(lambda_client, iam_client, logs_client)
    
    # Clean up local files
    cleanup_local_files()
    
    # Summary
    print("\n" + "=" * 50)
    print("🏁 CLEANUP SUMMARY")
    print("=" * 50)
    
    cleaned_count = sum(results.values())
    total_resources = len(results)
    
    for resource_type, cleaned in results.items():
        status = "✅ CLEANED" if cleaned else "ℹ️  NOT FOUND"
        print(f"{resource_type.upper()}: {status}")
    
    if cleaned_count > 0:
        print(f"\n✅ Successfully cleaned up {cleaned_count} resources.")
    else:
        print(f"\nℹ️  No demonstration resources found to clean up.")
    
    print("\n🎉 Cleanup completed!")
    print("\nNote: It may take a few minutes for all resources to be fully removed from AWS.")

if __name__ == "__main__":
    main()
