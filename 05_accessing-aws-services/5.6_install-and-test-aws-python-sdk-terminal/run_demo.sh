#!/bin/bash

# AWS Python SDK Demo Runner Script

echo "=== AWS Python SDK (Boto3) Demonstration ==="
echo ""

# Check if virtual environment is activated
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "Virtual environment not detected. Activating..."
    if [ -d "aws-sdk-env" ]; then
        source aws-sdk-env/bin/activate
        echo "Virtual environment activated."
    else
        echo "Virtual environment not found. Please run setup_venv.sh first."
        exit 1
    fi
fi

echo "Python version: $(python --version)"
echo "Boto3 version: $(python -c "import boto3; print(boto3.__version__)")"
echo ""

echo "1. Checking AWS credentials..."
python check_credentials.py
echo ""

echo "2. Listing S3 buckets..."
python list_buckets.py
echo ""

echo "3. Listing EC2 instances..."
python list_instances.py
echo ""

echo "4. Running multi-service demo..."
python aws_services_demo.py
echo ""

echo "Demo complete!"