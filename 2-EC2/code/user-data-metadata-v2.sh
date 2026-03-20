#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable --now httpd

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
EC2ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

echo "<center><h1>The instance ID of this Amazon EC2 instance is: $EC2ID</h1></center>" > /var/www/html/index.html