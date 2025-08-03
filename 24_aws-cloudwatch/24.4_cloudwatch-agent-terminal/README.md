# CloudWatch Agent Terminal Installation Demonstration

## Overview
This 5-minute demonstration shows how to install and configure the CloudWatch agent on an EC2 instance using terminal commands. You'll learn to collect custom metrics and logs from your instances beyond the default CloudWatch metrics.

## Prerequisites
- Running EC2 instance (Amazon Linux 2 or Ubuntu)
- SSH access to the instance
- IAM role attached to instance with CloudWatch permissions
- Terminal/SSH client

## Required IAM Permissions
Ensure your EC2 instance has an IAM role with these policies:
- `CloudWatchAgentServerPolicy`
- `AmazonSSMManagedInstanceCore` (for Systems Manager integration)

## Demonstration Steps

### Step 1: Connect and Download Agent (1 minute)
```bash
# Connect to your EC2 instance via SSH
ssh -i your-key.pem ec2-user@your-instance-ip

# Download CloudWatch agent (Amazon Linux 2)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm

# For Ubuntu, use:
# wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
```

### Step 2: Install the Agent (1 minute)
```bash
# Install the agent (Amazon Linux 2)
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# For Ubuntu, use:
# sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Verify installation
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -a query
```

### Step 3: Create Configuration File (2 minutes)
```bash
# Create configuration directory
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

# Create basic configuration file
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60,
                "totalcpu": false
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "ec2-system-logs",
                        "log_stream_name": "{instance_id}-messages"
                    }
                ]
            }
        }
    }
}
EOF
```

### Step 4: Start and Verify Agent (1 minute)
```bash
# Start the CloudWatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -a start

# Check agent status
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -m ec2 \
    -a query

# View agent logs
sudo tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

### Step 5: Verify Metrics in Console (30 seconds)
1. Open AWS CloudWatch Console
2. Navigate to **Metrics** → **All metrics**
3. Look for **CWAgent** namespace
4. Verify custom metrics are appearing:
   - CPU usage metrics
   - Memory utilization
   - Disk usage percentage
5. Check **Logs** → **Log groups** for `ec2-system-logs`

## Configuration Explanation

### Key Configuration Sections:
- **agent**: Global agent settings and collection interval
- **metrics**: Custom metrics to collect beyond default EC2 metrics
- **logs**: Log files to send to CloudWatch Logs

### Metrics Collected:
- **CPU**: Detailed CPU usage breakdown by type
- **Memory**: Memory utilization percentage
- **Disk**: Disk space usage and I/O metrics
- **Network**: Network interface statistics

## Advanced Configuration Options

### Using Configuration Wizard:
```bash
# Run interactive configuration wizard
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

### StatsD Integration:
```bash
# Add StatsD configuration for custom application metrics
"metrics": {
    "metrics_collected": {
        "statsd": {
            "service_address": ":8125",
            "metrics_collection_interval": 60,
            "metrics_aggregation_interval": 300
        }
    }
}
```

## Troubleshooting Commands

```bash
# Check agent status
sudo systemctl status amazon-cloudwatch-agent

# Restart agent
sudo systemctl restart amazon-cloudwatch-agent

# View detailed logs
sudo journalctl -u amazon-cloudwatch-agent -f

# Validate configuration
sudo /opt/aws/amazon-cloudwatch-agent/bin/config-translator \
    --input /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    --output /tmp/config.toml \
    --mode ec2 \
    --config /opt/aws/amazon-cloudwatch-agent/etc/common-config.toml
```

## Key Learning Points
- CloudWatch agent extends monitoring beyond basic EC2 metrics
- Configuration file controls what metrics and logs are collected
- Agent runs as a system service for continuous monitoring
- Custom namespaces help organize application-specific metrics
- Log collection enables centralized log management

## Best Practices Demonstrated
- Use IAM roles instead of access keys for security
- Configure appropriate collection intervals to balance cost and granularity
- Organize metrics with meaningful namespaces
- Monitor agent health and logs for troubleshooting
- Use Systems Manager for large-scale deployments

## Cost Considerations
- Custom metrics incur additional charges
- Log ingestion and storage have associated costs
- Higher collection frequency increases costs
- Use metric filters to reduce unnecessary data

## Documentation References
- [Installing the CloudWatch agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance.html)
- [Create the CloudWatch agent configuration file](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-cloudwatch-agent-configuration-file.html)
- [CloudWatch agent configuration file reference](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html)
