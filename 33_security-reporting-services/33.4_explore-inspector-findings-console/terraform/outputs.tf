# Outputs for Inspector Demo Resources

output "vulnerable_instances" {
  description = "Information about the vulnerable EC2 instances"
  value = {
    amazon_linux_2 = {
      instance_id   = aws_instance.vulnerable_al2.id
      public_ip     = aws_instance.vulnerable_al2.public_ip
      private_ip    = aws_instance.vulnerable_al2.private_ip
      ami_id        = aws_instance.vulnerable_al2.ami
      instance_type = aws_instance.vulnerable_al2.instance_type
    }
    ubuntu = {
      instance_id   = aws_instance.vulnerable_ubuntu.id
      public_ip     = aws_instance.vulnerable_ubuntu.public_ip
      private_ip    = aws_instance.vulnerable_ubuntu.private_ip
      ami_id        = aws_instance.vulnerable_ubuntu.ami
      instance_type = aws_instance.vulnerable_ubuntu.instance_type
    }
  }
}

output "ecr_repository" {
  description = "ECR repository information"
  value = {
    repository_name = aws_ecr_repository.vulnerable_repo.name
    repository_url  = aws_ecr_repository.vulnerable_repo.repository_url
    registry_id     = aws_ecr_repository.vulnerable_repo.registry_id
  }
}

output "lambda_function" {
  description = "Lambda function information"
  value = {
    function_name = aws_lambda_function.vulnerable_lambda.function_name
    function_arn  = aws_lambda_function.vulnerable_lambda.arn
    runtime       = aws_lambda_function.vulnerable_lambda.runtime
  }
}

output "security_group" {
  description = "Security group information"
  value = {
    id          = aws_security_group.vulnerable_sg.id
    name        = aws_security_group.vulnerable_sg.name
    description = aws_security_group.vulnerable_sg.description
  }
}

output "inspector_scan_commands" {
  description = "Commands to trigger Inspector scans"
  value = {
    ecr_push_command = "docker tag your-image:latest ${aws_ecr_repository.vulnerable_repo.repository_url}:vulnerable && docker push ${aws_ecr_repository.vulnerable_repo.repository_url}:vulnerable"
    inspector_console_url = "https://${data.aws_region.current.name}.console.aws.amazon.com/inspector/v2/home?region=${data.aws_region.current.name}#/findings"
  }
}

output "demo_information" {
  description = "Information for the Inspector demo"
  value = {
    region = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
    resources_created = {
      ec2_instances = 2
      lambda_functions = 1
      ecr_repositories = 1
      security_groups = 1
    }
    wait_time = "Allow 2-4 hours for Inspector to scan all resources and generate findings"
    cleanup_command = "terraform destroy -auto-approve"
  }
}
