# Variables for Inspector Demo Terraform Configuration

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for vulnerable instances"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium",
      "t2.micro", "t2.small", "t2.medium"
    ], var.instance_type)
    error_message = "Instance type must be a valid t2 or t3 instance type."
  }
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access (optional)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "inspector-demo"
}

variable "create_key_pair" {
  description = "Whether to create a new key pair for EC2 instances"
  type        = bool
  default     = false
}

variable "public_key_path" {
  description = "Path to public key file for creating new key pair"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
