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

# Data source to get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source to get the latest Amazon Linux 2023 ARM64 AMI
data "aws_ami" "amazon_linux_2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# IAM role for EC2 instances to use SSM Session Manager
resource "aws_iam_role" "ec2_ssm_role" {
  name_prefix = "${var.project_name}-ec2-ssm-role-"
  
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
    Name        = "${var.project_name}-ec2-ssm-role"
    Environment = var.environment
    Purpose     = "SSM Session Manager access for VPC peering demo instances"
  }
}

# Attach the AWS managed policy for SSM Session Manager
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile for the IAM role
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name_prefix = "${var.project_name}-ec2-ssm-profile-"
  role        = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name        = "${var.project_name}-ec2-ssm-profile"
    Environment = var.environment
  }
}

# VPC A - First VPC for peering demonstration
module "vpc_a" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc-a"
  cidr = var.vpc_a_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = [
    cidrsubnet(var.vpc_a_cidr, 8, 1),  # 10.0.1.0/24
    cidrsubnet(var.vpc_a_cidr, 8, 2)   # 10.0.2.0/24
  ]
  public_subnets = [
    cidrsubnet(var.vpc_a_cidr, 8, 101), # 10.0.101.0/24
    cidrsubnet(var.vpc_a_cidr, 8, 102)  # 10.0.102.0/24
  ]

  enable_nat_gateway = true
  single_nat_gateway = true  # Only one NAT Gateway in primary AZ
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name        = "${var.project_name}-vpc-a"
    Environment = var.environment
    Purpose     = "VPC Peering Demo"
  }
}

# VPC B - Second VPC for peering demonstration
module "vpc_b" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc-b"
  cidr = var.vpc_b_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = [
    cidrsubnet(var.vpc_b_cidr, 8, 1),  # 10.1.1.0/24
    cidrsubnet(var.vpc_b_cidr, 8, 2)   # 10.1.2.0/24
  ]
  public_subnets = [
    cidrsubnet(var.vpc_b_cidr, 8, 101), # 10.1.101.0/24
    cidrsubnet(var.vpc_b_cidr, 8, 102)  # 10.1.102.0/24
  ]

  enable_nat_gateway = true
  single_nat_gateway = true  # Only one NAT Gateway in primary AZ
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name        = "${var.project_name}-vpc-b"
    Environment = var.environment
    Purpose     = "VPC Peering Demo"
  }
}

# Security Group for VPC A EC2 instance
resource "aws_security_group" "vpc_a_instance_sg" {
  name_prefix = "${var.project_name}-vpc-a-instance-"
  vpc_id      = module.vpc_a.vpc_id
  description = "Security group for EC2 instance in VPC A"

  # Allow all traffic from VPC B CIDR
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_b_cidr]
    description = "Allow all TCP traffic from VPC B"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [var.vpc_b_cidr]
    description = "Allow all UDP traffic from VPC B"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_b_cidr]
    description = "Allow ICMP traffic from VPC B"
  }

  # Allow SSH from within VPC A for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_a_cidr]
    description = "Allow SSH from VPC A"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-vpc-a-instance-sg"
    Environment = var.environment
  }
}

# Security Group for VPC B EC2 instance
resource "aws_security_group" "vpc_b_instance_sg" {
  name_prefix = "${var.project_name}-vpc-b-instance-"
  vpc_id      = module.vpc_b.vpc_id
  description = "Security group for EC2 instance in VPC B"

  # Allow all traffic from VPC A CIDR
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_a_cidr]
    description = "Allow all TCP traffic from VPC A"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [var.vpc_a_cidr]
    description = "Allow all UDP traffic from VPC A"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_a_cidr]
    description = "Allow ICMP traffic from VPC A"
  }

  # Allow SSH from within VPC B for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_b_cidr]
    description = "Allow SSH from VPC B"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-vpc-b-instance-sg"
    Environment = var.environment
  }
}

# EC2 Instance in VPC A (private subnet)
resource "aws_instance" "vpc_a_instance" {
  ami                    = data.aws_ami.amazon_linux_2023_arm.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc_a.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.vpc_a_instance_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    vpc_name = "VPC-A"
  }))

  tags = {
    Name        = "${var.project_name}-vpc-a-instance"
    Environment = var.environment
    VPC         = "A"
  }
}

# EC2 Instance in VPC B (private subnet)
resource "aws_instance" "vpc_b_instance" {
  ami                    = data.aws_ami.amazon_linux_2023_arm.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc_b.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.vpc_b_instance_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    vpc_name = "VPC-B"
  }))

  tags = {
    Name        = "${var.project_name}-vpc-b-instance"
    Environment = var.environment
    VPC         = "B"
  }
}
