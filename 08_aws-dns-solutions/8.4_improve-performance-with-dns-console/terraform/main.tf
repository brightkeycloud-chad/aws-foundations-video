terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Providers for multiple regions
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"
}

# Data sources for latest Amazon Linux 2023 AMI in each region
data "aws_ami" "amazon_linux_us_east_2" {
  provider    = aws.us_east_2
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-arm64"]
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

data "aws_ami" "amazon_linux_us_west_2" {
  provider    = aws.us_west_2
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-arm64"]
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

data "aws_ami" "amazon_linux_eu_central_1" {
  provider    = aws.eu_central_1
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

# Data sources for default VPCs in each region
data "aws_vpc" "default_us_east_2" {
  provider = aws.us_east_2
  default  = true
}

data "aws_vpc" "default_us_west_2" {
  provider = aws.us_west_2
  default  = true
}

data "aws_vpc" "default_eu_central_1" {
  provider = aws.eu_central_1
  default  = true
}

# Data sources for first available subnet in each region
data "aws_subnets" "default_us_east_2" {
  provider = aws.us_east_2
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_us_east_2.id]
  }
}

data "aws_subnets" "default_us_west_2" {
  provider = aws.us_west_2
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_us_west_2.id]
  }
}

data "aws_subnets" "default_eu_central_1" {
  provider = aws.eu_central_1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_eu_central_1.id]
  }
}

# IAM role for EC2 instances to use SSM Session Manager (created in us-east-1)
resource "aws_iam_role" "ec2_ssm_role" {
  provider = aws.us_east_1
  name     = "EC2-SSM-Role-Performance-Demo"

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
    Name        = "EC2-SSM-Role-Performance-Demo"
    Purpose     = "DNS-Performance-Demo"
    Environment = "Training"
  }
}

# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  provider   = aws.us_east_1
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile for the IAM role
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  provider = aws.us_east_1
  name     = "EC2-SSM-Profile-Performance-Demo"
  role     = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name        = "EC2-SSM-Profile-Performance-Demo"
    Purpose     = "DNS-Performance-Demo"
    Environment = "Training"
  }
}

# Security groups for web servers in each region
resource "aws_security_group" "web_sg_us_east_2" {
  provider    = aws.us_east_2
  name        = "dns-performance-demo-web-sg-us-east-2"
  description = "Security group for DNS performance demo web server - US East 2"
  vpc_id      = data.aws_vpc.default_us_east_2.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access for web server"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access for web server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "dns-performance-demo-web-sg-us-east-2"
    Purpose     = "DNS-Performance-Demo"
    Environment = "Training"
    Region      = "us-east-2"
  }
}

resource "aws_security_group" "web_sg_us_west_2" {
  provider    = aws.us_west_2
  name        = "dns-performance-demo-web-sg-us-west-2"
  description = "Security group for DNS performance demo web server - US West 2"
  vpc_id      = data.aws_vpc.default_us_west_2.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access for web server"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access for web server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "dns-performance-demo-web-sg-us-west-2"
    Purpose     = "DNS-Performance-Demo"
    Environment = "Training"
    Region      = "us-west-2"
  }
}

resource "aws_security_group" "web_sg_eu_central_1" {
  provider    = aws.eu_central_1
  name        = "dns-performance-demo-web-sg-eu-central-1"
  description = "Security group for DNS performance demo web server - EU Central 1"
  vpc_id      = data.aws_vpc.default_eu_central_1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access for web server"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access for web server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "dns-performance-demo-web-sg-eu-central-1"
    Purpose     = "DNS-Performance-Demo"
    Environment = "Training"
    Region      = "eu-central-1"
  }
}

# User data scripts for each region
locals {
  user_data_us_east_2 = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple HTML page identifying this as the US East 2 server
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>DNS Performance Demo - US East 2 Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #e3f2fd; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background-color: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #1976d2; text-align: center; margin-bottom: 30px; }
        .status { background-color: #2196f3; color: white; padding: 10px; border-radius: 5px; text-align: center; margin: 20px 0; }
        .info { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .region { font-weight: bold; color: #d32f2f; }
        .performance { background-color: #e8f5e8; padding: 10px; border-left: 4px solid #4caf50; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🚀 DNS Performance Demonstration</h1>
        <div class="status">🇺🇸 US EAST 2 (OHIO) SERVER</div>
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Region:</strong> <span class="region">US East 2 (Ohio)</span></p>
            <p><strong>Instance Type:</strong> t4g.micro (ARM64)</p>
            <p><strong>Purpose:</strong> Route 53 Latency-Based Routing Demo</p>
            <p><strong>Optimal for:</strong> Users in Eastern United States and Canada</p>
        </div>
        <div class="performance">
            <h3>⚡ Performance Optimization:</h3>
            <p>You are seeing this server because Route 53 determined it provides the lowest latency for your location.</p>
            <p>This demonstrates how DNS routing can automatically optimize performance for users worldwide.</p>
        </div>
        <div class="info">
            <h3>Routing Policies Demonstrated:</h3>
            <ul>
                <li><strong>Latency-Based Routing:</strong> Routes to lowest latency region</li>
                <li><strong>Geolocation Routing:</strong> Routes based on user's geographic location</li>
                <li><strong>Health Checks:</strong> Ensures only healthy servers receive traffic</li>
            </ul>
        </div>
    </div>
</body>
</html>
HTML

# Create a health check endpoint
cat > /var/www/html/health << 'HEALTH'
OK - US East 2 Server Healthy
HEALTH

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod 755 /var/www/html/
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health
EOF
  )

  user_data_us_west_2 = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple HTML page identifying this as the US West 2 server
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>DNS Performance Demo - US West 2 Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #fff3e0; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background-color: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #f57c00; text-align: center; margin-bottom: 30px; }
        .status { background-color: #ff9800; color: white; padding: 10px; border-radius: 5px; text-align: center; margin: 20px 0; }
        .info { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .region { font-weight: bold; color: #d32f2f; }
        .performance { background-color: #e8f5e8; padding: 10px; border-left: 4px solid #4caf50; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🚀 DNS Performance Demonstration</h1>
        <div class="status">🇺🇸 US WEST 2 (OREGON) SERVER</div>
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Region:</strong> <span class="region">US West 2 (Oregon)</span></p>
            <p><strong>Instance Type:</strong> t4g.micro (ARM64)</p>
            <p><strong>Purpose:</strong> Route 53 Latency-Based Routing Demo</p>
            <p><strong>Optimal for:</strong> Users in Western United States and Pacific regions</p>
        </div>
        <div class="performance">
            <h3>⚡ Performance Optimization:</h3>
            <p>You are seeing this server because Route 53 determined it provides the lowest latency for your location.</p>
            <p>This demonstrates how DNS routing can automatically optimize performance for users worldwide.</p>
        </div>
        <div class="info">
            <h3>Routing Policies Demonstrated:</h3>
            <ul>
                <li><strong>Latency-Based Routing:</strong> Routes to lowest latency region</li>
                <li><strong>Geolocation Routing:</strong> Routes based on user's geographic location</li>
                <li><strong>Health Checks:</strong> Ensures only healthy servers receive traffic</li>
            </ul>
        </div>
    </div>
</body>
</html>
HTML

# Create a health check endpoint
cat > /var/www/html/health << 'HEALTH'
OK - US West 2 Server Healthy
HEALTH

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod 755 /var/www/html/
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health
EOF
  )

  user_data_eu_central_1 = base64encode(<<-EOF
#!/bin/bash
yum update -y

# Check if SSM agent is installed and install if needed
echo "Checking SSM Agent installation..."
if ! rpm -qa | grep -q amazon-ssm-agent; then
    echo "SSM Agent not found. Installing..."
    yum install -y amazon-ssm-agent
else
    echo "SSM Agent already installed."
fi

# Ensure SSM agent is started and enabled
echo "Starting and enabling SSM Agent..."
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

# Verify SSM agent is running
if systemctl is-active --quiet amazon-ssm-agent; then
    echo "SSM Agent is running successfully."
else
    echo "Warning: SSM Agent failed to start. Attempting restart..."
    systemctl restart amazon-ssm-agent
    sleep 5
    if systemctl is-active --quiet amazon-ssm-agent; then
        echo "SSM Agent started successfully after restart."
    else
        echo "Error: SSM Agent failed to start after restart."
    fi
fi

# Install and configure Apache
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple HTML page identifying this as the EU Central 1 server
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>DNS Performance Demo - EU Central 1 Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f3e5f5; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background-color: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #7b1fa2; text-align: center; margin-bottom: 30px; }
        .status { background-color: #9c27b0; color: white; padding: 10px; border-radius: 5px; text-align: center; margin: 20px 0; }
        .info { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .region { font-weight: bold; color: #d32f2f; }
        .performance { background-color: #e8f5e8; padding: 10px; border-left: 4px solid #4caf50; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🚀 DNS Performance Demonstration</h1>
        <div class="status">🇪🇺 EU CENTRAL 1 (FRANKFURT) SERVER</div>
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Region:</strong> <span class="region">EU Central 1 (Frankfurt)</span></p>
            <p><strong>Instance Type:</strong> t4g.micro (ARM64)</p>
            <p><strong>Purpose:</strong> Route 53 Latency-Based Routing Demo</p>
            <p><strong>Optimal for:</strong> Users in Europe, Middle East, and Africa</p>
        </div>
        <div class="performance">
            <h3>⚡ Performance Optimization:</h3>
            <p>You are seeing this server because Route 53 determined it provides the lowest latency for your location.</p>
            <p>This demonstrates how DNS routing can automatically optimize performance for users worldwide.</p>
        </div>
        <div class="info">
            <h3>Routing Policies Demonstrated:</h3>
            <ul>
                <li><strong>Latency-Based Routing:</strong> Routes to lowest latency region</li>
                <li><strong>Geolocation Routing:</strong> Routes based on user's geographic location</li>
                <li><strong>Health Checks:</strong> Ensures only healthy servers receive traffic</li>
            </ul>
        </div>
    </div>
</body>
</html>
HTML

# Create a health check endpoint
cat > /var/www/html/health << 'HEALTH'
OK - EU Central 1 Server Healthy
HEALTH

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod 755 /var/www/html/
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health

# Log completion
echo "User data script completed successfully at $(date)" >> /var/log/user-data.log
echo "SSM Agent status: $(systemctl is-active amazon-ssm-agent)" >> /var/log/user-data.log
EOF
  )
}

# EC2 instances in each region
resource "aws_instance" "web_server_us_east_2" {
  provider                    = aws.us_east_2
  ami                        = data.aws_ami.amazon_linux_us_east_2.id
  instance_type              = var.instance_type
  subnet_id                  = data.aws_subnets.default_us_east_2.ids[0]
  vpc_security_group_ids     = [aws_security_group.web_sg_us_east_2.id]
  iam_instance_profile       = aws_iam_instance_profile.ec2_ssm_profile.name
  user_data                  = local.user_data_us_east_2
  associate_public_ip_address = true

  tags = merge(var.common_tags, {
    Name   = "DNS-Performance-Demo-US-East-2"
    Region = "us-east-2"
    Role   = "Performance-Demo-Server"
  })
}

resource "aws_instance" "web_server_us_west_2" {
  provider                    = aws.us_west_2
  ami                        = data.aws_ami.amazon_linux_us_west_2.id
  instance_type              = var.instance_type
  subnet_id                  = data.aws_subnets.default_us_west_2.ids[0]
  vpc_security_group_ids     = [aws_security_group.web_sg_us_west_2.id]
  iam_instance_profile       = aws_iam_instance_profile.ec2_ssm_profile.name
  user_data                  = local.user_data_us_west_2
  associate_public_ip_address = true

  tags = merge(var.common_tags, {
    Name   = "DNS-Performance-Demo-US-West-2"
    Region = "us-west-2"
    Role   = "Performance-Demo-Server"
  })
}

resource "aws_instance" "web_server_eu_central_1" {
  provider                    = aws.eu_central_1
  ami                        = data.aws_ami.amazon_linux_eu_central_1.id
  instance_type              = var.instance_type
  subnet_id                  = data.aws_subnets.default_eu_central_1.ids[0]
  vpc_security_group_ids     = [aws_security_group.web_sg_eu_central_1.id]
  iam_instance_profile       = aws_iam_instance_profile.ec2_ssm_profile.name
  user_data                  = local.user_data_eu_central_1
  associate_public_ip_address = true

  tags = merge(var.common_tags, {
    Name   = "DNS-Performance-Demo-EU-Central-1"
    Region = "eu-central-1"
    Role   = "Performance-Demo-Server"
  })
}
