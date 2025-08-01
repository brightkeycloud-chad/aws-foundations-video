#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Wait for instance metadata service to be available
sleep 10

# Get IMDSv2 token for metadata calls
get_imds_token() {
    curl -X PUT "http://169.254.169.254/latest/api/token" \
         -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
         -s --max-time 10 2>/dev/null
}

# Get instance metadata using IMDSv2
get_metadata() {
    local endpoint=$1
    local default_value=$2
    local token=$(get_imds_token)
    
    if [ ! -z "$token" ]; then
        local result=$(curl -H "X-aws-ec2-metadata-token: $token" \
                           -s --max-time 10 \
                           "http://169.254.169.254/latest/meta-data/$endpoint" 2>/dev/null)
        if [ $? -eq 0 ] && [ ! -z "$result" ]; then
            echo "$result"
        else
            echo "$default_value"
        fi
    else
        echo "$default_value"
    fi
}

# Retrieve instance metadata
INSTANCE_ID=$(get_metadata "instance-id" "unavailable")
AVAILABILITY_ZONE=$(get_metadata "placement/availability-zone" "unavailable")
INSTANCE_TYPE=$(get_metadata "instance-type" "unavailable")
LOCAL_IPV4=$(get_metadata "local-ipv4" "unavailable")
PUBLIC_IPV4=$(get_metadata "public-ipv4" "not-assigned")

# Create a comprehensive HTML page with actual metadata
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Auto Scaling Group Demo Server</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto; 
            padding: 30px; 
            background-color: rgba(255,255,255,0.95); 
            border-radius: 15px; 
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            color: #333;
        }
        .header { 
            color: #4a5568; 
            text-align: center; 
            margin-bottom: 30px;
            border-bottom: 3px solid #667eea;
            padding-bottom: 20px;
        }
        .status { 
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white; 
            padding: 15px; 
            border-radius: 8px; 
            text-align: center; 
            margin: 20px 0;
            font-weight: bold;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
        }
        .info { 
            background-color: #f8f9fa; 
            padding: 20px; 
            border-radius: 8px; 
            margin: 15px 0;
            border-left: 4px solid #667eea;
        }
        .metric { 
            display: inline-block; 
            background-color: #e3f2fd; 
            padding: 8px 12px; 
            margin: 5px; 
            border-radius: 5px;
            border: 1px solid #2196f3;
            min-width: 200px;
        }
        .highlight { 
            font-weight: bold; 
            color: #1976d2; 
        }
        .timestamp {
            text-align: center;
            font-size: 0.9em;
            color: #666;
            margin-top: 20px;
            font-style: italic;
        }
        .refresh-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin: 10px;
        }
    </style>
    <script>
        function refreshPage() {
            location.reload();
        }
        // Auto-refresh every 30 seconds
        setTimeout(refreshPage, 30000);
    </script>
</head>
<body>
    <div class="container">
        <h1 class="header">🚀 Auto Scaling Group Demonstration</h1>
        <div class="status">✅ SERVER ONLINE - READY FOR LOAD TESTING</div>
        
        <div class="info">
            <h3>🖥️ Instance Information:</h3>
HTML

# Use shell variable substitution to insert the actual values
cat >> /var/www/html/index.html << HTML
            <div class="metric"><strong>Instance ID:</strong> <span class="highlight">$INSTANCE_ID</span></div>
            <div class="metric"><strong>Instance Type:</strong> <span class="highlight">$INSTANCE_TYPE</span></div>
            <div class="metric"><strong>Availability Zone:</strong> <span class="highlight">$AVAILABILITY_ZONE</span></div>
            <div class="metric"><strong>Private IP:</strong> <span class="highlight">$LOCAL_IPV4</span></div>
            <div class="metric"><strong>Public IP:</strong> <span class="highlight">$PUBLIC_IPV4</span></div>
        </div>
        
        <div class="info">
            <h3>🎯 Load Balancer Health Check:</h3>
            <p>This page serves as the health check endpoint for the Application Load Balancer.</p>
            <p>If you can see this page, this instance is healthy and receiving traffic.</p>
            <p><strong>Health Check Path:</strong> <code>/health</code></p>
            <button class="refresh-btn" onclick="refreshPage()">🔄 Refresh Now</button>
        </div>
        
        <div class="info">
            <h3>📊 Auto Scaling Behavior:</h3>
            <p>This instance is part of an Auto Scaling Group that will:</p>
            <ul>
                <li>Scale out when CPU utilization exceeds 70%</li>
                <li>Scale in when CPU utilization drops below 70%</li>
                <li>Maintain minimum 1 instance, maximum 4 instances</li>
                <li>Distribute instances across multiple Availability Zones</li>
            </ul>
        </div>
        
        <div class="info">
            <h3>🧪 Testing Instructions:</h3>
            <p>To test auto scaling:</p>
            <ol>
                <li>Generate load using: <code>sudo /home/ec2-user/generate-load.sh</code></li>
                <li>Monitor CloudWatch metrics for CPU utilization</li>
                <li>Watch new instances launch when thresholds are exceeded</li>
                <li>Observe load distribution across instances</li>
            </ol>
        </div>
        
        <div class="timestamp">
            Page generated at: $(date)<br>
            Auto-refresh in 30 seconds | Instance: $INSTANCE_ID
        </div>
    </div>
</body>
</html>
HTML

# Create a dedicated health check endpoint with instance information
cat > /var/www/html/health << HEALTH
{
  "status": "healthy",
  "instance_id": "$INSTANCE_ID",
  "instance_type": "$INSTANCE_TYPE",
  "availability_zone": "$AVAILABILITY_ZONE",
  "private_ip": "$LOCAL_IPV4",
  "public_ip": "$PUBLIC_IPV4",
  "timestamp": "$(date -Iseconds)",
  "service": "auto-scaling-demo",
  "uptime": "$(uptime -p)"
}
HEALTH

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod 755 /var/www/html/
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health

# Configure httpd to start on boot and restart if it fails
systemctl enable httpd
systemctl restart httpd

# Install stress testing tool for demonstration purposes
yum install -y stress-ng

# Create a simple load generation script for testing
cat > /home/ec2-user/generate-load.sh << 'SCRIPT'
#!/bin/bash
echo "Starting CPU load generation for Auto Scaling demonstration..."

# Get instance ID using IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)

echo "Instance ID: $INSTANCE_ID"
echo "This will generate high CPU load for 5 minutes to trigger scaling"
echo "Monitor the Auto Scaling Group in the AWS Console to see new instances launch"
stress-ng --cpu $(nproc) --timeout 300s --metrics-brief
echo "Load generation complete. Instances should scale back down after cooldown period."
SCRIPT

chmod +x /home/ec2-user/generate-load.sh
chown ec2-user:ec2-user /home/ec2-user/generate-load.sh

# Create a status page that shows real-time instance information using IMDSv2
cat > /var/www/html/status << 'STATUS'
#!/bin/bash
echo "Content-Type: application/json"
echo ""

# Get IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s 2>/dev/null)

if [ ! -z "$TOKEN" ]; then
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
    INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-type 2>/dev/null)
    AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)
    PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null)
    PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
else
    INSTANCE_ID="token-unavailable"
    INSTANCE_TYPE="token-unavailable"
    AVAILABILITY_ZONE="token-unavailable"
    PRIVATE_IP="token-unavailable"
    PUBLIC_IP="token-unavailable"
fi

echo "{"
echo "  \"instance_id\": \"${INSTANCE_ID:-unavailable}\","
echo "  \"instance_type\": \"${INSTANCE_TYPE:-unavailable}\","
echo "  \"availability_zone\": \"${AVAILABILITY_ZONE:-unavailable}\","
echo "  \"private_ip\": \"${PRIVATE_IP:-unavailable}\","
echo "  \"public_ip\": \"${PUBLIC_IP:-not-assigned}\","
echo "  \"timestamp\": \"$(date -Iseconds)\","
echo "  \"uptime\": \"$(uptime -p)\","
echo "  \"load_average\": \"$(uptime | awk -F'load average:' '{print $2}')\","
echo "  \"imdsv2_token_available\": $([ ! -z "$TOKEN" ] && echo "true" || echo "false")"
echo "}"
STATUS

chmod +x /var/www/html/status

# Log successful completion with instance details
echo "$(date): Auto Scaling Group demo web server setup completed successfully" >> /var/log/user-data.log
echo "Instance ID: $INSTANCE_ID" >> /var/log/user-data.log
echo "Instance Type: $INSTANCE_TYPE" >> /var/log/user-data.log
echo "Availability Zone: $AVAILABILITY_ZONE" >> /var/log/user-data.log
echo "Private IP: $LOCAL_IPV4" >> /var/log/user-data.log
echo "Public IP: $PUBLIC_IPV4" >> /var/log/user-data.log
