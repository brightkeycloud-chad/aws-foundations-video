# CloudWatch Metrics Console Demonstration

## Overview
This 5-minute demonstration shows how to view, analyze, and create custom dashboards using CloudWatch metrics in the AWS Console. You'll learn to navigate the metrics interface, create visualizations, and understand key performance indicators for your AWS resources using a pre-configured EC2 instance with detailed monitoring enabled.

## Prerequisites
- AWS account with appropriate permissions (EC2, CloudWatch, IAM)
- Terraform installed (version >= 1.0)
- AWS CLI configured with appropriate credentials
- Basic understanding of Terraform (optional but helpful)

## File Structure

```
24.3_cloudwatch-metrics-console/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example  # Example variables file
├── user-data.sh              # EC2 instance initialization script
└── README.md                 # This documentation
```

## Infrastructure Setup

### Step 1: Deploy Infrastructure with Terraform (2-3 minutes)

1. **Clone or navigate to the demo directory:**
   ```bash
   cd 24.3_cloudwatch-metrics-console
   ```

2. **Configure Terraform variables:**
   ```bash
   # Copy the example variables file
   cp terraform.tfvars.example terraform.tfvars
   
   # Edit terraform.tfvars with your preferences (optional)
   # The defaults will work for the demo
   ```

3. **Initialize and deploy:**
   ```bash
   # Initialize Terraform
   terraform init
   
   # Review the planned changes
   terraform plan
   
   # Deploy the infrastructure
   terraform apply
   ```

4. **Note the outputs:**
   After deployment, Terraform will display important information:
   - Instance ID
   - Public IP address
   - CloudWatch Dashboard URL
   - Direct metrics console URL

### What Gets Created:
- **EC2 Instance**: Amazon Linux 2023 with detailed monitoring enabled
- **Security Group**: Allows HTTP (80) and SSH (22) access
- **IAM Role**: Permissions for CloudWatch and SSM Session Manager access
- **CloudWatch Dashboard**: Pre-configured with key metrics
- **Load Generation Tools**: Stress testing utilities for demo
- **Session Manager Access**: Browser-based terminal access (no SSH keys required)
- **User Data Script**: External `user-data.sh` file for instance initialization

## Demonstration Steps

### Step 1: Access CloudWatch Metrics (1 minute)
1. Use the **CloudWatch Metrics Console URL** from Terraform output
2. Or manually navigate:
   - Sign in to AWS Management Console
   - Navigate to **CloudWatch** service
   - Click **Metrics** → **All metrics**
   - Click **AWS/EC2** namespace
3. Select **Per-Instance Metrics**
4. Find your instance using the Instance ID from Terraform output

### Step 2: Explore Instance Metrics (2 minutes)
1. Select your demo instance from the list
2. Choose key metrics to monitor:
   - **CPUUtilization** - Shows CPU usage percentage
   - **NetworkIn/NetworkOut** - Network traffic metrics
   - **DiskReadOps/DiskWriteOps** - Disk I/O operations
   - **StatusCheckFailed** - Instance health status
3. Click **Graphed metrics** tab to view selected metrics
4. **Demonstrate detailed monitoring:**
   - Show 1-minute data points (vs 5-minute for standard monitoring)
   - Adjust time range: 1 hour, 6 hours, 1 day
   - Explain the cost/benefit of detailed monitoring

### Step 3: Generate Load for Real-time Metrics (1 minute)
1. **Access the web interface:**
   - Use the **Web Server URL** from Terraform output
   - Show the instance information page with load generation commands

2. **Connect to the instance (choose one method):**

   **Option A - AWS Systems Manager Session Manager (Recommended):**
   - Use the **Session Manager URL** from Terraform output
   - Or navigate: EC2 Console → Instances → Select instance → Connect → Session Manager
   - Click **Connect** (no key pair required!)
   
   **Option B - SSH (if key pair configured):**
   ```bash
   # Use the SSH command from Terraform output
   ssh -i your-key.pem ec2-user@INSTANCE_IP
   ```

3. **Generate system load using manual commands:**
   ```bash
   # CPU Load Test (run in background)
   stress-ng --cpu 2 --timeout 300s &
   
   # Memory Load Test (run in background)
   stress-ng --vm 1 --vm-bytes 512M --timeout 300s &
   
   # Disk I/O Test
   dd if=/dev/zero of=/tmp/testfile bs=1M count=100
   rm -f /tmp/testfile
   
   # Check running processes
   ps aux | grep stress
   ```

4. **Alternative: Use automated scripts (if available):**
   ```bash
   # Check if scripts exist
   ls -la /home/ec2-user/*.sh
   
   # Run comprehensive load test
   cd /home/ec2-user
   ./generate-load.sh
   
   # Or run simple load test
   ./simple-load.sh
   
   # Check system information
   ./system-info.sh
   ```

5. **Monitor load generation:**
   ```bash
   # Watch CPU usage in real-time
   top
   
   # Check memory usage
   free -h
   
   # Monitor system load
   uptime
   
   # Check disk I/O (if iostat available)
   iostat 1 5
   ```

### Step 4: View Pre-configured Dashboard (1 minute)
1. Use the **CloudWatch Dashboard URL** from Terraform output
2. Or navigate manually:
   - CloudWatch Console → Dashboards
   - Select "CloudWatch-Metrics-Demo-Dashboard"
3. Observe the real-time metrics:
   - CPU and Network metrics in top widget
   - Disk I/O metrics in bottom widget
4. Show how metrics update as load is generated

### Step 5: Create Custom Visualization (30 seconds)
1. From the metrics view, select additional metrics
2. Click **Actions** → **Add to dashboard**
3. Choose **Add to existing dashboard** → Select demo dashboard
4. Configure widget:
   - Chart type: **Line** or **Number**
   - Widget title: "Custom Metric View"
   - Statistic: **Average** or **Maximum**
   - Period: **1 minute** (detailed monitoring)

## Advanced Features Demonstrated

### Math Expressions:
1. Click **Add math** in metrics view
2. Create expressions like:
   - `m1 + m2` (combine NetworkIn + NetworkOut)
   - `m1 * 100` (convert to percentage)
   - `RATE(m1)` (calculate rate of change)

### Metric Insights:
1. Navigate to **CloudWatch** → **Metrics** → **Metrics Insights**
2. Try SQL-like queries:
   ```sql
   SELECT AVG(CPUUtilization) 
   FROM SCHEMA("AWS/EC2", InstanceId) 
   WHERE InstanceId = 'i-1234567890abcdef0'
   ```

### Anomaly Detection:
1. Select a metric → **Actions** → **Create anomaly detector**
2. Show how CloudWatch learns normal patterns
3. Explain automatic threshold adjustment

## Key Learning Points
- **Detailed monitoring** provides 1-minute granularity vs 5-minute standard
- CloudWatch automatically collects metrics from AWS services
- Metrics are organized by **namespace** and **dimensions**
- **Custom dashboards** provide centralized monitoring views
- **Time range selection** affects metric granularity and retention
- **Math expressions** enable advanced metric calculations
- **Real-time monitoring** helps with immediate issue detection
- **Session Manager** provides secure, browser-based access without SSH keys
- **IAM roles** enable secure service-to-service authentication

## Best Practices Demonstrated
- Use appropriate time ranges for different monitoring needs
- Combine related metrics in single widgets for correlation analysis
- Name dashboards and widgets descriptively for team collaboration
- Leverage built-in statistics (Average, Sum, Maximum) appropriately
- Enable detailed monitoring for critical instances
- Use IAM roles instead of access keys for security
- **Prefer Session Manager over SSH** for secure, auditable access
- **Implement least privilege** IAM policies for service access

## Cost Considerations
- **Detailed monitoring**: $2.10 per instance per month
- **Custom metrics**: $0.30 per metric per month
- **Dashboard**: $3.00 per dashboard per month
- **API requests**: $0.01 per 1,000 requests
- **EBS Storage**: ~$2.40 per month for 30GB GP3 volume
- Demo infrastructure: ~$0.75-1.25 per day if left running

## Troubleshooting Tips

### CloudWatch Metrics Issues:
- If metrics don't appear, verify the instance is running and generating data
- Check the selected time range - recent metrics may not show in long time ranges
- Ensure proper IAM permissions for CloudWatch access
- Detailed monitoring metrics may take 1-2 minutes to appear
- Generate load manually to create visible metric changes

### Load Generation Issues:
- **Primary method**: Use manual `stress-ng` commands (always available)
- **stress-ng not found**: Run `sudo yum install -y stress-ng` to install
- **Scripts not available**: Use manual commands instead - they're more reliable
- **No visible metrics**: Wait 1-2 minutes for metrics to appear in CloudWatch
- **Session Manager issues**: Verify IAM role has `AmazonSSMManagedInstanceCore` policy

### Manual Load Generation (Recommended):
```bash
# Always works - CPU load for 5 minutes
stress-ng --cpu 2 --timeout 300s &

# Memory load for 5 minutes  
stress-ng --vm 1 --vm-bytes 512M --timeout 300s &

# Disk I/O test
dd if=/dev/zero of=/tmp/testfile bs=1M count=100
rm -f /tmp/testfile

# Check if load is running
ps aux | grep stress
top
```

### Verification Commands:
```bash
# Check if stress-ng is installed
which stress-ng
stress-ng --version

# Check user data execution log
sudo tail -f /var/log/user-data.log

# Verify SSM agent status
sudo systemctl status amazon-ssm-agent

# Check if scripts exist (optional)
ls -la /home/ec2-user/*.sh 2>/dev/null || echo "Scripts not found - use manual commands"

# Monitor system resources
uptime
free -h
df -h
```

## Cleanup
To avoid ongoing charges, destroy the infrastructure after the demo:
```bash
terraform destroy
```

## Infrastructure Details

### EC2 Instance Configuration:
- **AMI**: Latest Amazon Linux 2023
- **Instance Type**: t3.micro (free tier eligible)
- **Monitoring**: Detailed (1-minute intervals)
- **Storage**: 30GB GP3 encrypted root volume (minimum required for AL2023)
- **Network**: Default VPC, public subnet
- **Security**: Security group with HTTP/SSH access

### Pre-installed Tools:
- **stress-ng**: CPU and memory load generation utility (primary tool)
- **htop**: Interactive system monitoring (if available)
- **sysstat**: System performance tools including iostat
- **Apache httpd**: Web server for information display and connectivity testing
- **Optional scripts**: May be available in `/home/ec2-user/` (use manual commands if not)

### IAM Permissions:
- **CloudWatch**: Metric publishing, reading, and dashboard management
- **CloudWatch Logs**: Log group and stream management
- **SSM Session Manager**: Browser-based terminal access
- **EC2**: Basic instance metadata access
- **Minimal required permissions**: Following principle of least privilege

## Alternative Manual Load Generation

If the automated scripts are not available, you can generate load manually:

### CPU Load:
```bash
# Generate CPU load on 2 cores for 5 minutes
stress-ng --cpu 2 --timeout 300s

# Alternative using yes command
yes > /dev/null &
yes > /dev/null &
# Kill with: killall yes
```

### Memory Load:
```bash
# Allocate 512MB of memory for 5 minutes
stress-ng --vm 1 --vm-bytes 512M --timeout 300s

# Alternative using dd
dd if=/dev/zero of=/dev/null bs=1M count=512 &
```

### Disk I/O Load:
```bash
# Generate disk write operations
dd if=/dev/zero of=/tmp/testfile bs=1M count=100

# Generate continuous disk I/O
while true; do
    dd if=/dev/zero of=/tmp/testfile bs=1M count=50 2>/dev/null
    rm -f /tmp/testfile
    sleep 10
done &
```

### Monitor Load Generation:
```bash
# Watch CPU usage
watch -n 1 'cat /proc/loadavg'

# Monitor memory usage
watch -n 1 'free -h'

# Monitor disk I/O
watch -n 1 'iostat -x 1 1'
```

## Next Steps
- Set up CloudWatch alarms based on these metrics
- Explore custom metrics from applications
- Integrate with other AWS monitoring services
- Consider CloudWatch agent for additional system metrics

## Documentation References
- [Metrics in Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html)
- [Creating a customized CloudWatch dashboard](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create_dashboard.html)
- [Using CloudWatch Metrics Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/query_with_cloudwatch-metrics-insights.html)
- [Enable or turn off detailed monitoring for your instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
