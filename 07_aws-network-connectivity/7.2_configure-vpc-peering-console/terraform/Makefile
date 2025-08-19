# VPC Peering Demo - Terraform Makefile
# Simplifies common Terraform operations

.PHONY: help init plan apply destroy clean status outputs connect-a connect-b test-connectivity

# Default target
help:
	@echo "VPC Peering Demo - Terraform Commands"
	@echo "====================================="
	@echo ""
	@echo "Setup Commands:"
	@echo "  init          Initialize Terraform"
	@echo "  plan          Show planned changes"
	@echo "  apply         Deploy infrastructure"
	@echo "  destroy       Destroy infrastructure"
	@echo ""
	@echo "Management Commands:"
	@echo "  status        Show current infrastructure status"
	@echo "  outputs       Show all Terraform outputs"
	@echo "  demo-info     Show demo-specific information"
	@echo "  clean         Clean Terraform cache files"
	@echo ""
	@echo "Testing Commands:"
	@echo "  connect-a     Connect to VPC A instance via Session Manager"
	@echo "  connect-b     Connect to VPC B instance via Session Manager"
	@echo "  ssm-status    Check SSM connectivity status for instances"
	@echo "  test-ping     Test ping connectivity (after peering setup)"
	@echo "  test-web      Test web server connectivity"
	@echo ""
	@echo "Utility Commands:"
	@echo "  get-ami       Get latest Amazon Linux 2023 ARM64 AMI ID"
	@echo "  ami-info      Show AMI information from Terraform"
	@echo "  test-ssm      Test SSM connectivity for instances"
	@echo "  validate      Validate Terraform configuration"
	@echo "  format        Format Terraform files"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Validate configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Format Terraform files
format:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Show planned changes
plan:
	@echo "Planning Terraform changes..."
	terraform plan

# Deploy infrastructure
apply:
	@echo "Deploying infrastructure..."
	terraform apply

# Destroy infrastructure
destroy:
	@echo "Destroying infrastructure..."
	terraform destroy

# Show current status
status:
	@echo "Current infrastructure status:"
	@echo "=============================="
	@terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[] | select(.type == "aws_instance") | "\(.values.tags.Name): \(.values.instance_state)"' 2>/dev/null || echo "No instances found or jq not installed"

# Show all outputs
outputs:
	@echo "Terraform Outputs:"
	@echo "=================="
	@terraform output

# Show demo-specific information
demo-info:
	@echo "VPC Peering Demo Information:"
	@echo "============================"
	@terraform output demo_information

# Connect to VPC A instance
connect-a:
	@echo "Connecting to VPC A instance via SSM Session Manager..."
	@INSTANCE_ID=$$(terraform output -raw vpc_a_instance_id 2>/dev/null); \
	REGION=$$(terraform output -raw aws_region 2>/dev/null || echo "us-west-2"); \
	if [ -n "$$INSTANCE_ID" ]; then \
		echo "Instance ID: $$INSTANCE_ID"; \
		echo "Region: $$REGION"; \
		echo "Connecting..."; \
		aws ssm start-session --target $$INSTANCE_ID --region $$REGION; \
	else \
		echo "Error: Could not get VPC A instance ID. Is the infrastructure deployed?"; \
	fi

# Connect to VPC B instance
connect-b:
	@echo "Connecting to VPC B instance via SSM Session Manager..."
	@INSTANCE_ID=$$(terraform output -raw vpc_b_instance_id 2>/dev/null); \
	REGION=$$(terraform output -raw aws_region 2>/dev/null || echo "us-west-2"); \
	if [ -n "$$INSTANCE_ID" ]; then \
		echo "Instance ID: $$INSTANCE_ID"; \
		echo "Region: $$REGION"; \
		echo "Connecting..."; \
		aws ssm start-session --target $$INSTANCE_ID --region $$REGION; \
	else \
		echo "Error: Could not get VPC B instance ID. Is the infrastructure deployed?"; \
	fi

# Check SSM connectivity status
ssm-status:
	@echo "Checking SSM connectivity status..."
	@echo "=================================="
	@VPC_A_ID=$$(terraform output -raw vpc_a_instance_id 2>/dev/null); \
	VPC_B_ID=$$(terraform output -raw vpc_b_instance_id 2>/dev/null); \
	REGION=$$(terraform output -raw aws_region 2>/dev/null || echo "us-west-2"); \
	if [ -n "$$VPC_A_ID" ]; then \
		echo "VPC A Instance ($$VPC_A_ID):"; \
		aws ssm describe-instance-information --region $$REGION --filters "Key=InstanceIds,Values=$$VPC_A_ID" --query 'InstanceInformationList[0].{Status:PingStatus,LastPing:LastPingDateTime,AgentVersion:AgentVersion}' --output table 2>/dev/null || echo "  Not connected to SSM"; \
	fi; \
	if [ -n "$$VPC_B_ID" ]; then \
		echo "VPC B Instance ($$VPC_B_ID):"; \
		aws ssm describe-instance-information --region $$REGION --filters "Key=InstanceIds,Values=$$VPC_B_ID" --query 'InstanceInformationList[0].{Status:PingStatus,LastPing:LastPingDateTime,AgentVersion:AgentVersion}' --output table 2>/dev/null || echo "  Not connected to SSM"; \
	fi

# Test ping connectivity
test-ping:
	@echo "Testing ping connectivity..."
	@echo "Note: This requires VPC peering to be configured first!"
	@VPC_A_IP=$$(terraform output -raw vpc_a_instance_private_ip 2>/dev/null); \
	VPC_B_IP=$$(terraform output -raw vpc_b_instance_private_ip 2>/dev/null); \
	echo "VPC A Instance IP: $$VPC_A_IP"; \
	echo "VPC B Instance IP: $$VPC_B_IP"; \
	echo ""; \
	echo "To test connectivity:"; \
	echo "1. Connect to VPC A instance: make connect-a"; \
	echo "2. Run: ping $$VPC_B_IP"; \
	echo "3. Connect to VPC B instance: make connect-b"; \
	echo "4. Run: ping $$VPC_A_IP"

# Test web server connectivity
test-web:
	@echo "Testing web server connectivity..."
	@VPC_A_IP=$$(terraform output -raw vpc_a_instance_private_ip 2>/dev/null); \
	VPC_B_IP=$$(terraform output -raw vpc_b_instance_private_ip 2>/dev/null); \
	echo "Web servers are running on port 8080:"; \
	echo "VPC A: http://$$VPC_A_IP:8080"; \
	echo "VPC B: http://$$VPC_B_IP:8080"; \
	echo ""; \
	echo "To test from instances:"; \
	echo "curl http://$$VPC_A_IP:8080"; \
	echo "curl http://$$VPC_B_IP:8080"

# Get latest AMI ID
get-ami:
	@echo "Getting latest Amazon Linux 2023 ARM64 AMI ID for current region..."
	@REGION=$$(terraform output -raw aws_region 2>/dev/null || aws configure get region || echo "us-west-2"); \
	echo "Region: $$REGION"; \
	aws ec2 describe-images \
		--region $$REGION \
		--owners amazon \
		--filters "Name=name,Values=al2023-ami-2023.*-arm64" \
		          "Name=state,Values=available" \
		          "Name=architecture,Values=arm64" \
		--query 'Images | sort_by(@, &CreationDate) | [-1].{ImageId:ImageId,Name:Name,CreationDate:CreationDate}' \
		--output table

# Show AMI information from Terraform
ami-info:
	@echo "AMI Information from Terraform:"
	@echo "==============================="
	@echo "AMI ID: $$(terraform output -raw ami_id 2>/dev/null || echo 'Not available - run terraform apply first')"
	@echo "AMI Name: $$(terraform output -raw ami_name 2>/dev/null || echo 'Not available - run terraform apply first')"

# Test SSM connectivity
test-ssm:
	@echo "Testing SSM connectivity..."
	@./test-ssm.sh

# Clean Terraform cache
clean:
	@echo "Cleaning Terraform cache files..."
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate.backup

# Quick deployment (init + apply)
deploy: init apply

# Full cleanup (destroy + clean)
cleanup: destroy clean

# Development workflow
dev: format validate plan

# Show resource costs (requires infracost)
cost:
	@if command -v infracost >/dev/null 2>&1; then \
		echo "Calculating infrastructure costs..."; \
		infracost breakdown --path .; \
	else \
		echo "infracost not installed. Install from: https://www.infracost.io/docs/"; \
	fi
