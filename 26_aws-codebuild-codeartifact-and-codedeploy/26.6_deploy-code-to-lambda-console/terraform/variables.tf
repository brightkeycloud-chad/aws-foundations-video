variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "codedeploy-lambda-demo"
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "codedeploy-lambda-demo"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project = "CodeDeploy Lambda Demo"
    Environment = "Demo"
  }
}
