# Outputs for CloudWatch Metrics Console Demo

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.cloudwatch_demo.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.cloudwatch_demo.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.cloudwatch_demo.public_dns
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.cloudwatch_demo.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.cloudwatch_demo_sg.id
}

output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.demo_dashboard.dashboard_name}"
}

output "web_server_url" {
  description = "URL to access the web server on the instance"
  value       = "http://${aws_instance.cloudwatch_demo.public_ip}"
}

output "session_manager_url" {
  description = "URL to connect via AWS Systems Manager Session Manager"
  value       = "https://console.aws.amazon.com/systems-manager/session-manager/sessions?region=${var.aws_region}&instanceId=${aws_instance.cloudwatch_demo.id}"
}

output "ssh_command" {
  description = "SSH command to connect to the instance (if key pair is specified)"
  value       = var.key_pair_name != null ? "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.cloudwatch_demo.public_ip}" : "No key pair specified - SSH not available"
}

output "load_generation_command" {
  description = "Commands to generate load for testing CloudWatch metrics"
  value       = "Connect via Session Manager, then run: stress-ng --cpu 2 --timeout 300s & stress-ng --vm 1 --vm-bytes 512M --timeout 300s &"
}

output "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  value       = var.root_volume_size
}

output "cloudwatch_metrics_console_url" {
  description = "Direct URL to CloudWatch metrics for this instance"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#metricsV2:graph=~();query=AWS%2FEC2%20InstanceId%20${aws_instance.cloudwatch_demo.id}"
}
