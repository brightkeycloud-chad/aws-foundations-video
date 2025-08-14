# Terraform configuration for creating deliberately vulnerable resources for Inspector demo
# This creates EC2 instances, Lambda functions, and ECR images with known vulnerabilities

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get the first available subnet
data "aws_subnet" "default" {
  id = data.aws_subnets.default.ids[0]
}

# Security group for EC2 instances (deliberately permissive for vulnerabilities)
resource "aws_security_group" "vulnerable_sg" {
  name_prefix = "inspector-demo-vulnerable-"
  description = "Deliberately vulnerable security group for Inspector demo"
  vpc_id      = data.aws_vpc.default.id

  # SSH access from anywhere (vulnerability)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from anywhere - VULNERABLE"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from anywhere"
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access from anywhere"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "inspector-demo-vulnerable-sg"
    Purpose     = "Inspector Demo"
    Environment = "Demo"
    Vulnerable  = "true"
  }
}

# IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name_prefix = "inspector-demo-ec2-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "inspector-demo-ec2-role"
    Purpose     = "Inspector Demo"
    Environment = "Demo"
  }
}

# IAM instance profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "inspector-demo-ec2-"
  role        = aws_iam_role.ec2_role.name
}

# Attach SSM managed instance core policy (for Inspector agent)
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Get latest Amazon Linux 2 AMI (older version for vulnerabilities)
data "aws_ami" "amazon_linux_old" {
  most_recent = false
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20220606.1-x86_64-gp2"] # Older AL2 version with known vulnerabilities
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get older Ubuntu AMI with vulnerabilities
data "aws_ami" "ubuntu_old" {
  most_recent = false
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20220610"] # Older Ubuntu 20.04
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance 1: Amazon Linux 2 with vulnerable packages
resource "aws_instance" "vulnerable_al2" {
  ami                    = data.aws_ami.amazon_linux_old.id
  instance_type          = var.instance_type
  key_name              = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]
  subnet_id             = data.aws_subnet.default.id
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name

  user_data = base64encode(templatefile("${path.module}/user_data_al2.sh", {
    region = data.aws_region.current.name
  }))

  tags = {
    Name        = "inspector-demo-vulnerable-al2"
    Purpose     = "Inspector Demo"
    Environment = "Demo"
    OS          = "Amazon Linux 2"
    Vulnerable  = "true"
  }
}

# EC2 Instance 2: Ubuntu with vulnerable packages
resource "aws_instance" "vulnerable_ubuntu" {
  ami                    = data.aws_ami.ubuntu_old.id
  instance_type          = var.instance_type
  key_name              = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]
  subnet_id             = data.aws_subnet.default.id
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name

  user_data = base64encode(templatefile("${path.module}/user_data_ubuntu.sh", {
    region = data.aws_region.current.name
  }))

  tags = {
    Name        = "inspector-demo-vulnerable-ubuntu"
    Purpose     = "Inspector Demo"
    Environment = "Demo"
    OS          = "Ubuntu 20.04"
    Vulnerable  = "true"
  }
}

# ECR Repository for vulnerable container images
resource "aws_ecr_repository" "vulnerable_repo" {
  name                 = "inspector-demo-vulnerable"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "inspector-demo-vulnerable-repo"
    Purpose     = "Inspector Demo"
    Environment = "Demo"
    Vulnerable  = "true"
  }
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name_prefix = "inspector-demo-lambda-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "inspector-demo-lambda-role"
    Purpose     = "Inspector Demo"
    Environment = "Demo"
  }
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function with vulnerable dependencies
resource "aws_lambda_function" "vulnerable_lambda" {
  filename         = "${path.module}/vulnerable_lambda.zip"
  function_name    = "inspector-demo-vulnerable-function"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.8" # Older Python runtime
  timeout         = 30

  depends_on = [data.archive_file.lambda_zip]

  tags = {
    Name        = "inspector-demo-vulnerable-lambda"
    Purpose     = "Inspector Demo"
    Environment = "Demo"
    Vulnerable  = "true"
  }
}

# Create Lambda deployment package with vulnerable dependencies
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/vulnerable_lambda.zip"
  source {
    content = templatefile("${path.module}/lambda_function.py", {
      region = data.aws_region.current.name
    })
    filename = "index.py"
  }
  source {
    content = file("${path.module}/requirements.txt")
    filename = "requirements.txt"
  }
}
