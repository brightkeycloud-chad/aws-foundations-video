#!/bin/bash
# User data script for Amazon Linux 2 - Deliberately vulnerable setup

# Update system but don't upgrade packages (to keep vulnerabilities)
yum update -y

# Install older versions of packages with known vulnerabilities
yum install -y \
    httpd-2.4.54 \
    openssl-1.0.2k \
    curl-7.61.1 \
    wget-1.14 \
    git-2.23.4 \
    python3-3.7.16 \
    nodejs-16.20.0 \
    npm-8.19.4

# Install vulnerable Python packages
pip3 install \
    requests==2.25.1 \
    urllib3==1.26.5 \
    Pillow==8.3.2 \
    Django==3.2.13 \
    Flask==2.0.3

# Install vulnerable Node.js packages
npm install -g \
    lodash@4.17.20 \
    moment@2.29.1 \
    express@4.17.1 \
    axios@0.21.1

# Create a simple web server with vulnerable configuration
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Inspector Demo - Vulnerable Server</title>
</head>
<body>
    <h1>Inspector Demo - Amazon Linux 2</h1>
    <p>This server is deliberately configured with vulnerable packages for demonstration purposes.</p>
    <p>Server Information:</p>
    <ul>
        <li>OS: Amazon Linux 2</li>
        <li>Apache: Older version with known CVEs</li>
        <li>OpenSSL: Vulnerable version</li>
        <li>Python packages: Outdated with security issues</li>
    </ul>
    <p><strong>WARNING: This is for demo purposes only!</strong></p>
</body>
</html>
EOF

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create vulnerable PHP script (if PHP is available)
yum install -y php-7.2.24
cat > /var/www/html/info.php << 'EOF'
<?php
// Vulnerable PHP script for demo
phpinfo();
?>
EOF

# Install SSM agent for Inspector
yum install -y amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

# Create log entry
echo "$(date): Vulnerable Amazon Linux 2 instance setup completed" >> /var/log/inspector-demo.log

# Set up cron job with vulnerable permissions
echo "0 * * * * root /usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id >> /tmp/instance-info.log" >> /etc/crontab

# Create world-writable directory (vulnerability)
mkdir -p /tmp/vulnerable-dir
chmod 777 /tmp/vulnerable-dir

# Install Docker with older version
amazon-linux-extras install docker=18.06.1
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Log completion
echo "$(date): Inspector demo setup completed on Amazon Linux 2" >> /var/log/inspector-demo.log
