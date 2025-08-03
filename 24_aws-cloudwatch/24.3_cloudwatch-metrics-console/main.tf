# CloudWatch Metrics Console Demo - EC2 Instance with Detailed Monitoring
# This template creates an EC2 instance in us-west-2 with detailed monitoring enabled

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data source to get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source to get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get default VPC subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group for the EC2 instance
resource "aws_security_group" "cloudwatch_demo_sg" {
  name_prefix = "cloudwatch-demo-"
  description = "Security group for CloudWatch metrics demo EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # Allow SSH access (optional - for troubleshooting)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access (for web server demo)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cloudwatch-demo-sg"
    Purpose     = "CloudWatch Metrics Demo"
    Environment = "Training"
  }
}

# IAM role for EC2 instance to access CloudWatch and SSM
resource "aws_iam_role" "cloudwatch_demo_role" {
  name = "cloudwatch-demo-ec2-role"

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
    Name        = "cloudwatch-demo-ec2-role"
    Purpose     = "CloudWatch Metrics Demo"
    Environment = "Training"
  }
}

# Attach AWS managed policy for SSM Session Manager
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.cloudwatch_demo_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach AWS managed policy for CloudWatch Agent
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
  role       = aws_iam_role.cloudwatch_demo_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Custom IAM policy for additional CloudWatch permissions
resource "aws_iam_role_policy" "cloudwatch_demo_policy" {
  name = "cloudwatch-demo-policy"
  role = aws_iam_role.cloudwatch_demo_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:PutDashboard",
          "cloudwatch:GetDashboard",
          "cloudwatch:ListDashboards",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM instance profile
resource "aws_iam_instance_profile" "cloudwatch_demo_profile" {
  name = "cloudwatch-demo-profile"
  role = aws_iam_role.cloudwatch_demo_role.name
}

# User data script loaded from external file
locals {
  user_data = base64encode(file("${path.module}/user-data.sh"))
}

# EC2 Instance with detailed monitoring enabled
resource "aws_instance" "cloudwatch_demo" {
  ami                     = data.aws_ami.amazon_linux_2023.id
  instance_type           = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.cloudwatch_demo_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]
  iam_instance_profile   = aws_iam_instance_profile.cloudwatch_demo_profile.name
  
  # Enable detailed monitoring (1-minute intervals instead of 5-minute)
  monitoring = true
  
  # User data for initial setup
  user_data = local.user_data

  # Root volume configuration
  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
    
    tags = {
      Name        = "cloudwatch-demo-root-volume"
      Purpose     = "CloudWatch Metrics Demo"
      Environment = "Training"
    }
  }

  tags = {
    Name        = "cloudwatch-metrics-demo"
    Purpose     = "CloudWatch Metrics Console Demonstration"
    Environment = "Training"
    Project     = "AWS Foundations Video Training"
  }
}

# CloudWatch Dashboard for the demo instance
resource "aws_cloudwatch_dashboard" "demo_dashboard" {
  dashboard_name = "CloudWatch-Metrics-Demo-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.cloudwatch_demo.id],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 Instance Metrics - CPU and Network"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "DiskReadOps", "InstanceId", aws_instance.cloudwatch_demo.id],
            [".", "DiskWriteOps", ".", "."],
            [".", "DiskReadBytes", ".", "."],
            [".", "DiskWriteBytes", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 Instance Metrics - Disk I/O"
          period  = 300
        }
      }
    ]
  })
}
