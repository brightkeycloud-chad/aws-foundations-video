#!/bin/bash

# Update the system
yum update -y

# Install useful networking tools
yum install -y telnet traceroute nmap-ncat

# Ensure SSM agent is installed and running (should be by default on AL2023)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Verify SSM agent status
systemctl status amazon-ssm-agent --no-pager

# Create a simple identification file
echo "This instance is in ${vpc_name}" > /home/ec2-user/vpc_info.txt
echo "Instance started at: $(date)" >> /home/ec2-user/vpc_info.txt
echo "Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)" >> /home/ec2-user/vpc_info.txt
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" >> /home/ec2-user/vpc_info.txt
echo "SSM Agent Status: $(systemctl is-active amazon-ssm-agent)" >> /home/ec2-user/vpc_info.txt
echo "Internet Access: Via NAT Gateway" >> /home/ec2-user/vpc_info.txt

# Set ownership
chown ec2-user:ec2-user /home/ec2-user/vpc_info.txt

# Create a simple web server for testing connectivity
cat > /home/ec2-user/simple_server.py << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import socket

PORT = 8080

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
        
        response = f"""
        <html>
        <body>
        <h1>VPC Peering Demo Server</h1>
        <p><strong>VPC:</strong> ${vpc_name}</p>
        <p><strong>Hostname:</strong> {hostname}</p>
        <p><strong>Local IP:</strong> {local_ip}</p>
        <p><strong>Request from:</strong> {self.client_address[0]}</p>
        <p>This server is running to test VPC peering connectivity!</p>
        </body>
        </html>
        """
        self.wfile.write(response.encode())

with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    print(f"Server running on port {PORT}")
    httpd.serve_forever()
EOF

# Make the script executable
chmod +x /home/ec2-user/simple_server.py
chown ec2-user:ec2-user /home/ec2-user/simple_server.py

# Create a systemd service for the simple server
cat > /etc/systemd/system/simple-server.service << EOF
[Unit]
Description=Simple HTTP Server for VPC Peering Demo
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 /home/ec2-user/simple_server.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable simple-server.service
systemctl start simple-server.service

# Create helpful aliases for ec2-user
cat >> /home/ec2-user/.bashrc << 'EOF'

# VPC Peering Demo aliases
alias vpc-info='cat ~/vpc_info.txt'
alias check-connectivity='echo "Testing connectivity to other VPC..." && echo "Use: ping <other-vpc-instance-ip>"'
alias server-status='systemctl status simple-server.service'
alias server-logs='journalctl -u simple-server.service -f'
alias ssm-status='systemctl status amazon-ssm-agent'

echo "VPC Peering Demo Instance Ready!"
echo "Use 'vpc-info' to see instance information"
echo "Use 'check-connectivity' for testing instructions"
echo "Use 'ssm-status' to check SSM agent status"
echo "Simple HTTP server running on port 8080"
EOF

# Log completion
echo "User data script completed at $(date)" >> /var/log/user-data.log
