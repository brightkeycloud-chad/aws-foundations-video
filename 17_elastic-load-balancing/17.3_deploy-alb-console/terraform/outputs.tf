# Output values for the Application Load Balancer demonstration

output "web_server_a_info" {
  description = "Information about Web Server A"
  value = {
    instance_id       = aws_instance.web_server_a.id
    public_ip         = aws_instance.web_server_a.public_ip
    private_ip        = aws_instance.web_server_a.private_ip
    public_dns        = aws_instance.web_server_a.public_dns
    availability_zone = aws_instance.web_server_a.availability_zone
    instance_type     = aws_instance.web_server_a.instance_type
    ami_id           = aws_instance.web_server_a.ami
    subnet_id        = aws_instance.web_server_a.subnet_id
  }
}

output "web_server_b_info" {
  description = "Information about Web Server B"
  value = {
    instance_id       = aws_instance.web_server_b.id
    public_ip         = aws_instance.web_server_b.public_ip
    private_ip        = aws_instance.web_server_b.private_ip
    public_dns        = aws_instance.web_server_b.public_dns
    availability_zone = aws_instance.web_server_b.availability_zone
    instance_type     = aws_instance.web_server_b.instance_type
    ami_id           = aws_instance.web_server_b.ami
    subnet_id        = aws_instance.web_server_b.subnet_id
  }
}

output "web_server_a_url" {
  description = "URL to access Web Server A directly"
  value       = "http://${aws_instance.web_server_a.public_ip}"
}

output "web_server_b_url" {
  description = "URL to access Web Server B directly"
  value       = "http://${aws_instance.web_server_b.public_ip}"
}

output "web_server_a_health_url" {
  description = "Health check endpoint for Web Server A"
  value       = "http://${aws_instance.web_server_a.public_ip}/health"
}

output "web_server_b_health_url" {
  description = "Health check endpoint for Web Server B"
  value       = "http://${aws_instance.web_server_b.public_ip}/health"
}

output "target_group_targets" {
  description = "Instance information for ALB target group registration"
  value = {
    web_server_a = {
      id         = aws_instance.web_server_a.id
      private_ip = aws_instance.web_server_a.private_ip
      port       = var.web_server_port
      az         = aws_instance.web_server_a.availability_zone
    }
    web_server_b = {
      id         = aws_instance.web_server_b.id
      private_ip = aws_instance.web_server_b.private_ip
      port       = var.web_server_port
      az         = aws_instance.web_server_b.availability_zone
    }
  }
}

output "vpc_and_subnet_info" {
  description = "VPC and subnet information for ALB configuration"
  value = {
    vpc_id = data.aws_vpc.default.id
    subnets = {
      az_a = {
        subnet_id = data.aws_subnet.az_a.id
        az        = data.aws_subnet.az_a.availability_zone
        cidr      = data.aws_subnet.az_a.cidr_block
      }
      az_b = {
        subnet_id = data.aws_subnet.az_b.id
        az        = data.aws_subnet.az_b.availability_zone
        cidr      = data.aws_subnet.az_b.cidr_block
      }
    }
    all_subnet_ids = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
  }
}

output "security_group_info" {
  description = "Security group information"
  value = {
    security_group_id   = aws_security_group.web_sg.id
    security_group_name = aws_security_group.web_sg.name
    vpc_id             = aws_security_group.web_sg.vpc_id
  }
}

output "ssm_connection_info" {
  description = "Information for connecting via SSM Session Manager"
  value = {
    web_server_a_instance_id = aws_instance.web_server_a.id
    web_server_b_instance_id = aws_instance.web_server_b.id
    connect_command_a = "aws ssm start-session --target ${aws_instance.web_server_a.id} --region ${var.aws_region}"
    connect_command_b = "aws ssm start-session --target ${aws_instance.web_server_b.id} --region ${var.aws_region}"
  }
}

output "iam_role_info" {
  description = "IAM role and instance profile information"
  value = {
    role_name             = aws_iam_role.ec2_ssm_role.name
    role_arn             = aws_iam_role.ec2_ssm_role.arn
    instance_profile_name = aws_iam_instance_profile.ec2_ssm_profile.name
    instance_profile_arn  = aws_iam_instance_profile.ec2_ssm_profile.arn
  }
}

output "alb_demo_summary" {
  description = "Summary information for the ALB demonstration"
  value = {
    region = var.aws_region
    web_servers = {
      server_a = {
        name        = "Web Server A"
        instance_id = aws_instance.web_server_a.id
        public_ip   = aws_instance.web_server_a.public_ip
        private_ip  = aws_instance.web_server_a.private_ip
        az          = aws_instance.web_server_a.availability_zone
        url         = "http://${aws_instance.web_server_a.public_ip}"
        health_url  = "http://${aws_instance.web_server_a.public_ip}/health"
      }
      server_b = {
        name        = "Web Server B"
        instance_id = aws_instance.web_server_b.id
        public_ip   = aws_instance.web_server_b.public_ip
        private_ip  = aws_instance.web_server_b.private_ip
        az          = aws_instance.web_server_b.availability_zone
        url         = "http://${aws_instance.web_server_b.public_ip}"
        health_url  = "http://${aws_instance.web_server_b.public_ip}/health"
      }
    }
    next_steps = [
      "1. Wait 2-3 minutes for instances to fully initialize",
      "2. Test both web servers using the URLs above",
      "3. Use these instances as targets when creating the ALB target group",
      "4. Follow the main README.md instructions for ALB configuration",
      "5. After ALB creation, test load balancing by refreshing the ALB DNS name"
    ]
  }
}

output "curl_test_commands" {
  description = "Commands to test the web servers"
  value = {
    test_server_a = "curl -s http://${aws_instance.web_server_a.public_ip} | grep 'WEB-SERVER-A'"
    test_server_b = "curl -s http://${aws_instance.web_server_b.public_ip} | grep 'WEB-SERVER-B'"
    health_check_a = "curl -s http://${aws_instance.web_server_a.public_ip}/health"
    health_check_b = "curl -s http://${aws_instance.web_server_b.public_ip}/health"
  }
}
