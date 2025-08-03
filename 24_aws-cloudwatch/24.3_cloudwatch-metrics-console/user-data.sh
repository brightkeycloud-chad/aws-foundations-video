#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user data script at $(date)"

yum update -y

# Ensure SSM agent is installed and running (should be pre-installed on AL2023)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl status amazon-ssm-agent

# Install stress testing tools and monitoring utilities
yum install -y stress-ng htop sysstat

# Install and start Apache web server
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Ensure ec2-user home directory exists and has proper permissions
mkdir -p /home/ec2-user
chown ec2-user:ec2-user /home/ec2-user
chmod 755 /home/ec2-user

# Create a simple web page
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>CloudWatch Metrics Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .info-box { background-color: #f0f0f0; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .command { background-color: #2d3748; color: #e2e8f0; padding: 10px; border-radius: 3px; font-family: monospace; }
    </style>
</head>
<body>
    <h1>🚀 CloudWatch Metrics Demo Instance</h1>
    <p>This EC2 instance is configured for CloudWatch metrics demonstration with detailed monitoring enabled.</p>
    
    <div class="info-box">
        <h3>Instance Information</h3>
        <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
        <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
        <p><strong>Instance Type:</strong> <span id="instance-type">Loading...</span></p>
        <p><strong>Private IP:</strong> <span id="private-ip">Loading...</span></p>
    </div>
    
    <div class="info-box">
        <h3>🔧 Access Methods</h3>
        <p><strong>SSH Access:</strong> Use your key pair if configured</p>
        <p><strong>Session Manager:</strong> Available via AWS Console → EC2 → Connect → Session Manager</p>
        <p><strong>No key pair needed</strong> for Session Manager access!</p>
    </div>
    
    <div class="info-box">
        <h3>📊 Generate Load for CloudWatch Testing</h3>
        <p>Connect via Session Manager and run these commands:</p>
        
        <h4>Manual Commands:</h4>
        <div class="command">stress-ng --cpu 2 --timeout 300s &</div>
        <div class="command">stress-ng --vm 1 --vm-bytes 512M --timeout 300s &</div>
        <div class="command">dd if=/dev/zero of=/tmp/testfile bs=1M count=100</div>
        
        <h4>Automated Script (if available):</h4>
        <div class="command">cd /home/ec2-user && ./generate-load.sh</div>
    </div>
    
    <div class="info-box">
        <h3>📈 Monitor in CloudWatch</h3>
        <p>After generating load, check these metrics in CloudWatch:</p>
        <ul>
            <li><strong>CPUUtilization</strong> - Should spike during CPU tests</li>
            <li><strong>NetworkIn/NetworkOut</strong> - Network traffic</li>
            <li><strong>DiskReadOps/DiskWriteOps</strong> - Disk I/O operations</li>
            <li><strong>StatusCheckFailed</strong> - Instance health</li>
        </ul>
    </div>
    
    <script>
        // Fetch instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data)
            .catch(() => document.getElementById('instance-id').textContent = 'Unable to fetch');
            
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('az').textContent = data)
            .catch(() => document.getElementById('az').textContent = 'Unable to fetch');
            
        fetch('http://169.254.169.254/latest/meta-data/instance-type')
            .then(response => response.text())
            .then(data => document.getElementById('instance-type').textContent = data)
            .catch(() => document.getElementById('instance-type').textContent = 'Unable to fetch');
            
        fetch('http://169.254.169.254/latest/meta-data/local-ipv4')
            .then(response => response.text())
            .then(data => document.getElementById('private-ip').textContent = data)
            .catch(() => document.getElementById('private-ip').textContent = 'Unable to fetch');
    </script>
</body>
</html>
HTML

echo "Creating load generation script..."
# Create a script for easy load generation
cat > /home/ec2-user/generate-load.sh << 'SCRIPT'
#!/bin/bash
echo "🚀 Starting comprehensive load test for CloudWatch metrics demo..."
echo "This will run for 5 minutes to generate visible metrics."
echo ""

echo "📊 Starting CPU load test (2 cores)..."
stress-ng --cpu 2 --timeout 300s &
CPU_PID=$!

echo "💾 Starting memory load test (512MB)..."
stress-ng --vm 1 --vm-bytes 512M --timeout 300s &
MEM_PID=$!

echo "💿 Starting disk I/O test..."
(
    for i in {1..5}; do
        dd if=/dev/zero of=/tmp/testfile_$i bs=1M count=50 2>/dev/null
        rm -f /tmp/testfile_$i
        sleep 30
    done
) &
DISK_PID=$!

echo ""
echo "✅ Load generation started! Processes:"
echo "   CPU Load PID: $CPU_PID"
echo "   Memory Load PID: $MEM_PID" 
echo "   Disk I/O PID: $DISK_PID"
echo ""
echo "🔍 Monitor these metrics in CloudWatch console:"
echo "   - CPUUtilization (should reach 80-100%)"
echo "   - NetworkIn/NetworkOut"
echo "   - DiskReadOps/DiskWriteOps"
echo "   - Check detailed monitoring for 1-minute intervals"
echo ""
echo "⏱️  Tests will run for 5 minutes..."
echo "💡 Tip: Refresh your CloudWatch dashboard to see real-time changes!"

# Wait for processes to complete
wait $CPU_PID $MEM_PID $DISK_PID

echo ""
echo "✅ Load generation completed!"
echo "📈 Check CloudWatch metrics now for the results."
SCRIPT

echo "Setting permissions for generate-load.sh..."
chmod +x /home/ec2-user/generate-load.sh
chown ec2-user:ec2-user /home/ec2-user/generate-load.sh

echo "Creating system info script..."
# Create a simple system info script
cat > /home/ec2-user/system-info.sh << 'INFO'
#!/bin/bash
echo "=== System Information ==="
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
echo "Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)"
echo "Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
echo "Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo ""
echo "=== SSM Agent Status ==="
systemctl status amazon-ssm-agent --no-pager
echo ""
echo "=== Current System Load ==="
uptime
echo ""
echo "=== Memory Usage ==="
free -h
echo ""
echo "=== Disk Usage ==="
df -h
echo ""
echo "=== Available Scripts ==="
ls -la /home/ec2-user/*.sh 2>/dev/null || echo "No scripts found in /home/ec2-user"
INFO

echo "Setting permissions for system-info.sh..."
chmod +x /home/ec2-user/system-info.sh
chown ec2-user:ec2-user /home/ec2-user/system-info.sh

# Create a simple load test script that doesn't require the main script
echo "Creating simple load test script..."
cat > /home/ec2-user/simple-load.sh << 'SIMPLE'
#!/bin/bash
echo "Starting simple load test..."
echo "CPU test for 2 minutes..."
stress-ng --cpu 1 --timeout 120s &
echo "Memory test for 2 minutes..."  
stress-ng --vm 1 --vm-bytes 256M --timeout 120s &
echo "Disk I/O test..."
dd if=/dev/zero of=/tmp/testfile bs=1M count=50
rm -f /tmp/testfile
echo "Load test completed!"
SIMPLE

chmod +x /home/ec2-user/simple-load.sh
chown ec2-user:ec2-user /home/ec2-user/simple-load.sh

# Verify scripts were created
echo "Verifying script creation..."
ls -la /home/ec2-user/*.sh

# Log completion
echo "User data script completed at $(date)"
echo "SSM Agent status: $(systemctl is-active amazon-ssm-agent)"
echo "Scripts created: $(ls /home/ec2-user/*.sh 2>/dev/null | wc -l)"
