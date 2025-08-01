variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the launch template"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium",
      "t2.micro", "t2.small", "t2.medium"
    ], var.instance_type)
    error_message = "Instance type must be a valid t2 or t3 instance type suitable for demonstrations."
  }
}

variable "volume_size" {
  description = "EBS root volume size in GB (minimum 30GB for Amazon Linux 2023)"
  type        = number
  default     = 30
  
  validation {
    condition     = var.volume_size >= 30
    error_message = "Volume size must be at least 30GB for Amazon Linux 2023 AMI."
  }
}

variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
  default     = "auto-scaling-group-demo"
}
