# Variables for DNS Performance Demonstration Infrastructure

variable "regions" {
  description = "AWS regions for the performance demonstration"
  type = object({
    us_east_1    = string  # For IAM resources
    us_east_2    = string  # For EC2 instances
    us_west_2    = string
    eu_central_1 = string
  })
  default = {
    us_east_1    = "us-east-1"
    us_east_2    = "us-east-2"
    us_west_2    = "us-west-2"
    eu_central_1 = "eu-central-1"
  }
  
  validation {
    condition = alltrue([
      can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.regions.us_east_1)),
      can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.regions.us_east_2)),
      can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.regions.us_west_2)),
      can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.regions.eu_central_1))
    ])
    error_message = "All regions must be valid AWS region format (e.g., us-east-2)."
  }
}

variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t4g.micro"
  
  validation {
    condition     = can(regex("^t4g\\.", var.instance_type))
    error_message = "Instance type must be ARM-based (t4g family) for this demonstration."
  }
}

variable "architecture" {
  description = "CPU architecture for the AMI"
  type        = string
  default     = "arm64"
  
  validation {
    condition     = contains(["arm64", "x86_64"], var.architecture)
    error_message = "Architecture must be either 'arm64' or 'x86_64'."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Purpose     = "DNS-Performance-Demo"
    Environment = "Training"
    Project     = "AWS-Foundations-Video"
    ManagedBy   = "Terraform"
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2 instances"
  type        = bool
  default     = false
}

variable "web_server_port" {
  description = "Port for the web server"
  type        = number
  default     = 80
  
  validation {
    condition     = var.web_server_port > 0 && var.web_server_port <= 65535
    error_message = "Web server port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "Path for health check endpoint"
  type        = string
  default     = "/health"
  
  validation {
    condition     = can(regex("^/", var.health_check_path))
    error_message = "Health check path must start with '/'."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the web servers"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  
  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid CIDR notation."
  }
}

variable "iam_role_name" {
  description = "Name for the IAM role used by EC2 instances"
  type        = string
  default     = "EC2-SSM-Role-Performance-Demo"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.iam_role_name))
    error_message = "IAM role name must contain only alphanumeric characters and +=,.@_- characters."
  }
}

variable "instance_profile_name" {
  description = "Name for the IAM instance profile"
  type        = string
  default     = "EC2-SSM-Profile-Performance-Demo"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.instance_profile_name))
    error_message = "Instance profile name must contain only alphanumeric characters and +=,.@_- characters."
  }
}

variable "enable_health_checks" {
  description = "Enable health checks for Route 53 routing policies"
  type        = bool
  default     = true
}

variable "ttl_seconds" {
  description = "TTL in seconds for DNS records"
  type        = number
  default     = 300
  
  validation {
    condition     = var.ttl_seconds >= 60 && var.ttl_seconds <= 86400
    error_message = "TTL must be between 60 seconds and 86400 seconds (24 hours)."
  }
}
