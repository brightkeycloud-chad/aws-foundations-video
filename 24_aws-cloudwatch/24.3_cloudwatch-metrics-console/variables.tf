# Variables for CloudWatch Metrics Console Demo

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type"
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
  
  validation {
    condition = var.key_pair_name == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]*$", var.key_pair_name))
    error_message = "Key pair name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instance"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 30
  
  validation {
    condition     = var.root_volume_size >= 30
    error_message = "Root volume size must be at least 30GB for Amazon Linux 2023 AMI."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "AWS Foundations Video Training"
    Environment = "Training"
    Purpose     = "CloudWatch Metrics Demo"
    Owner       = "Training Team"
  }
}
