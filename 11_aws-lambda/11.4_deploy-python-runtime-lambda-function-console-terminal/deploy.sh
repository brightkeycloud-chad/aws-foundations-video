#!/bin/bash

# Deploy Python Lambda Function with Dependencies
# This script creates a deployment package and uploads it to AWS Lambda
# Compatible with Linux and macOS

set -e

FUNCTION_NAME="CostExplorerFunction"
REGION="us-east-1"
ROLE_NAME="CostExplorerRole"

echo "🚀 Starting Lambda deployment process..."

# Function to detect Python executable
detect_python() {
    local python_cmd=""
    local python_version=""
    
    # Try different Python executable names in order of preference
    for cmd in python3 python python3.13 python3.12 python3.11 python3.10 python3.9 python3.8; do
        if command -v "$cmd" &> /dev/null; then
            python_version=$($cmd --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            if [[ -n "$python_version" ]]; then
                # Check if version is 3.8 or higher
                if $cmd -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" 2>/dev/null; then
                    python_cmd="$cmd"
                    break
                fi
            fi
        fi
    done
    
    if [[ -z "$python_cmd" ]]; then
        echo "❌ Python 3.8+ not found. Please install Python 3.8 or higher."
        echo "   Tried: python3, python, python3.13, python3.12, python3.11, python3.10, python3.9, python3.8"
        exit 1
    fi
    
    echo "✅ Found Python: $python_cmd (version $python_version)"
    DETECTED_PYTHON="$python_cmd"
    DETECTED_PYTHON_VERSION="$python_version"
}

# Function to detect pip executable
detect_pip() {
    local python_cmd="$1"
    local pip_cmd=""
    
    # Try different pip executable names
    for cmd in pip3 pip; do
        if command -v "$cmd" &> /dev/null; then
            # Test if pip actually works
            if $cmd --version &> /dev/null; then
                pip_cmd="$cmd"
                break
            fi
        fi
    done
    
    # Try python -m pip as fallback
    if [[ -z "$pip_cmd" ]]; then
        if $python_cmd -m pip --version &> /dev/null; then
            pip_cmd="$python_cmd -m pip"
        fi
    fi
    
    if [[ -z "$pip_cmd" ]]; then
        echo "❌ pip not found. Please install pip."
        echo "   Tried: pip3, pip, $python_cmd -m pip"
        exit 1
    fi
    
    echo "✅ Found pip: $pip_cmd"
    DETECTED_PIP="$pip_cmd"
}

# Function to detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "🐧 Detected OS: Linux"
        DETECTED_OS="Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🍎 Detected OS: macOS"
        DETECTED_OS="macOS"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "🪟 Detected OS: Windows"
        echo "⚠️  Windows detected. This script is optimized for Linux/macOS."
        echo "   Consider using Windows Subsystem for Linux (WSL) for best compatibility."
        DETECTED_OS="Windows"
    else
        echo "❓ Unknown OS: $OSTYPE"
        echo "   Proceeding with Linux/macOS assumptions..."
        DETECTED_OS="Unknown"
    fi
}

# Detect operating system
detect_os

# Detect Python executable
echo "🔍 Detecting Python installation..."
detect_python

# Detect pip executable
echo "🔍 Detecting pip installation..."
detect_pip "$DETECTED_PYTHON"

# Display system information
echo ""
echo "📋 System Information:"
echo "   OS: $DETECTED_OS ($OSTYPE)"
echo "   Python: $DETECTED_PYTHON ($DETECTED_PYTHON_VERSION)"
echo "   Pip: $DETECTED_PIP"
echo ""

# Clean up previous builds
echo "🧹 Cleaning up previous builds..."
rm -rf package/
rm -f deployment-package.zip

# Create package directory
echo "📦 Creating package directory..."
mkdir package

# Install dependencies
echo "📥 Installing dependencies..."
echo "   Using: $DETECTED_PIP install --target ./package -r requirements.txt"

# Execute pip install command
if [[ "$DETECTED_PIP" == *"-m pip" ]]; then
    # Handle "python -m pip" case
    $DETECTED_PIP install --target ./package -r requirements.txt
else
    # Handle regular pip case
    $DETECTED_PIP install --target ./package -r requirements.txt
fi

# Verify installation
if [[ ! -d "package/boto3" ]]; then
    echo "❌ Failed to install dependencies. boto3 not found in package directory."
    exit 1
fi

echo "✅ Dependencies installed successfully"

# Copy function code
echo "📋 Copying function code..."
cp lambda_function.py package/

# Create deployment package
echo "🗜️  Creating deployment package..."
cd package

# Use different zip commands based on availability
if command -v zip &> /dev/null; then
    zip -r ../deployment-package.zip .
elif $DETECTED_PYTHON -c "import zipfile" 2>/dev/null; then
    echo "   Using Python zipfile module..."
    $DETECTED_PYTHON -c "
import zipfile
import os
with zipfile.ZipFile('../deployment-package.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk('.'):
        for file in files:
            file_path = os.path.join(root, file)
            arcname = os.path.relpath(file_path, '.')
            zipf.write(file_path, arcname)
print('Zip file created successfully')
"
else
    echo "❌ No zip utility found. Please install zip or ensure Python zipfile module is available."
    exit 1
fi

cd ..

# Verify deployment package was created
if [[ ! -f "deployment-package.zip" ]]; then
    echo "❌ Failed to create deployment package"
    exit 1
fi

echo "✅ Deployment package created: deployment-package.zip"

# Display package information
if command -v du &> /dev/null; then
    PACKAGE_SIZE=$(du -h deployment-package.zip | cut -f1)
    echo "📊 Package size: $PACKAGE_SIZE"
fi

# Check if AWS CLI is configured
echo "🔍 Checking AWS CLI configuration..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    echo ""
    echo "📝 To configure AWS CLI:"
    echo "   1. Run: aws configure"
    echo "   2. Enter your AWS Access Key ID"
    echo "   3. Enter your AWS Secret Access Key"
    echo "   4. Enter your default region (e.g., us-east-1)"
    echo "   5. Enter default output format (json recommended)"
    exit 1
fi

# Get AWS account information
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_USER=$(aws sts get-caller-identity --query Arn --output text)
echo "✅ AWS CLI configured"
echo "   Account: $AWS_ACCOUNT"
echo "   User/Role: $AWS_USER"

echo "🔍 Checking if function exists..."
if aws lambda get-function --function-name $FUNCTION_NAME --region $REGION > /dev/null 2>&1; then
    echo "🔄 Function exists. Updating function code..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://deployment-package.zip \
        --region $REGION
    echo "✅ Function code updated successfully!"
    
    # Update function configuration to ensure proper timeout and memory
    echo "⚙️  Updating function configuration..."
    aws lambda update-function-configuration \
        --function-name $FUNCTION_NAME \
        --timeout 30 \
        --memory-size 256 \
        --region $REGION > /dev/null
    
else
    echo "❌ Function does not exist. Please create it first using the AWS Console."
    echo ""
    echo "📝 To create the function:"
    echo "   1. Go to AWS Lambda Console: https://console.aws.amazon.com/lambda/"
    echo "   2. Click 'Create function'"
    echo "   3. Select 'Author from scratch'"
    echo "   4. Function name: $FUNCTION_NAME"
    echo "   5. Runtime: Python 3.13 (or latest available)"
    echo "   6. Handler: lambda_function.lambda_handler"
    echo "   7. Add required IAM permissions for Cost Explorer and S3"
    echo "   8. Then run this script again to update the code."
    echo ""
    echo "📋 Required IAM permissions:"
    echo "   - AWSLambdaBasicExecutionRole"
    echo "   - AWSBillingReadOnlyAccess (or custom Cost Explorer permissions)"
    echo "   - AmazonS3FullAccess (or specific S3 bucket permissions)"
fi

echo ""
echo "🎉 Deployment process completed!"
echo ""
echo "📊 Summary:"
echo "   Function: $FUNCTION_NAME"
echo "   Region: $REGION"
echo "   Package: deployment-package.zip"
echo "   Python: $DETECTED_PYTHON ($DETECTED_PYTHON_VERSION)"
echo "   Pip: $DETECTED_PIP"
echo "   OS: $DETECTED_OS"
echo ""
echo "🧪 To test the function:"
echo "   aws lambda invoke --function-name $FUNCTION_NAME \\"
echo "     --payload '{\"bucket_name\":\"your-bucket-name\"}' \\"
echo "     --region $REGION response.json"
