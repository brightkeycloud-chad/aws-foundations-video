#!/bin/bash

# Lambda Demonstration Test Runner
# This script validates the demonstration instructions by programmatically
# creating, testing, and cleaning up Lambda functions.

set -e

echo "Lambda Demonstration Test Runner"
echo "================================"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI is not configured or credentials are invalid."
    echo "Please run 'aws configure' to set up your credentials."
    exit 1
fi

echo "✓ AWS credentials are configured"

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed."
    exit 1
fi

echo "✓ Python 3 is available"

# Check if boto3 is installed, install in virtual environment if needed
if ! python3 -c "import boto3" &> /dev/null; then
    echo "boto3 not found. Creating virtual environment..."
    python3 -m venv venv
    source venv/bin/activate
    pip install boto3
    echo "✓ boto3 installed in virtual environment"
    VENV_ACTIVATED=true
else
    echo "✓ boto3 is available"
    VENV_ACTIVATED=false
fi

# Get current AWS region
AWS_REGION=$(aws configure get region)
if [ -z "$AWS_REGION" ]; then
    echo "Warning: No default region configured. Using us-east-1"
    export AWS_DEFAULT_REGION=us-east-1
else
    echo "✓ Using AWS region: $AWS_REGION"
fi

# Run the test
echo ""
echo "Running Lambda demonstration tests..."
echo "This will create, test, and clean up Lambda functions in your AWS account."
echo ""

if [ "$VENV_ACTIVATED" = true ]; then
    python3 test_lambda_demo.py
else
    python3 test_lambda_demo.py
fi

echo ""
echo "Test completed successfully!"
echo "The demonstration instructions have been validated."
