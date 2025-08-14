# Dockerfile for creating vulnerable container images for Inspector demo
# Uses older base images and packages with known vulnerabilities

# Use older Ubuntu base image with known vulnerabilities
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV APP_HOME=/app

# Install vulnerable packages without updates
RUN apt-get update && apt-get install -y \
    apache2=2.4.41-4ubuntu3.14 \
    openssl=1.1.1f-1ubuntu2.16 \
    curl=7.68.0-1ubuntu2.14 \
    wget=1.20.3-1ubuntu2 \
    git=1:2.25.1-1ubuntu3.6 \
    python3=3.8.2-0ubuntu2 \
    python3-pip=20.0.2-5ubuntu1.9 \
    nodejs=10.19.0~dfsg-3ubuntu1 \
    npm=6.14.4+ds-1ubuntu2 \
    php7.4=7.4.3-4ubuntu2.15 \
    php7.4-apache2 \
    libapache2-mod-php7.4 \
    mysql-client=8.0.32-0ubuntu0.20.04.2 \
    && apt-mark hold apache2 openssl curl wget git python3 python3-pip nodejs npm php7.4 php7.4-apache2 mysql-client

# Install vulnerable Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

# Install vulnerable Node.js packages globally
RUN npm install -g \
    lodash@4.17.20 \
    moment@2.29.1 \
    express@4.17.1 \
    axios@0.21.1 \
    handlebars@4.7.6 \
    serialize-javascript@3.1.0 \
    minimist@1.2.5

# Create application directory
WORKDIR $APP_HOME

# Copy vulnerable application files
COPY app/ $APP_HOME/

# Create vulnerable web content
RUN echo '<!DOCTYPE html>\n\
<html>\n\
<head>\n\
    <title>Inspector Demo - Vulnerable Container</title>\n\
</head>\n\
<body>\n\
    <h1>Inspector Demo - Vulnerable Container</h1>\n\
    <p>This container is deliberately configured with vulnerable packages.</p>\n\
    <p>Vulnerable Components:</p>\n\
    <ul>\n\
        <li>Ubuntu 20.04 (older version)</li>\n\
        <li>Apache 2.4.41 (vulnerable)</li>\n\
        <li>OpenSSL 1.1.1f (vulnerable)</li>\n\
        <li>Python 3.8.2 with vulnerable packages</li>\n\
        <li>Node.js 10.19.0 with vulnerable packages</li>\n\
        <li>PHP 7.4.3 (vulnerable)</li>\n\
    </ul>\n\
    <p><strong>WARNING: For demo purposes only!</strong></p>\n\
</body>\n\
</html>' > /var/www/html/index.html

# Create vulnerable PHP info page
RUN echo '<?php\n\
// Vulnerable PHP script for demo\n\
phpinfo();\n\
?>' > /var/www/html/info.php

# Create vulnerable Python web app
RUN echo 'from flask import Flask, request, render_template_string\n\
import os\n\
\n\
app = Flask(__name__)\n\
\n\
# Vulnerable: Template injection\n\
@app.route("/", methods=["GET", "POST"])\n\
def home():\n\
    if request.method == "POST":\n\
        user_input = request.form.get("input", "")\n\
        # VULNERABILITY: Template injection\n\
        template = f"<h1>Hello {user_input}!</h1>"\n\
        return render_template_string(template)\n\
    return """<form method="post">\n\
        <input type="text" name="input" placeholder="Enter your name">\n\
        <input type="submit" value="Submit">\n\
    </form>"""\n\
\n\
# Vulnerable: Information disclosure\n\
@app.route("/debug")\n\
def debug():\n\
    return {"env": dict(os.environ), "vulnerable": True}\n\
\n\
if __name__ == "__main__":\n\
    app.run(host="0.0.0.0", port=5000, debug=True)  # Debug mode in production - VULNERABILITY\n\
' > $APP_HOME/app.py

# Set vulnerable permissions
RUN chmod 777 /tmp \
    && chmod 755 /var/www/html \
    && chmod 644 /var/www/html/* \
    && mkdir -p /app/logs \
    && chmod 777 /app/logs

# Expose ports
EXPOSE 80 5000

# Create startup script
RUN echo '#!/bin/bash\n\
service apache2 start\n\
python3 /app/app.py &\n\
tail -f /var/log/apache2/access.log\n\
' > /start.sh && chmod +x /start.sh

# Use vulnerable startup command
CMD ["/start.sh"]
