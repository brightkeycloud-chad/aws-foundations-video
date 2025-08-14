#!/bin/bash
# User data script for Ubuntu - Deliberately vulnerable setup

# Update package list but don't upgrade (to keep vulnerabilities)
apt-get update

# Install older versions of packages with known vulnerabilities
apt-get install -y \
    apache2=2.4.41-4ubuntu3.14 \
    openssl=1.1.1f-1ubuntu2.16 \
    curl=7.68.0-1ubuntu2.14 \
    wget=1.20.3-1ubuntu2 \
    git=1:2.25.1-1ubuntu3.6 \
    python3=3.8.2-0ubuntu2 \
    python3-pip=20.0.2-5ubuntu1.9 \
    nodejs=10.19.0~dfsg-3ubuntu1 \
    npm=6.14.4+ds-1ubuntu2

# Hold packages to prevent automatic updates
apt-mark hold apache2 openssl curl wget git python3 python3-pip nodejs npm

# Install vulnerable Python packages
pip3 install \
    requests==2.25.1 \
    urllib3==1.26.5 \
    Pillow==8.3.2 \
    Django==3.2.13 \
    Flask==2.0.3 \
    Jinja2==2.11.3

# Install vulnerable Node.js packages
npm install -g \
    lodash@4.17.20 \
    moment@2.29.1 \
    express@4.17.1 \
    axios@0.21.1 \
    handlebars@4.7.6

# Create a simple web server with vulnerable configuration
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Inspector Demo - Vulnerable Ubuntu Server</title>
</head>
<body>
    <h1>Inspector Demo - Ubuntu 20.04</h1>
    <p>This server is deliberately configured with vulnerable packages for demonstration purposes.</p>
    <p>Server Information:</p>
    <ul>
        <li>OS: Ubuntu 20.04 LTS</li>
        <li>Apache: Older version with known CVEs</li>
        <li>OpenSSL: Vulnerable version</li>
        <li>Python packages: Outdated with security issues</li>
        <li>Node.js packages: Vulnerable versions</li>
    </ul>
    <p><strong>WARNING: This is for demo purposes only!</strong></p>
</body>
</html>
EOF

# Install PHP with vulnerable version
apt-get install -y php7.4=7.4.3-4ubuntu2.15 php7.4-apache2
apt-mark hold php7.4 php7.4-apache2

cat > /var/www/html/info.php << 'EOF'
<?php
// Vulnerable PHP script for demo
phpinfo();
?>
EOF

# Start and enable Apache
systemctl start apache2
systemctl enable apache2

# Install AWS CLI and SSM agent
apt-get install -y awscli
snap install amazon-ssm-agent --classic
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service

# Create log entry
echo "$(date): Vulnerable Ubuntu instance setup completed" >> /var/log/inspector-demo.log

# Set up cron job with vulnerable permissions
echo "0 * * * * root /usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id >> /tmp/instance-info.log" >> /etc/crontab

# Create world-writable directory (vulnerability)
mkdir -p /tmp/vulnerable-dir
chmod 777 /tmp/vulnerable-dir

# Install Docker with older version
apt-get install -y docker.io=20.10.12-0ubuntu2~20.04.1
apt-mark hold docker.io
systemctl start docker
systemctl enable docker
usermod -a -G docker ubuntu

# Install vulnerable Ruby gems
apt-get install -y ruby=1:2.7.0+1 ruby-dev=1:2.7.0+1
gem install rails -v 6.1.4.1
gem install nokogiri -v 1.12.5

# Create vulnerable configuration files
cat > /etc/apache2/conf-available/vulnerable.conf << 'EOF'
# Vulnerable Apache configuration for demo
ServerTokens Full
ServerSignature On
TraceEnable On

<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF

a2enconf vulnerable
systemctl reload apache2

# Log completion
echo "$(date): Inspector demo setup completed on Ubuntu" >> /var/log/inspector-demo.log
