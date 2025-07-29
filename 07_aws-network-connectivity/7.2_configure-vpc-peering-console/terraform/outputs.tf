output "vpc_a_id" {
  description = "ID of VPC A"
  value       = module.vpc_a.vpc_id
}

output "vpc_b_id" {
  description = "ID of VPC B"
  value       = module.vpc_b.vpc_id
}

output "vpc_a_cidr" {
  description = "CIDR block of VPC A"
  value       = module.vpc_a.vpc_cidr_block
}

output "vpc_b_cidr" {
  description = "CIDR block of VPC B"
  value       = module.vpc_b.vpc_cidr_block
}

output "vpc_a_private_subnets" {
  description = "Private subnet IDs in VPC A"
  value       = module.vpc_a.private_subnets
}

output "vpc_b_private_subnets" {
  description = "Private subnet IDs in VPC B"
  value       = module.vpc_b.private_subnets
}

output "vpc_a_public_subnets" {
  description = "Public subnet IDs in VPC A"
  value       = module.vpc_a.public_subnets
}

output "vpc_b_public_subnets" {
  description = "Public subnet IDs in VPC B"
  value       = module.vpc_b.public_subnets
}

output "vpc_a_route_table_ids" {
  description = "Route table IDs for VPC A private subnets"
  value       = module.vpc_a.private_route_table_ids
}

output "vpc_b_route_table_ids" {
  description = "Route table IDs for VPC B private subnets"
  value       = module.vpc_b.private_route_table_ids
}

output "vpc_a_instance_id" {
  description = "Instance ID of EC2 instance in VPC A"
  value       = aws_instance.vpc_a_instance.id
}

output "vpc_b_instance_id" {
  description = "Instance ID of EC2 instance in VPC B"
  value       = aws_instance.vpc_b_instance.id
}

output "vpc_a_instance_private_ip" {
  description = "Private IP address of EC2 instance in VPC A"
  value       = aws_instance.vpc_a_instance.private_ip
}

output "vpc_b_instance_private_ip" {
  description = "Private IP address of EC2 instance in VPC B"
  value       = aws_instance.vpc_b_instance.private_ip
}

output "vpc_a_security_group_id" {
  description = "Security group ID for VPC A instance"
  value       = aws_security_group.vpc_a_instance_sg.id
}

output "vpc_b_security_group_id" {
  description = "Security group ID for VPC B instance"
  value       = aws_security_group.vpc_b_instance_sg.id
}

output "ami_id" {
  description = "AMI ID used for EC2 instances"
  value       = data.aws_ami.amazon_linux_2023_arm.id
}

output "ami_name" {
  description = "AMI name used for EC2 instances"
  value       = data.aws_ami.amazon_linux_2023_arm.name
}

output "iam_role_name" {
  description = "IAM role name for EC2 instances"
  value       = aws_iam_role.ec2_ssm_role.name
}

output "iam_role_arn" {
  description = "IAM role ARN for EC2 instances"
  value       = aws_iam_role.ec2_ssm_role.arn
}

output "instance_profile_name" {
  description = "Instance profile name for EC2 instances"
  value       = aws_iam_instance_profile.ec2_ssm_profile.name
}

# Useful information for the VPC peering demonstration
output "demo_information" {
  description = "Key information for VPC peering demonstration"
  value = {
    vpc_a = {
      id          = module.vpc_a.vpc_id
      cidr        = module.vpc_a.vpc_cidr_block
      instance_id = aws_instance.vpc_a_instance.id
      instance_ip = aws_instance.vpc_a_instance.private_ip
    }
    vpc_b = {
      id          = module.vpc_b.vpc_id
      cidr        = module.vpc_b.vpc_cidr_block
      instance_id = aws_instance.vpc_b_instance.id
      instance_ip = aws_instance.vpc_b_instance.private_ip
    }
    connection_commands = {
      vpc_a = "aws ssm start-session --target ${aws_instance.vpc_a_instance.id}"
      vpc_b = "aws ssm start-session --target ${aws_instance.vpc_b_instance.id}"
    }
    next_steps = [
      "1. Create VPC peering connection between ${module.vpc_a.vpc_id} and ${module.vpc_b.vpc_id}",
      "2. Accept the peering connection",
      "3. Add route to VPC A route tables: ${module.vpc_b.vpc_cidr_block} -> peering connection",
      "4. Add route to VPC B route tables: ${module.vpc_a.vpc_cidr_block} -> peering connection",
      "5. Connect to VPC A instance: aws ssm start-session --target ${aws_instance.vpc_a_instance.id}",
      "6. Test connectivity: ping ${aws_instance.vpc_b_instance.private_ip}",
      "7. Connect to VPC B instance: aws ssm start-session --target ${aws_instance.vpc_b_instance.id}",
      "8. Test connectivity: ping ${aws_instance.vpc_a_instance.private_ip}"
    ]
  }
}
