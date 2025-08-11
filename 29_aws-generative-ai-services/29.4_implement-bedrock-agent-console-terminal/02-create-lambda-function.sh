#!/bin/bash

# Script 2: Create Lambda Function for Action Group
echo "Creating Lambda function for Bedrock Agent action group..."

# Create Lambda function code
echo "Creating Lambda function code..."
cat > lambda_function.py << EOF
import json

def lambda_handler(event, context):
    """
    Lambda function for Bedrock Agent weather demo
    Handles the parameter format from Bedrock agents
    """
    print(f"Received event: {json.dumps(event)}")
    
    # Extract function name and parameters from the event
    function_name = event.get('function', '')
    parameters_list = event.get('parameters', [])
    action_group = event.get('actionGroup', '')
    
    # Convert parameters list to dictionary
    parameters = {}
    for param in parameters_list:
        if isinstance(param, dict) and 'name' in param and 'value' in param:
            parameters[param['name']] = param['value']
    
    print(f"Function: {function_name}, Parameters: {parameters}")
    
    if function_name == 'get_weather':
        location = parameters.get('location', 'Unknown')
        
        # Simulate weather data based on location
        weather_responses = {
            'seattle': 'Cloudy and 62°F with light rain',
            'new york': 'Sunny and 75°F with clear skies',
            'miami': 'Hot and 85°F with high humidity',
            'denver': 'Partly cloudy and 68°F with mountain breeze',
            'chicago': 'Windy and 58°F with overcast skies',
            'los angeles': 'Sunny and 78°F with light breeze'
        }
        
        weather = weather_responses.get(location.lower(), f'Pleasant and 72°F in {location}')
        
        # Return response in the correct format for Bedrock agents with function details
        response = {
            'messageVersion': '1.0',
            'response': {
                'actionGroup': action_group,
                'function': function_name,
                'functionResponse': {
                    'responseBody': {
                        'TEXT': {
                            'body': f"The current weather in {location} is {weather}."
                        }
                    }
                }
            }
        }
        
        print(f"Returning response: {json.dumps(response)}")
        return response
    
    # Handle unknown functions
    error_response = {
        'messageVersion': '1.0',
        'response': {
            'actionGroup': action_group,
            'function': function_name,
            'functionResponse': {
                'responseState': 'FAILURE',
                'responseBody': {
                    'TEXT': {
                        'body': f'Sorry, I don\\'t know how to handle the function: {function_name}'
                    }
                }
            }
        }
    }
    
    print(f"Returning error response: {json.dumps(error_response)}")
    return error_response
EOF

echo "✅ Created lambda_function.py"

# Create deployment package
echo "Creating deployment package..."
zip lambda-function.zip lambda_function.py

if [ $? -eq 0 ]; then
    echo "✅ Created lambda-function.zip"
else
    echo "❌ Failed to create deployment package"
    exit 1
fi

# Create Lambda execution role
echo "Creating Lambda execution role..."
aws iam create-role \
    --role-name lambda-execution-role \
    --assume-role-policy-document '{
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
    }'

if [ $? -eq 0 ]; then
    echo "✅ Successfully created lambda-execution-role"
else
    echo "⚠️  Lambda execution role may already exist"
fi

# Attach basic execution policy
echo "Attaching basic execution policy..."
aws iam attach-role-policy \
    --role-name lambda-execution-role \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

if [ $? -eq 0 ]; then
    echo "✅ Successfully attached basic execution policy"
fi

# Wait a moment for role to propagate
echo "Waiting for IAM role to propagate..."
sleep 10

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create Lambda function
echo "Creating Lambda function: bedrock-agent-weather..."
aws lambda create-function \
    --function-name bedrock-agent-weather \
    --runtime python3.9 \
    --role arn:aws:iam::$ACCOUNT_ID:role/lambda-execution-role \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://lambda-function.zip \
    --description "Weather function for Bedrock Agent demo" \
    --timeout 30

if [ $? -eq 0 ]; then
    echo "✅ Successfully created Lambda function: bedrock-agent-weather"
    
    # Get function ARN for reference
    FUNCTION_ARN=$(aws lambda get-function --function-name bedrock-agent-weather --query Configuration.FunctionArn --output text)
    echo "📝 Function ARN: $FUNCTION_ARN"
else
    echo "❌ Failed to create Lambda function"
fi

echo "Lambda function setup completed!"
