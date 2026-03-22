#!/bin/bash

# This is my modified `User Data` script for the web server
# It is designed to be compatible with Linux 2/2023 and Debian/Ubuntu

# Debugging Step
# -x enables a mode of the shell where all executed commands are printed to the terminal
# -e causes the script to exit immediately if any command exits with a non-zero status
set -xe

# Creates error logs for debugging purposes
# Redirects both stdout and stderr to /var/log/user-data.log 
# (2>&1 means redirect stderr to the same place as stdout)
# Reminder: 0 = stdin, 1 = stdout, 2 = stderr
exec > /var/log/user-data.log 2>&1

# Detect package manager / distro family
if command -v dnf >/dev/null 2>&1; then # Amazon Linux 2023 and newer distros
    dnf update -y
    dnf install -y httpd curl
elif command -v yum >/dev/null 2>&1; then # Amazon Linux 2 and older distros
    yum update -y
    yum install -y httpd curl
elif command -v apt-get >/dev/null 2>&1; then # Debian/Ubuntu-based distros
    apt-get update -y
    apt-get install -y apache2 curl
fi

# Fetch AZ via IMDSv2, with fallback text if metadata call fails
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone || echo "unknown")

# Write the page
mkdir -p /var/www/html
cat > /var/www/html/index.html <<EOF
<html>
<head>
    <title>Instance Availability Zone</title>
    <style>
        body {
            background-color: #6495ED;
            color: white;
            font-size: 36px;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
        }
    </style>
</head>
<body>
    <div>This instance is located in Availability Zone: $AZ</div>
</body>
</html>
EOF

# Start the web server depending on distro
if systemctl list-unit-files | grep -q '^httpd'; then # Amazon Linux 2/2023
    systemctl enable --now httpd    # --now enables and starts the service immediately
elif systemctl list-unit-files | grep -q '^apache2'; then # Debian/Ubuntu
    systemctl enable --now apache2  # --now enables and starts the service immediately
fi