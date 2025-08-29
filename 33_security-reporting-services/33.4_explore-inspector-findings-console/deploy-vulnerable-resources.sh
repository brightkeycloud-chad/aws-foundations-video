#!/bin/bash

# AWS Inspector Demo - Vulnerable Resources Deployment Script
# This script creates EC2 instances, Lambda functions, and ECR repositories with known vulnerabilities

echo "🚀 Deploying vulnerable resources for Inspector demo..."

# Configuration
REGION=${AWS_DEFAULT_REGION:-us-east-1}
INSTANCE_TYPE=${INSTANCE_TYPE:-t3.micro}
KEY_PAIR_NAME=${KEY_PAIR_NAME:-}
ENVIRONMENT="inspector-demo"

echo "🌍 Using region: $REGION"
echo "💻 Instance type: $INSTANCE_TYPE"

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
    echo "✅ AWS CLI configured successfully"
}

# Function to get account ID and region
get_aws_info() {
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
    CURRENT_REGION=$(aws configure get region || echo $REGION)
    echo "📋 Account ID: $ACCOUNT_ID"
    echo "🌍 Region: $CURRENT_REGION"
}

# Function to create security group
create_security_group() {
    echo "🔄 Creating vulnerable security group..."
    
    # Get default VPC
    VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)
    
    if [ "$VPC_ID" = "None" ] || [ -z "$VPC_ID" ]; then
        echo "❌ No default VPC found. Please create a VPC first."
        exit 1
    fi
    
    # Check if security group already exists
    EXISTING_SG=$(aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=inspector-demo-vulnerable-sg" "Name=vpc-id,Values=$VPC_ID" \
        --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "None")
    
    if [ "$EXISTING_SG" != "None" ] && [ -n "$EXISTING_SG" ]; then
        echo "  ⚠️  Security group already exists, using existing: $EXISTING_SG"
        SG_ID="$EXISTING_SG"
    else
        # Create security group
        SG_ID=$(aws ec2 create-security-group \
            --group-name "inspector-demo-vulnerable-sg" \
            --description "Deliberately vulnerable security group for Inspector demo" \
            --vpc-id "$VPC_ID" \
            --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=inspector-demo-vulnerable-sg},{Key=Purpose,Value=Inspector Demo},{Key=Vulnerable,Value=true}]" \
            --query 'GroupId' --output text 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$SG_ID" ]; then
            echo "  ✅ Security group created: $SG_ID"
            
            # Add ingress rules (deliberately permissive)
            aws ec2 authorize-security-group-ingress \
                --group-id "$SG_ID" \
                --protocol tcp \
                --port 22 \
                --cidr 0.0.0.0/0 2>/dev/null || echo "  ⚠️  SSH rule may already exist"
            
            aws ec2 authorize-security-group-ingress \
                --group-id "$SG_ID" \
                --protocol tcp \
                --port 80 \
                --cidr 0.0.0.0/0 2>/dev/null || echo "  ⚠️  HTTP rule may already exist"
            
            aws ec2 authorize-security-group-ingress \
                --group-id "$SG_ID" \
                --protocol tcp \
                --port 443 \
                --cidr 0.0.0.0/0 2>/dev/null || echo "  ⚠️  HTTPS rule may already exist"
        else
            echo "❌ Failed to create security group"
            exit 1
        fi
    fi
    
    echo "$SG_ID" > /tmp/inspector-demo-sg-id
}

# Function to create IAM role for EC2
create_ec2_iam_role() {
    echo "🔄 Creating IAM role for EC2 instances..."
    
    ROLE_NAME="inspector-demo-ec2-role"
    
    # Check if role already exists
    EXISTING_ROLE=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.RoleName' --output text 2>/dev/null || echo "None")
    
    if [ "$EXISTING_ROLE" != "None" ]; then
        echo "  ⚠️  IAM role already exists, using existing: $ROLE_NAME"
    else
        # Create trust policy
        cat > /tmp/ec2-trust-policy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
        
        # Create IAM role
        aws iam create-role \
            --role-name "$ROLE_NAME" \
            --assume-role-policy-document file:///tmp/ec2-trust-policy.json \
            --tags Key=Purpose,Value="Inspector Demo" Key=Environment,Value="$ENVIRONMENT" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "  ✅ IAM role created: $ROLE_NAME"
        else
            echo "  ⚠️  IAM role creation failed, may already exist"
        fi
    fi
    
    # Attach SSM policy for Inspector (idempotent)
    aws iam attach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" 2>/dev/null || echo "  ⚠️  Policy may already be attached"
    
    # Check if instance profile exists
    EXISTING_PROFILE=$(aws iam get-instance-profile --instance-profile-name "$ROLE_NAME" --query 'InstanceProfile.InstanceProfileName' --output text 2>/dev/null || echo "None")
    
    if [ "$EXISTING_PROFILE" != "None" ]; then
        echo "  ⚠️  Instance profile already exists: $ROLE_NAME"
    else
        # Create instance profile
        aws iam create-instance-profile --instance-profile-name "$ROLE_NAME" 2>/dev/null
        
        # Add role to instance profile
        aws iam add-role-to-instance-profile \
            --instance-profile-name "$ROLE_NAME" \
            --role-name "$ROLE_NAME" 2>/dev/null || echo "  ⚠️  Role may already be in instance profile"
        
        echo "  ✅ Instance profile created: $ROLE_NAME"
    fi
    
    echo "$ROLE_NAME" > /tmp/inspector-demo-role-name
    
    # Wait for role to be available
    sleep 10
}

# Function to get AMI IDs for vulnerable instances
get_vulnerable_amis() {
    echo "🔄 Finding vulnerable AMI IDs..."
    
    # Use a slightly older Amazon Linux 2 AMI for more vulnerabilities
    AL2_AMI=$(aws ec2 describe-images \
        --owners amazon \
        --filters "Name=name,Values=amzn2-ami-hvm-2.0.20250721.2-x86_64-gp2" \
        --query 'Images[0].ImageId' --output text)
    
    if [ "$AL2_AMI" = "None" ] || [ -z "$AL2_AMI" ]; then
        # Fallback to any available AL2 AMI
        AL2_AMI=$(aws ec2 describe-images \
            --owners amazon \
            --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" \
            --query 'Images | sort_by(@, &CreationDate) | [-2].ImageId' --output text)
    fi
    
    # Use Ubuntu 20.04 AMI (has more known vulnerabilities than newer versions)
    UBUNTU_AMI=$(aws ec2 describe-images \
        --owners 099720109477 \
        --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20250603" \
        --query 'Images[0].ImageId' --output text)
    
    if [ "$UBUNTU_AMI" = "None" ] || [ -z "$UBUNTU_AMI" ]; then
        # Fallback to any available Ubuntu 20.04
        UBUNTU_AMI=$(aws ec2 describe-images \
            --owners 099720109477 \
            --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" "Name=state,Values=available" \
            --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
    fi
    
    echo "  📋 Amazon Linux 2 AMI: $AL2_AMI"
    echo "  📋 Ubuntu AMI: $UBUNTU_AMI"
    
    echo "$AL2_AMI" > /tmp/inspector-demo-al2-ami
    echo "$UBUNTU_AMI" > /tmp/inspector-demo-ubuntu-ami
}

# Function to create user data scripts
create_user_data_scripts() {
    echo "🔄 Creating user data scripts..."
    
    # Amazon Linux 2 user data
    cat > /tmp/user-data-al2.sh << 'EOF'
#!/bin/bash
yum update -y
yum install -y httpd openssl curl wget git python3 nodejs npm
pip3 install requests==2.25.1 urllib3==1.26.5 Pillow==8.3.2 Django==3.2.13 Flask==2.0.3
npm install -g lodash@4.17.20 moment@2.29.1 express@4.17.1 axios@0.21.1
systemctl start httpd
systemctl enable httpd
yum install -y amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent
echo "<h1>Inspector Demo - Vulnerable Amazon Linux 2</h1>" > /var/www/html/index.html
echo "$(date): Vulnerable AL2 setup completed" >> /var/log/inspector-demo.log
EOF
    
    # Ubuntu user data
    cat > /tmp/user-data-ubuntu.sh << 'EOF'
#!/bin/bash
apt-get update
apt-get install -y apache2 openssl curl wget git python3 python3-pip nodejs npm php7.4 php7.4-apache2
pip3 install requests==2.25.1 urllib3==1.26.5 Pillow==8.3.2 Django==3.2.13 Flask==2.0.3
npm install -g lodash@4.17.20 moment@2.29.1 express@4.17.1 axios@0.21.1
systemctl start apache2
systemctl enable apache2
snap install amazon-ssm-agent --classic
echo "<h1>Inspector Demo - Vulnerable Ubuntu</h1>" > /var/www/html/index.html
echo "$(date): Vulnerable Ubuntu setup completed" >> /var/log/inspector-demo.log
EOF
}

# Function to launch EC2 instances
launch_ec2_instances() {
    echo "🔄 Launching vulnerable EC2 instances..."
    
    SG_ID=$(cat /tmp/inspector-demo-sg-id)
    ROLE_NAME=$(cat /tmp/inspector-demo-role-name)
    AL2_AMI=$(cat /tmp/inspector-demo-al2-ami)
    UBUNTU_AMI=$(cat /tmp/inspector-demo-ubuntu-ami)
    
    # Get first available subnet
    SUBNET_ID=$(aws ec2 describe-subnets \
        --filters "Name=default-for-az,Values=true" \
        --query 'Subnets[0].SubnetId' --output text)
    
    # Build key pair parameter
    KEY_PAIR_PARAM=""
    if [ -n "$KEY_PAIR_NAME" ] && [ "$KEY_PAIR_NAME" != "" ]; then
        KEY_PAIR_PARAM="--key-name $KEY_PAIR_NAME"
        echo "  📋 Using key pair: $KEY_PAIR_NAME"
    else
        echo "  ⚠️  No key pair specified - instances will not have SSH access"
    fi
    
    # Launch Amazon Linux 2 instance
    AL2_INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AL2_AMI" \
        --count 1 \
        --instance-type "$INSTANCE_TYPE" \
        $KEY_PAIR_PARAM \
        --security-group-ids "$SG_ID" \
        --subnet-id "$SUBNET_ID" \
        --iam-instance-profile Name="$ROLE_NAME" \
        --user-data file:///tmp/user-data-al2.sh \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=inspector-demo-vulnerable-al2},{Key=Purpose,Value=Inspector Demo},{Key=OS,Value=Amazon Linux 2},{Key=Vulnerable,Value=true}]" \
        --query 'Instances[0].InstanceId' --output text 2>/dev/null)
    
    # Launch Ubuntu instance
    UBUNTU_INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$UBUNTU_AMI" \
        --count 1 \
        --instance-type "$INSTANCE_TYPE" \
        $KEY_PAIR_PARAM \
        --security-group-ids "$SG_ID" \
        --subnet-id "$SUBNET_ID" \
        --iam-instance-profile Name="$ROLE_NAME" \
        --user-data file:///tmp/user-data-ubuntu.sh \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=inspector-demo-vulnerable-ubuntu},{Key=Purpose,Value=Inspector Demo},{Key=OS,Value=Ubuntu 20.04},{Key=Vulnerable,Value=true}]" \
        --query 'Instances[0].InstanceId' --output text 2>/dev/null)
    
    if [ -n "$AL2_INSTANCE_ID" ] && [ "$AL2_INSTANCE_ID" != "None" ]; then
        echo "  ✅ Amazon Linux 2 instance: $AL2_INSTANCE_ID"
        echo "$AL2_INSTANCE_ID" > /tmp/inspector-demo-al2-instance
    else
        echo "  ❌ Failed to launch Amazon Linux 2 instance"
    fi
    
    if [ -n "$UBUNTU_INSTANCE_ID" ] && [ "$UBUNTU_INSTANCE_ID" != "None" ]; then
        echo "  ✅ Ubuntu instance: $UBUNTU_INSTANCE_ID"
        echo "$UBUNTU_INSTANCE_ID" > /tmp/inspector-demo-ubuntu-instance
    else
        echo "  ❌ Failed to launch Ubuntu instance"
    fi
}

# Function to create ECR repository
create_ecr_repository() {
    echo "🔄 Creating ECR repository..."
    
    REPO_NAME="inspector-demo-vulnerable"
    
    # Check if repository already exists
    EXISTING_REPO=$(aws ecr describe-repositories --repository-names "$REPO_NAME" --query 'repositories[0].repositoryUri' --output text 2>/dev/null || echo "None")
    
    if [ "$EXISTING_REPO" != "None" ]; then
        echo "  ⚠️  ECR repository already exists, using existing: $EXISTING_REPO"
        REPO_URI="$EXISTING_REPO"
    else
        # Create repository
        REPO_URI=$(aws ecr create-repository \
            --repository-name "$REPO_NAME" \
            --image-scanning-configuration scanOnPush=true \
            --tags Key=Purpose,Value="Inspector Demo",Key=Vulnerable,Value="true" \
            --query 'repository.repositoryUri' --output text 2>&1)
        
        if [[ "$REPO_URI" == *"error"* ]] || [[ "$REPO_URI" == *"Error"* ]] || [ -z "$REPO_URI" ]; then
            echo "  ⚠️  ECR repository creation failed: $REPO_URI"
            echo "  ⚠️  Continuing without ECR repository - container scanning will be skipped"
            echo "None" > /tmp/inspector-demo-ecr-uri
            return 0
        else
            echo "  ✅ ECR repository created: $REPO_URI"
        fi
    fi
    
    echo "$REPO_URI" > /tmp/inspector-demo-ecr-uri
}

# Function to create Lambda function
create_lambda_function() {
    echo "🔄 Creating vulnerable Lambda function..."
    
    LAMBDA_ROLE_NAME="inspector-demo-lambda-role"
    FUNCTION_NAME="inspector-demo-vulnerable-function"
    
    # Check if Lambda role already exists
    EXISTING_LAMBDA_ROLE=$(aws iam get-role --role-name "$LAMBDA_ROLE_NAME" --query 'Role.RoleName' --output text 2>/dev/null || echo "None")
    
    if [ "$EXISTING_LAMBDA_ROLE" != "None" ]; then
        echo "  ⚠️  Lambda IAM role already exists: $LAMBDA_ROLE_NAME"
    else
        # Create Lambda role
        cat > /tmp/lambda-trust-policy.json << 'EOF'
{
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
}
EOF
        
        aws iam create-role \
            --role-name "$LAMBDA_ROLE_NAME" \
            --assume-role-policy-document file:///tmp/lambda-trust-policy.json \
            --tags Key=Purpose,Value="Inspector Demo" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "  ✅ Lambda IAM role created: $LAMBDA_ROLE_NAME"
        else
            echo "  ⚠️  Lambda IAM role creation failed, may already exist"
        fi
    fi
    
    # Attach policy (idempotent)
    aws iam attach-role-policy \
        --role-name "$LAMBDA_ROLE_NAME" \
        --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 2>/dev/null || echo "  ⚠️  Policy may already be attached"
    
    # Wait for role to be available
    sleep 10
    
    # Check if Lambda function already exists
    EXISTING_FUNCTION=$(aws lambda get-function --function-name "$FUNCTION_NAME" --query 'Configuration.FunctionArn' --output text 2>/dev/null || echo "None")
    
    if [ "$EXISTING_FUNCTION" != "None" ]; then
        echo "  ⚠️  Lambda function already exists, using existing: $EXISTING_FUNCTION"
        LAMBDA_ARN="$EXISTING_FUNCTION"
    else
        # Create Lambda function code
        cat > /tmp/lambda_function.py << 'EOF'
import json
import requests
import urllib3
from datetime import datetime

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def lambda_handler(event, context):
    try:
        response = requests.get("https://httpbin.org/json", verify=False, timeout=30)
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Vulnerable Lambda function for Inspector demo',
                'timestamp': datetime.now().isoformat(),
                'vulnerable_packages': {
                    'requests': requests.__version__,
                    'urllib3': urllib3.__version__
                }
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
EOF
        
        # Create requirements.txt
        cat > /tmp/requirements.txt << 'EOF'
requests==2.25.1
urllib3==1.26.5
Pillow==8.3.2
Django==3.2.13
Flask==2.0.3
EOF
        
        # Create deployment package
        cd /tmp
        mkdir -p lambda-package
        cp lambda_function.py lambda-package/
        cp requirements.txt lambda-package/
        cd lambda-package
        pip3 install -r requirements.txt -t . 2>/dev/null || echo "  ⚠️  Some packages may not install"
        zip -r ../vulnerable-lambda.zip . >/dev/null 2>&1
        cd ..
        
        # Get Lambda role ARN
        LAMBDA_ROLE_ARN=$(aws iam get-role --role-name "$LAMBDA_ROLE_NAME" --query 'Role.Arn' --output text)
        
        # Create Lambda function
        LAMBDA_ARN=$(aws lambda create-function \
            --function-name "$FUNCTION_NAME" \
            --runtime python3.8 \
            --role "$LAMBDA_ROLE_ARN" \
            --handler lambda_function.lambda_handler \
            --zip-file fileb://vulnerable-lambda.zip \
            --timeout 30 \
            --tags Purpose="Inspector Demo",Vulnerable="true" \
            --query 'FunctionArn' --output text 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$LAMBDA_ARN" ]; then
            echo "  ✅ Lambda function created: $LAMBDA_ARN"
        else
            echo "❌ Failed to create Lambda function"
            exit 1
        fi
    fi
    
    echo "$LAMBDA_ARN" > /tmp/inspector-demo-lambda-arn
}

# Function to build and push vulnerable container image
build_and_push_container() {
    echo "🔄 Building and pushing vulnerable container image..."
    
    REPO_URI=$(cat /tmp/inspector-demo-ecr-uri)
    
    if [ "$REPO_URI" = "None" ] || [ -z "$REPO_URI" ]; then
        echo "  ⚠️  No ECR repository available - skipping container build"
        return 0
    fi
    
    # Create Dockerfile
    cat > /tmp/Dockerfile << 'EOF'
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    apache2 \
    openssl \
    curl \
    python3 \
    python3-pip \
    nodejs \
    npm \
    php7.4 \
    && pip3 install requests==2.25.1 urllib3==1.26.5 Pillow==8.3.2 \
    && npm install -g lodash@4.17.20 express@4.17.1
EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
EOF
    
    # Build and push image
    cd /tmp
    if aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REPO_URI" 2>/dev/null; then
        if docker build -t inspector-demo-vulnerable . 2>/dev/null; then
            docker tag inspector-demo-vulnerable:latest "$REPO_URI:vulnerable"
            if docker push "$REPO_URI:vulnerable" 2>/dev/null; then
                echo "  ✅ Container image pushed: $REPO_URI:vulnerable"
            else
                echo "  ⚠️  Failed to push container image - continuing without it"
            fi
        else
            echo "  ⚠️  Failed to build container image - continuing without it"
        fi
    else
        echo "  ⚠️  Failed to login to ECR - continuing without container image"
    fi
}

# Function to display deployment summary
display_summary() {
    echo ""
    echo "🎉 Vulnerable resources deployment completed!"
    echo "=============================================="
    
    if [ -f /tmp/inspector-demo-al2-instance ]; then
        AL2_INSTANCE=$(cat /tmp/inspector-demo-al2-instance)
        echo "📋 Amazon Linux 2 Instance: $AL2_INSTANCE"
    fi
    
    if [ -f /tmp/inspector-demo-ubuntu-instance ]; then
        UBUNTU_INSTANCE=$(cat /tmp/inspector-demo-ubuntu-instance)
        echo "📋 Ubuntu Instance: $UBUNTU_INSTANCE"
    fi
    
    if [ -f /tmp/inspector-demo-lambda-arn ]; then
        LAMBDA_ARN=$(cat /tmp/inspector-demo-lambda-arn)
        echo "📋 Lambda Function: $LAMBDA_ARN"
    fi
    
    if [ -f /tmp/inspector-demo-ecr-uri ]; then
        ECR_URI=$(cat /tmp/inspector-demo-ecr-uri)
        echo "📋 ECR Repository: $ECR_URI"
    fi
    
    echo ""
    echo "⏰ Wait Time: Allow 2-4 hours for Inspector to scan all resources"
    echo "🔍 Inspector Console: https://$REGION.console.aws.amazon.com/inspector/v2/home"
    echo "🧹 Cleanup: Run ./cleanup-vulnerable-resources.sh when done"
    echo ""
    echo "⚠️  WARNING: These resources contain deliberate vulnerabilities!"
    echo "   Only use for demonstration purposes and clean up promptly."
}

# Main execution
main() {
    echo "🚀 AWS Inspector Demo - Vulnerable Resources Deployment"
    echo "======================================================"
    
    check_aws_cli
    get_aws_info
    
    echo ""
    create_security_group
    
    echo ""
    create_ec2_iam_role
    
    echo ""
    get_vulnerable_amis
    
    echo ""
    create_user_data_scripts
    
    echo ""
    launch_ec2_instances
    
    echo ""
    create_ecr_repository
    
    echo ""
    create_lambda_function
    
    # Skip container build if Docker is not available
    if command -v docker &> /dev/null; then
        echo ""
        build_and_push_container
    else
        echo ""
        echo "⚠️  Docker not found - skipping container image creation"
        echo "   Install Docker and run: docker build -t vulnerable . && docker push"
    fi
    
    display_summary
}

# Run main function
main
