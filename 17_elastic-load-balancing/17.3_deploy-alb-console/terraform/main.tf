terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider for us-west-2
provider "aws" {
  region = var.aws_region
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = [var.architecture]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for subnets in different AZs
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  
  filter {
    name   = "availability-zone"
    values = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  }
}

# Get specific subnet information for each AZ
data "aws_subnet" "az_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  
  filter {
    name   = "availability-zone"
    values = [data.aws_availability_zones.available.names[0]]
  }
}

data "aws_subnet" "az_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  
  filter {
    name   = "availability-zone"
    values = [data.aws_availability_zones.available.names[1]]
  }
}

# IAM role for EC2 instances to use SSM Session Manager
resource "aws_iam_role" "ec2_ssm_role" {
  name = var.iam_role_name

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

  tags = merge(var.common_tags, {
    Name = var.iam_role_name
  })
}

# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile for the IAM role
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.ec2_ssm_role.name

  tags = merge(var.common_tags, {
    Name = var.instance_profile_name
  })
}

# Security group for web servers
resource "aws_security_group" "web_sg" {
  name        = "alb-demo-web-sg"
  description = "Security group for ALB demo web servers"
  vpc_id      = data.aws_vpc.default.id

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTP access for web server"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTPS access for web server"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "alb-demo-web-sg"
  })
}

# User data script for web server in AZ-A
locals {
  user_data_web_server_a = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create a simple HTML page identifying this web server
cat > /var/www/html/index.html << HTML
<!DOCTYPE html>
<html>
<head>
    <title>ALB Demo - Web Server A</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #e3f2fd; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background-color: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #1976d2; text-align: center; margin-bottom: 30px; }
        .status { background-color: #2196f3; color: white; padding: 10px; border-radius: 5px; text-align: center; margin: 20px 0; }
        .info { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .server-id { font-weight: bold; color: #d32f2f; font-size: 1.2em; }
        .az { font-weight: bold; color: #388e3c; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🚀 Application Load Balancer Demonstration</h1>
        <div class="status">✅ WEB SERVER A - ACTIVE</div>
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Server ID:</strong> <span class="server-id">WEB-SERVER-A</span></p>
            <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
            <p><strong>Private IP:</strong> $PRIVATE_IP</p>
            <p><strong>Availability Zone:</strong> <span class="az">$AZ</span></p>
            <p><strong>Region:</strong> $REGION</p>
            <p><strong>Instance Type:</strong> ${var.instance_type}</p>
        </div>
        <div class="info">
            <h3>Load Balancer Demo:</h3>
            <p>🎯 <strong>You are connected to Web Server A!</strong></p>
            <p>This server is running in Availability Zone A and is one of the targets behind the Application Load Balancer.</p>
            <p>Refresh this page multiple times to see traffic distributed between different servers.</p>
        </div>
        <div class="info">
            <h3>Health Check Status:</h3>
            <p>This page serves as the health check endpoint for the ALB target group.</p>
            <p>The load balancer continuously monitors this endpoint to ensure the server is healthy.</p>
        </div>
        <div class="info">
            <p><strong>Timestamp:</strong> $(date)</p>
        </div>
    </div>
</body>
</html>
HTML

# Create a health check endpoint
cat > /var/www/html/health << 'HEALTH'
OK - Web Server A Healthy
HEALTH

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod 755 /var/www/html/
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health
EOF
  )

  user_data_web_server_b = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create a simple HTML page identifying this web server
cat > /var/www/html/index.html << HTML
<!DOCTYPE html>
<html>
<head>
    <title>ALB Demo - Web Server B</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f3e5f5; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background-color: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #7b1fa2; text-align: center; margin-bottom: 30px; }
        .status { background-color: #9c27b0; color: white; padding: 10px; border-radius: 5px; text-align: center; margin: 20px 0; }
        .info { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .server-id { font-weight: bold; color: #d32f2f; font-size: 1.2em; }
        .az { font-weight: bold; color: #388e3c; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🚀 Application Load Balancer Demonstration</h1>
        <div class="status">✅ WEB SERVER B - ACTIVE</div>
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Server ID:</strong> <span class="server-id">WEB-SERVER-B</span></p>
            <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
            <p><strong>Private IP:</strong> $PRIVATE_IP</p>
            <p><strong>Availability Zone:</strong> <span class="az">$AZ</span></p>
            <p><strong>Region:</strong> $REGION</p>
            <p><strong>Instance Type:</strong> ${var.instance_type}</p>
        </div>
        <div class="info">
            <h3>Load Balancer Demo:</h3>
            <p>🎯 <strong>You are connected to Web Server B!</strong></p>
            <p>This server is running in Availability Zone B and is one of the targets behind the Application Load Balancer.</p>
            <p>Refresh this page multiple times to see traffic distributed between different servers.</p>
        </div>
        <div class="info">
            <h3>Health Check Status:</h3>
            <p>This page serves as the health check endpoint for the ALB target group.</p>
            <p>The load balancer continuously monitors this endpoint to ensure the server is healthy.</p>
        </div>
        <div class="info">
            <p><strong>Timestamp:</strong> $(date)</p>
        </div>
    </div>
</body>
</html>
HTML

# Create a health check endpoint
cat > /var/www/html/health << 'HEALTH'
OK - Web Server B Healthy
HEALTH

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod 755 /var/www/html/
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health
EOF
  )
}

# Web Server A in first availability zone
resource "aws_instance" "web_server_a" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.az_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  user_data                   = local.user_data_web_server_a
  associate_public_ip_address = true
  monitoring                  = var.enable_detailed_monitoring

  tags = merge(var.common_tags, {
    Name = "ALB-Demo-Web-Server-A"
    Role = "WebServer"
    Zone = "A"
  })
}

# Web Server B in second availability zone
resource "aws_instance" "web_server_b" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.az_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  user_data                   = local.user_data_web_server_b
  associate_public_ip_address = true
  monitoring                  = var.enable_detailed_monitoring

  tags = merge(var.common_tags, {
    Name = "ALB-Demo-Web-Server-B"
    Role = "WebServer"
    Zone = "B"
  })
}
