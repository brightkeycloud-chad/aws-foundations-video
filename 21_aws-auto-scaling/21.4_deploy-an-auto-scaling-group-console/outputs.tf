output "launch_template_id" {
  description = "ID of the launch template for Auto Scaling Group"
  value       = aws_launch_template.asg_demo_template.id
}

output "launch_template_name" {
  description = "Name of the launch template for Auto Scaling Group"
  value       = aws_launch_template.asg_demo_template.name
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.asg_demo_template.latest_version
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.asg_demo_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.asg_demo_alb.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.asg_demo_alb.arn
}

output "target_group_arn" {
  description = "ARN of the target group for Auto Scaling Group attachment"
  value       = aws_lb_target_group.asg_demo_tg.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.asg_demo_tg.name
}

output "ec2_security_group_id" {
  description = "Security group ID for EC2 instances"
  value       = aws_security_group.ec2_sg.id
}

output "alb_security_group_id" {
  description = "Security group ID for Application Load Balancer"
  value       = aws_security_group.alb_sg.id
}

output "default_vpc_id" {
  description = "ID of the default VPC"
  value       = data.aws_vpc.default.id
}

output "default_subnet_ids" {
  description = "IDs of the default subnets"
  value       = data.aws_subnets.default.ids
}

output "availability_zones" {
  description = "Available availability zones"
  value       = data.aws_availability_zones.available.names
}

output "demo_url" {
  description = "URL to access the demo application"
  value       = "http://${aws_lb.asg_demo_alb.dns_name}"
}

output "health_check_url" {
  description = "URL for health check endpoint"
  value       = "http://${aws_lb.asg_demo_alb.dns_name}/health"
}

output "status_endpoint_url" {
  description = "URL for real-time status endpoint"
  value       = "http://${aws_lb.asg_demo_alb.dns_name}/status"
}

# Instructions for the demonstration
output "demonstration_instructions" {
  description = "Instructions for creating the Auto Scaling Group"
  value = <<-EOT
    
    🚀 INFRASTRUCTURE READY FOR AUTO SCALING GROUP DEMONSTRATION
    
    ✅ Resources Created:
    - Launch Template: ${aws_launch_template.asg_demo_template.name}
    - Application Load Balancer: ${aws_lb.asg_demo_alb.dns_name}
    - Target Group: ${aws_lb_target_group.asg_demo_tg.name}
    - Security Groups: ALB and EC2 configured
    
    📋 Next Steps for Demonstration:
    1. Go to AWS Console → EC2 → Auto Scaling Groups
    2. Click "Create an Auto Scaling group"
    3. Use launch template: ${aws_launch_template.asg_demo_template.name}
    4. Configure with these settings:
       - Desired capacity: 2
       - Minimum capacity: 1  
       - Maximum capacity: 4
       - Target group: ${aws_lb_target_group.asg_demo_tg.name}
       - Health check type: ELB
       - Health check grace period: 300 seconds
    
    🧪 Testing URLs:
    - Demo Application: http://${aws_lb.asg_demo_alb.dns_name}
    - Health Check: http://${aws_lb.asg_demo_alb.dns_name}/health
    
    💡 Load Testing:
    - SSH into instances and run: /home/ec2-user/generate-load.sh
    - Monitor Auto Scaling Group activity in AWS Console
    - Watch new instances launch when CPU > 70%
    
  EOT
}
