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

# Data source for latest Amazon Linux 2023 AMI (x86_64)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
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

# Data source for default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Security group for Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "asg-demo-alb-sg"
  description = "Security group for Auto Scaling Group demo ALB"
  vpc_id      = data.aws_vpc.default.id

  # HTTP access from internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from internet"
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
    Name        = "asg-demo-alb-sg"
    Purpose     = "Auto-Scaling-Group-Demo"
    Environment = "Training"
  }
}

# Security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "asg-demo-ec2-sg"
  description = "Security group for Auto Scaling Group demo EC2 instances"
  vpc_id      = data.aws_vpc.default.id

  # HTTP access from ALB only
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "HTTP access from ALB"
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
    Name        = "asg-demo-ec2-sg"
    Purpose     = "Auto-Scaling-Group-Demo"
    Environment = "Training"
  }
}

# IAM role for EC2 instances to use SSM Session Manager
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ASG-Demo-EC2-SSM-Role"

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
    Name        = "ASG-Demo-EC2-SSM-Role"
    Purpose     = "Auto-Scaling-Group-Demo"
    Environment = "Training"
  }
}

# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile for the IAM role
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ASG-Demo-EC2-SSM-Profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name        = "ASG-Demo-EC2-SSM-Profile"
    Purpose     = "Auto-Scaling-Group-Demo"
    Environment = "Training"
  }
}

# User data script for web server setup with IMDSv2 support
locals {
  user_data = base64encode(file("${path.module}/user-data.sh"))
}

# Launch template for Auto Scaling Group
resource "aws_launch_template" "asg_demo_template" {
  name        = "asg-demo-launch-template"
  description = "Launch template for Auto Scaling Group demonstration"

  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # Security group configuration for EC2 instances
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # IAM instance profile for SSM access
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_profile.name
  }

  # User data script for web server setup
  user_data = local.user_data

  # Block device mapping - must be >= 30GB for Amazon Linux 2023 AMI
  # Alternative: Remove this entire block to use AMI default settings
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.volume_size
      volume_type          = "gp3"
      delete_on_termination = true
      encrypted            = true
    }
  }

  # Monitoring configuration
  monitoring {
    enabled = true
  }

  # Instance metadata service configuration (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "ASG-Demo-Instance"
      Purpose     = "Auto-Scaling-Group-Demo"
      Environment = "Training"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "ASG-Demo-Volume"
      Purpose     = "Auto-Scaling-Group-Demo"
      Environment = "Training"
    }
  }

  tags = {
    Name        = "asg-demo-launch-template"
    Purpose     = "Auto-Scaling-Group-Demo"
    Environment = "Training"
  }
}

# Application Load Balancer
resource "aws_lb" "asg_demo_alb" {
  name               = "asg-demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false

  tags = {
    Name        = "asg-demo-alb"
    Purpose     = "Auto-Scaling-Group-Demo"
    Environment = "Training"
  }
}

# Target group for the ALB
resource "aws_lb_target_group" "asg_demo_tg" {
  name     = "asg-demo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name        = "asg-demo-tg"
    Purpose     = "Auto-Scaling-Group-Demo"
    Environment = "Training"
  }
}

# ALB Listener
resource "aws_lb_listener" "asg_demo_listener" {
  load_balancer_arn = aws_lb.asg_demo_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_demo_tg.arn
  }

  tags = {
    Name        = "asg-demo-listener"
    Purpose     = "Auto-Scaling-Group-Demo"
    Environment = "Training"
  }
}
