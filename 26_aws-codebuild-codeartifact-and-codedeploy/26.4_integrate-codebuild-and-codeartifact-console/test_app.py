import pytest
import json
from app import lambda_handler

def test_lambda_handler():
    """Test the lambda handler function"""
    event = {}
    context = {}
    
    result = lambda_handler(event, context)
    
    assert result['statusCode'] == 200
    body = json.loads(result['body'])
    assert 'message' in body
    assert body['message'] == 'Successfully used CodeArtifact packages!'

def test_lambda_handler_structure():
    """Test the response structure"""
    event = {}
    context = {}
    
    result = lambda_handler(event, context)
    
    assert 'statusCode' in result
    assert 'body' in result
    
    body = json.loads(result['body'])
    assert 'message' in body
    assert 'http_data' in body
