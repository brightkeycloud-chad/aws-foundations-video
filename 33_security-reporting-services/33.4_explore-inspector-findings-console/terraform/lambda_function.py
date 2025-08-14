"""
Lambda function with vulnerable dependencies for Inspector demo
This function intentionally uses outdated packages with known security vulnerabilities
"""

import json
import boto3
import requests
import urllib3
from datetime import datetime
import os

# Disable SSL warnings (vulnerability)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def handler(event, context):
    """
    Lambda handler function with vulnerable code patterns
    """
    
    # Get region from template variable
    region = "${region}"
    
    try:
        # Vulnerable: Using requests without SSL verification
        response = requests.get(
            "https://httpbin.org/json", 
            verify=False,  # SSL verification disabled - VULNERABILITY
            timeout=30
        )
        
        # Vulnerable: Direct string formatting (potential injection)
        user_input = event.get('user_input', 'demo')
        message = f"Hello {user_input}!"  # Potential injection point
        
        # Vulnerable: Using eval (if user_input contains code)
        if 'calculate' in event:
            # NEVER do this in production - eval is extremely dangerous
            try:
                result = eval(event['calculate'])  # MAJOR VULNERABILITY
            except:
                result = "calculation_error"
        else:
            result = "no_calculation"
        
        # Create response with vulnerable information disclosure
        response_data = {
            'statusCode': 200,
            'message': message,
            'calculation_result': result,
            'timestamp': datetime.now().isoformat(),
            'region': region,
            'function_name': context.function_name,
            'aws_request_id': context.aws_request_id,
            # Vulnerable: Exposing internal information
            'environment_variables': dict(os.environ),  # VULNERABILITY: Info disclosure
            'external_api_response': response.json() if response.status_code == 200 else None,
            'vulnerable_packages': {
                'requests': requests.__version__,
                'urllib3': urllib3.__version__,
                'boto3': boto3.__version__
            }
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                # Vulnerable: Permissive CORS
                'Access-Control-Allow-Origin': '*',  # VULNERABILITY
                'Access-Control-Allow-Methods': '*',  # VULNERABILITY
                'Access-Control-Allow-Headers': '*'   # VULNERABILITY
            },
            'body': json.dumps(response_data)
        }
        
    except Exception as e:
        # Vulnerable: Detailed error information disclosure
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e),
                'error_type': type(e).__name__,
                'function_name': context.function_name,
                # Vulnerable: Stack trace disclosure
                'stack_trace': str(e.__traceback__) if hasattr(e, '__traceback__') else None
            })
        }
