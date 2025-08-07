import requests
import boto3
import json

def lambda_handler(event, context):
    """
    Simple Lambda function that makes an HTTP request
    and interacts with AWS services
    """
    try:
        # Make HTTP request using requests library
        response = requests.get('https://httpbin.org/json')
        data = response.json()
        
        # Use boto3 to get AWS account info
        sts = boto3.client('sts')
        identity = sts.get_caller_identity()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Successfully used CodeArtifact packages!',
                'http_data': data,
                'aws_account': identity.get('Account', 'Unknown')
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }

if __name__ == "__main__":
    print("Testing locally...")
    result = lambda_handler({}, {})
    print(json.dumps(result, indent=2))
