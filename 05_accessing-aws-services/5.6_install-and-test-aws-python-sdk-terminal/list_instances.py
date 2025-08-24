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