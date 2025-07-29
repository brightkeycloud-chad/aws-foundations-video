# Output values for the DNS performance demonstration

output "us_east_2_server_info" {
  description = "Information about the US East 2 web server"
  value = {
    instance_id       = aws_instance.web_server_us_east_2.id
    public_ip         = aws_instance.web_server_us_east_2.public_ip
    private_ip        = aws_instance.web_server_us_east_2.private_ip
    public_dns        = aws_instance.web_server_us_east_2.public_dns
    region           = "us-east-2"
    availability_zone = aws_instance.web_server_us_east_2.availability_zone
    instance_type    = aws_instance.web_server_us_east_2.instance_type
    ami_id           = aws_instance.web_server_us_east_2.ami
  }
}

output "us_west_2_server_info" {
  description = "Information about the US West 2 web server"
  value = {
    instance_id       = aws_instance.web_server_us_west_2.id
    public_ip         = aws_instance.web_server_us_west_2.public_ip
    private_ip        = aws_instance.web_server_us_west_2.private_ip
    public_dns        = aws_instance.web_server_us_west_2.public_dns
    region           = "us-west-2"
    availability_zone = aws_instance.web_server_us_west_2.availability_zone
    instance_type    = aws_instance.web_server_us_west_2.instance_type
    ami_id           = aws_instance.web_server_us_west_2.ami
  }
}

output "eu_central_1_server_info" {
  description = "Information about the EU Central 1 web server"
  value = {
    instance_id       = aws_instance.web_server_eu_central_1.id
    public_ip         = aws_instance.web_server_eu_central_1.public_ip
    private_ip        = aws_instance.web_server_eu_central_1.private_ip
    public_dns        = aws_instance.web_server_eu_central_1.public_dns
    region           = "eu-central-1"
    availability_zone = aws_instance.web_server_eu_central_1.availability_zone
    instance_type    = aws_instance.web_server_eu_central_1.instance_type
    ami_id           = aws_instance.web_server_eu_central_1.ami
  }
}

output "web_server_urls" {
  description = "URLs to access each web server"
  value = {
    us_east_2    = "http://${aws_instance.web_server_us_east_2.public_ip}"
    us_west_2    = "http://${aws_instance.web_server_us_west_2.public_ip}"
    eu_central_1 = "http://${aws_instance.web_server_eu_central_1.public_ip}"
  }
}

output "health_check_urls" {
  description = "Health check endpoints for each server"
  value = {
    us_east_2    = "http://${aws_instance.web_server_us_east_2.public_ip}/health"
    us_west_2    = "http://${aws_instance.web_server_us_west_2.public_ip}/health"
    eu_central_1 = "http://${aws_instance.web_server_eu_central_1.public_ip}/health"
  }
}

output "route53_latency_routing_ips" {
  description = "IP addresses to use for Route 53 latency-based routing records"
  value = {
    us_east_2 = {
      ip_address = aws_instance.web_server_us_east_2.public_ip
      region     = "us-east-2"
    }
    us_west_2 = {
      ip_address = aws_instance.web_server_us_west_2.public_ip
      region     = "us-west-2"
    }
    eu_central_1 = {
      ip_address = aws_instance.web_server_eu_central_1.public_ip
      region     = "eu-central-1"
    }
  }
}

output "route53_geolocation_routing_ips" {
  description = "IP addresses to use for Route 53 geolocation routing records"
  value = {
    north_america = {
      ip_address = aws_instance.web_server_us_east_2.public_ip
      location   = "North America"
      region     = "us-east-2"
    }
    europe = {
      ip_address = aws_instance.web_server_eu_central_1.public_ip
      location   = "Europe"
      region     = "eu-central-1"
    }
    default = {
      ip_address = aws_instance.web_server_us_west_2.public_ip
      location   = "Default"
      region     = "us-west-2"
    }
  }
}

output "ssm_connection_info" {
  description = "Information for connecting via SSM Session Manager"
  value = {
    us_east_2_instance_id    = aws_instance.web_server_us_east_2.id
    us_west_2_instance_id    = aws_instance.web_server_us_west_2.id
    eu_central_1_instance_id = aws_instance.web_server_eu_central_1.id
    
    connect_commands = {
      us_east_2    = "aws ssm start-session --target ${aws_instance.web_server_us_east_2.id} --region us-east-2"
      us_west_2    = "aws ssm start-session --target ${aws_instance.web_server_us_west_2.id} --region us-west-2"
      eu_central_1 = "aws ssm start-session --target ${aws_instance.web_server_eu_central_1.id} --region eu-central-1"
    }
  }
}

output "security_groups" {
  description = "Security group information for each region"
  value = {
    us_east_2    = aws_security_group.web_sg_us_east_2.id
    us_west_2    = aws_security_group.web_sg_us_west_2.id
    eu_central_1 = aws_security_group.web_sg_eu_central_1.id
  }
}

output "iam_role_info" {
  description = "IAM role and instance profile information"
  value = {
    role_name            = aws_iam_role.ec2_ssm_role.name
    role_arn            = aws_iam_role.ec2_ssm_role.arn
    instance_profile_name = aws_iam_instance_profile.ec2_ssm_profile.name
    instance_profile_arn  = aws_iam_instance_profile.ec2_ssm_profile.arn
  }
}

output "demonstration_summary" {
  description = "Summary information for the DNS performance demonstration"
  value = {
    servers = {
      us_east_2 = {
        region      = "us-east-2 (Ohio)"
        purpose     = "Optimal for Eastern US and Canada"
        url         = "http://${aws_instance.web_server_us_east_2.public_ip}"
        health_url  = "http://${aws_instance.web_server_us_east_2.public_ip}/health"
        ip_address  = aws_instance.web_server_us_east_2.public_ip
        color_theme = "Blue"
      }
      us_west_2 = {
        region      = "us-west-2 (Oregon)"
        purpose     = "Optimal for Western US and Pacific"
        url         = "http://${aws_instance.web_server_us_west_2.public_ip}"
        health_url  = "http://${aws_instance.web_server_us_west_2.public_ip}/health"
        ip_address  = aws_instance.web_server_us_west_2.public_ip
        color_theme = "Orange"
      }
      eu_central_1 = {
        region      = "eu-central-1 (Frankfurt)"
        purpose     = "Optimal for Europe, Middle East, and Africa"
        url         = "http://${aws_instance.web_server_eu_central_1.public_ip}"
        health_url  = "http://${aws_instance.web_server_eu_central_1.public_ip}/health"
        ip_address  = aws_instance.web_server_eu_central_1.public_ip
        color_theme = "Purple"
      }
    }
    
    routing_policies = {
      latency_based = {
        description = "Routes users to the region with lowest latency"
        use_case    = "Global applications where response time is critical"
        records_needed = 3
      }
      geolocation = {
        description = "Routes users based on their geographic location"
        use_case    = "Content localization and compliance requirements"
        records_needed = 3
      }
    }
    
    next_steps = [
      "1. Wait 2-3 minutes for instances to fully initialize",
      "2. Test all three web servers using the URLs above",
      "3. Use the IP addresses for Route 53 latency-based routing",
      "4. Configure geolocation routing for different continents",
      "5. Follow the README.md instructions for Route 53 configuration"
    ]
  }
}

output "testing_commands" {
  description = "Commands to test the infrastructure"
  value = {
    test_all_servers = [
      "curl http://${aws_instance.web_server_us_east_2.public_ip}",
      "curl http://${aws_instance.web_server_us_west_2.public_ip}",
      "curl http://${aws_instance.web_server_eu_central_1.public_ip}"
    ]
    
    test_health_endpoints = [
      "curl http://${aws_instance.web_server_us_east_2.public_ip}/health",
      "curl http://${aws_instance.web_server_us_west_2.public_ip}/health",
      "curl http://${aws_instance.web_server_eu_central_1.public_ip}/health"
    ]
    
    check_response_times = [
      "curl -w \"@curl-format.txt\" -o /dev/null -s http://${aws_instance.web_server_us_east_2.public_ip}",
      "curl -w \"@curl-format.txt\" -o /dev/null -s http://${aws_instance.web_server_us_west_2.public_ip}",
      "curl -w \"@curl-format.txt\" -o /dev/null -s http://${aws_instance.web_server_eu_central_1.public_ip}"
    ]
  }
}
