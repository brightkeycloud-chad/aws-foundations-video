#!/bin/bash

# AWS Python SDK (Boto3) Virtual Environment Setup Script

echo "Setting up Python virtual environment for AWS SDK demonstration..."

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed. Please install Python 3.7 or later."
    exit 1
fi

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv aws-sdk-env

# Activate virtual environment
echo "Activating virtual environment..."
source aws-sdk-env/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "Installing AWS SDK (boto3)..."
pip install -r requirements.txt

echo "Setup complete!"
echo ""
echo "To activate the virtual environment, run:"
echo "source aws-sdk-env/bin/activate"
echo ""
echo "To deactivate, run:"
echo "deactivate"