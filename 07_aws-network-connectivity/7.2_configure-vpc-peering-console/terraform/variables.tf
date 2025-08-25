variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "vpc-peering-demo"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "demo"
}

variable "vpc_a_cidr" {
  description = "CIDR block for VPC A"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_a_cidr, 0))
    error_message = "VPC A CIDR must be a valid IPv4 CIDR block."
  }
}

variable "vpc_b_cidr" {
  description = "CIDR block for VPC B"
  type        = string
  default     = "10.1.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_b_cidr, 0))
    error_message = "VPC B CIDR must be a valid IPv4 CIDR block."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t4g.micro"

  validation {
    condition     = can(regex("^t4g\\.", var.instance_type))
    error_message = "Instance type must be a t4g instance type for ARM architecture."
  }
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access (optional)"
  type        = string
  default     = null
}
