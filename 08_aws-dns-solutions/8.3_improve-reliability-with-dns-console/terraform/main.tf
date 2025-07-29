terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider for us-east-2 (primary region)
provider "aws" {
  alias  = "primary"
  region = "us-east-2"
}

# Configure the AWS Provider for us-west-2 (secondary region)
provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
}

# Data source for latest Amazon Linux 2023 AMI in us-east-2
data "aws_ami" "amazon_linux_primary" {
  provider    = aws.primary
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for latest Amazon Linux 2023 AMI in us-west-2
data "aws_ami" "amazon_linux_secondary" {
  provider    = aws.secondary
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for default VPC in us-east-2
data "aws_vpc" "default_primary" {
  provider = aws.primary
  default  = true
}

# Data source for default VPC in us-west-2
data "aws_vpc" "default_secondary" {
  provider = aws.secondary
  default  = true
}

# Data source for first available subnet in us-east-2
data "aws_subnets" "default_primary" {
  provider = aws.primary
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_primary.id]
  }
}

# Data source for first available subnet in us-west-2
data "aws_subnets" "default_secondary" {
  provider = aws.secondary
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_secondary.id]
  }
}

# IAM role for EC2 instances to use SSM Session Manager
resource "aws_iam_role" "ec2_ssm_role" {
  provider = aws.primary
  name     = "EC2-SSM-Role"

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
    Name        = "EC2-SSM-Role"
    Purpose     = "DNS-Reliability-Demo"
    Environment = "Training"
  }
}

# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  provider   = aws.primary
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile for the IAM role
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  provider = aws.primary
  name     = "EC2-SSM-Profile"
  role     = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name        = "EC2-SSM-Profile"
    Purpose     = "DNS-Reliability-Demo"
    Environment = "Training"
  }
}

# Security group for web servers in us-east-2
resource "aws_security_group" "web_sg_primary" {
  provider    = aws.primary
  name        = "dns-demo-web-sg-primary"
  description = "Security group for DNS reliability demo web server - Primary"
  vpc_id      = data.aws_vpc.default_primary.id

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access for web server"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

  tags = {
    Name        = "dns-demo-web-sg-primary"
    Purpose     = "DNS-Reliability-Demo"
    Environment = "Training"
    Region      = "us-east-2"
  }
}

# Security group for web servers in us-west-2
resource "aws_security_group" "web_sg_secondary" {
  provider    = aws.secondary
  name        = "dns-demo-web-sg-secondary"
  description = "Security group for DNS reliability demo web server - Secondary"
  vpc_id      = data.aws_vpc.default_secondary.id

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access for web server"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

  tags = {
    Name        = "dns-demo-web-sg-secondary"
    Purpose     = "DNS-Reliability-Demo"
    Environment = "Training"
    Region      = "us-west-2"
  }
}

# User data script to install and configure web server
locals {
  user_data_primary = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple HTML page identifying this as the primary server
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>DNS Reliability Demo - Primary Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #e8f5e8; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background-color: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #2e7d32; text-align: center; margin-bottom: 30px; }
        .status { background-color: #4caf50; color: white; padding: 10px; border-radius: 5px; text-align: center; margin: 20px 0; }
        .info { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .region { font-weight: bold; color: #1976d2; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🌐 DNS Reliability Demonstration</h1>
        <div class="status">✅ PRIMARY SERVER - ACTIVE</div>
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Role:</strong> Primary Web Server</p>
            <p><strong>Region:</strong> <span class="region">US East 2 (Ohio)</span></p>
            <p><strong>Instance Type:</strong> t4g.micro (ARM64)</p>
            <p><strong>Purpose:</strong> Route 53 Failover Demo</p>
        </div>
        <div class="info">
            <h3>Health Check Endpoint:</h3>
            <p>This page serves as the health check endpoint for Route 53.</p>
            <p>If you can see this page, the primary server is healthy and operational.</p>
        </div>
        <div class="info">
            <h3>Failover Behavior:</h3>
            <p>When this server becomes unhealthy, Route 53 will automatically redirect traffic to the secondary server in US West 2.</p>
        </div>
    </div>
</body>
</html>
HTML

# Create a health check endpoint
cat > /var/www/html/health << 'HEALTH'
OK - Primary Server Healthy
HEALTH

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod 755 /var/www/html/
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health
EOF
  )

  user_data_secondary = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple HTML page identifying this as the secondary server
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>DNS Reliability Demo - Secondary Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #fff3e0; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background-color: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #f57c00; text-align: center; margin-bottom: 30px; }
        .status { background-color: #ff9800; color: white; padding: 10px; border-radius: 5px; text-align: center; margin: 20px 0; }
        .info { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .region { font-weight: bold; color: #1976d2; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🌐 DNS Reliability Demonstration</h1>
        <div class="status">🔄 SECONDARY SERVER - STANDBY</div>
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Role:</strong> Secondary Web Server</p>
            <p><strong>Region:</strong> <span class="region">US West 2 (Oregon)</span></p>
            <p><strong>Instance Type:</strong> t4g.micro (ARM64)</p>
            <p><strong>Purpose:</strong> Route 53 Failover Demo</p>
        </div>
        <div class="info">
            <h3>Failover Status:</h3>
            <p>🎯 <strong>You are now seeing the secondary server!</strong></p>
            <p>This means the primary server in US East 2 is currently unhealthy or unavailable.</p>
            <p>Route 53 has automatically failed over to this backup server.</p>
        </div>
        <div class="info">
            <h3>Automatic Recovery:</h3>
            <p>When the primary server becomes healthy again, Route 53 will automatically redirect traffic back to the primary server.</p>
        </div>
    </div>
</body>
</html>
HTML

# Create a health check endpoint
cat > /var/www/html/health << 'HEALTH'
OK - Secondary Server Healthy
HEALTH

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod 755 /var/www/html/
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health
EOF
  )
}

# Primary EC2 instance in us-east-2
resource "aws_instance" "primary_web_server" {
  provider                    = aws.primary
  ami                        = data.aws_ami.amazon_linux_primary.id
  instance_type              = "t4g.micro"
  subnet_id                  = data.aws_subnets.default_primary.ids[0]
  vpc_security_group_ids     = [aws_security_group.web_sg_primary.id]
  iam_instance_profile       = aws_iam_instance_profile.ec2_ssm_profile.name
  user_data                  = local.user_data_primary
  associate_public_ip_address = true

  tags = {
    Name        = "DNS-Demo-Primary-Web-Server"
    Purpose     = "DNS-Reliability-Demo"
    Environment = "Training"
    Region      = "us-east-2"
    Role        = "Primary"
  }
}

# Secondary EC2 instance in us-west-2
resource "aws_instance" "secondary_web_server" {
  provider                    = aws.secondary
  ami                        = data.aws_ami.amazon_linux_secondary.id
  instance_type              = "t4g.micro"
  subnet_id                  = data.aws_subnets.default_secondary.ids[0]
  vpc_security_group_ids     = [aws_security_group.web_sg_secondary.id]
  iam_instance_profile       = aws_iam_instance_profile.ec2_ssm_profile.name
  user_data                  = local.user_data_secondary
  associate_public_ip_address = true

  tags = {
    Name        = "DNS-Demo-Secondary-Web-Server"
    Purpose     = "DNS-Reliability-Demo"
    Environment = "Training"
    Region      = "us-west-2"
    Role        = "Secondary"
  }
}
