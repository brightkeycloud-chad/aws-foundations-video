import json
import boto3
import os
import logging
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients outside handler for reuse
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    """
    AWS Lambda function handler for processing events
    Demonstrates common Lambda patterns and AWS service integration
    """
    
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Get function metadata
        function_name = context.function_name
        function_version = context.function_version
        request_id = context.aws_request_id
        
        # Process different event types
        if 'source' in event and event['source'] == 'aws.s3':
            return handle_s3_event(event, context)
        elif 'httpMethod' in event:
            return handle_api_gateway_event(event, context)
        else:
            return handle_direct_invocation(event, context)
            
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'requestId': context.aws_request_id
            })
        }

def handle_s3_event(event, context):
    """Handle S3 bucket events"""
    logger.info("Processing S3 event")
    
    processed_objects = []
    for record in event.get('Records', []):
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        event_name = record['eventName']
        
        processed_objects.append({
            'bucket': bucket,
            'key': key,
            'event': event_name,
            'processed_at': datetime.utcnow().isoformat()
        })
        
        logger.info(f"Processed S3 object: {bucket}/{key}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'S3 event processed successfully',
            'processed_objects': processed_objects
        })
    }

def handle_api_gateway_event(event, context):
    """Handle API Gateway events"""
    logger.info("Processing API Gateway event")
    
    method = event['httpMethod']
    path = event['path']
    query_params = event.get('queryStringParameters', {})
    
    response_body = {
        'message': 'API Gateway event processed',
        'method': method,
        'path': path,
        'query_parameters': query_params,
        'timestamp': datetime.utcnow().isoformat(),
        'function_name': context.function_name
    }
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(response_body)
    }

def handle_direct_invocation(event, context):
    """Handle direct Lambda invocations"""
    logger.info("Processing direct invocation")
    
    # Extract data from event
    action = event.get('action', 'default')
    data = event.get('data', {})
    
    # Perform action based on event
    if action == 'process_data':
        result = process_business_logic(data)
    elif action == 'health_check':
        result = perform_health_check()
    else:
        result = {
            'message': 'Default processing completed',
            'received_data': data
        }
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'action': action,
            'result': result,
            'execution_time': context.get_remaining_time_in_millis(),
            'memory_limit': context.memory_limit_in_mb,
            'request_id': context.aws_request_id
        })
    }

def process_business_logic(data):
    """Simulate business logic processing"""
    logger.info("Processing business logic")
    
    # Simulate data processing
    processed_items = []
    for item in data.get('items', []):
        processed_items.append({
            'original': item,
            'processed': item.upper() if isinstance(item, str) else str(item),
            'timestamp': datetime.utcnow().isoformat()
        })
    
    return {
        'processed_count': len(processed_items),
        'processed_items': processed_items
    }

def perform_health_check():
    """Perform system health check"""
    logger.info("Performing health check")
    
    health_status = {
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'checks': {
            's3_client': 'available',
            'dynamodb_client': 'available',
            'memory_usage': 'normal'
        }
    }
    
    return health_status
