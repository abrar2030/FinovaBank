#!/bin/bash
# FinovaBank Application Server User Data Script
# This script configures application servers with security hardening and monitoring

set -e

# Variables
CLOUDWATCH_LOG_GROUP="${cloudwatch_log_group}"
REGION="${region}"
LOG_FILE="/var/log/user-data.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "Starting FinovaBank application server configuration"

# Update system packages
log "Updating system packages"
yum update -y

# Install required packages
log "Installing required packages"
yum install -y \
    docker \
    awscli \
    amazon-cloudwatch-agent \
    amazon-ssm-agent \
    htop \
    iotop \
    ntp \
    fail2ban \
    aide \
    rkhunter \
    chkrootkit \
    logrotate \
    rsyslog \
    audit

# Configure NTP for time synchronization
log "Configuring NTP"
systemctl enable ntpd
systemctl start ntpd

# Configure and start SSM agent
log "Configuring SSM agent"
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Configure Docker
log "Configuring Docker"
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user

# Create application user
log "Creating application user"
useradd -m -s /bin/bash finovaapp
usermod -a -G docker finovaapp

# Security hardening
log "Applying security hardening"

# Disable unnecessary services
systemctl disable postfix
systemctl stop postfix

# Configure SSH hardening
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#Protocol 2/Protocol 2/' /etc/ssh/sshd_config
echo "AllowUsers ec2-user finovaapp" >> /etc/ssh/sshd_config
echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config
systemctl restart sshd

# Configure fail2ban
log "Configuring fail2ban"
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = ssh
logpath = /var/log/secure
maxretry = 3
bantime = 3600
EOF

systemctl enable fail2ban
systemctl start fail2ban

# Configure firewall
log "Configuring firewall"
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Configure audit logging
log "Configuring audit logging"
cat >> /etc/audit/rules.d/audit.rules << 'EOF'
# FinovaBank Audit Rules for Financial Compliance

# Monitor file access
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k identity

# Monitor authentication events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

# Monitor network configuration
-w /etc/hosts -p wa -k network
-w /etc/sysconfig/network -p wa -k network

# Monitor system administration
-w /var/log/sudo.log -p wa -k actions
-w /etc/sudoers -p wa -k actions

# Monitor file system mounts
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts

# Monitor file deletions
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete

# Monitor privilege escalation
-w /bin/su -p x -k priv_esc
-w /usr/bin/sudo -p x -k priv_esc
-w /etc/sudoers -p rw -k priv_esc

# Monitor system calls
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change

# Make the configuration immutable
-e 2
EOF

systemctl enable auditd
systemctl restart auditd

# Configure CloudWatch agent
log "Configuring CloudWatch agent"
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/system",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/secure",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/security",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/audit/audit.log",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/audit",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/user-data",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/docker",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/docker",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "FinovaBank/EC2",
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
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                    "swap_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Configure log rotation
log "Configuring log rotation"
cat > /etc/logrotate.d/finovabank << 'EOF'
/var/log/finovabank/*.log {
    daily
    missingok
    rotate 365
    compress
    delaycompress
    notifempty
    create 644 finovaapp finovaapp
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
EOF

# Create application directories
log "Creating application directories"
mkdir -p /opt/finovabank/{app,config,logs,data}
mkdir -p /var/log/finovabank
chown -R finovaapp:finovaapp /opt/finovabank
chown -R finovaapp:finovaapp /var/log/finovabank

# Configure rsyslog for application logging
log "Configuring rsyslog"
cat > /etc/rsyslog.d/finovabank.conf << 'EOF'
# FinovaBank application logging configuration
$template FinovaBankFormat,"%timestamp:::date-rfc3339% %HOSTNAME% %syslogtag% %msg%\n"

# Application logs
local0.*    /var/log/finovabank/application.log;FinovaBankFormat
local1.*    /var/log/finovabank/security.log;FinovaBankFormat
local2.*    /var/log/finovabank/audit.log;FinovaBankFormat
local3.*    /var/log/finovabank/performance.log;FinovaBankFormat

# Stop processing after writing to files
local0.*    stop
local1.*    stop
local2.*    stop
local3.*    stop
EOF

systemctl restart rsyslog

# Install and configure AIDE (Advanced Intrusion Detection Environment)
log "Configuring AIDE"
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Create AIDE check script
cat > /usr/local/bin/aide-check.sh << 'EOF'
#!/bin/bash
# AIDE integrity check script for FinovaBank

AIDE_LOG="/var/log/aide.log"
AIDE_REPORT="/tmp/aide-report.txt"

# Run AIDE check
aide --check > $AIDE_REPORT 2>&1

# Check if there are any changes
if [ $? -ne 0 ]; then
    echo "$(date): AIDE detected file system changes" >> $AIDE_LOG
    cat $AIDE_REPORT >> $AIDE_LOG

    # Send alert to CloudWatch
    aws logs put-log-events \
        --log-group-name "$CLOUDWATCH_LOG_GROUP" \
        --log-stream-name "$(curl -s http://169.254.169.254/latest/meta-data/instance-id)/aide-alerts" \
        --log-events timestamp=$(date +%s000),message="AIDE detected file system changes: $(cat $AIDE_REPORT)" \
        --region "$REGION"
else
    echo "$(date): AIDE check completed - no changes detected" >> $AIDE_LOG
fi

# Clean up
rm -f $AIDE_REPORT
EOF

chmod +x /usr/local/bin/aide-check.sh

# Schedule AIDE checks
echo "0 2 * * * root /usr/local/bin/aide-check.sh" >> /etc/crontab

# Configure system limits for financial applications
log "Configuring system limits"
cat >> /etc/security/limits.conf << 'EOF'
# FinovaBank system limits for financial applications
finovaapp soft nofile 65536
finovaapp hard nofile 65536
finovaapp soft nproc 32768
finovaapp hard nproc 32768
EOF

# Configure kernel parameters
log "Configuring kernel parameters"
cat >> /etc/sysctl.conf << 'EOF'
# FinovaBank kernel parameters for security and performance

# Network security
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1

# Memory management
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# File system
fs.file-max = 2097152
fs.suid_dumpable = 0

# Process limits
kernel.pid_max = 4194304
EOF

sysctl -p

# Create health check endpoint
log "Creating health check endpoint"
mkdir -p /var/www/html
cat > /var/www/html/health << 'EOF'
#!/bin/bash
# FinovaBank health check script

# Check system load
LOAD=$(uptime | awk '{print $10}' | sed 's/,//')
LOAD_THRESHOLD=2.0

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
DISK_THRESHOLD=90

# Check memory usage
MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
MEM_THRESHOLD=90

# Check if Docker is running
DOCKER_STATUS=$(systemctl is-active docker)

# Health check logic
if (( $(echo "$LOAD > $LOAD_THRESHOLD" | bc -l) )); then
    echo "UNHEALTHY: High system load ($LOAD)"
    exit 1
elif [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "UNHEALTHY: High disk usage ($DISK_USAGE%)"
    exit 1
elif [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
    echo "UNHEALTHY: High memory usage ($MEM_USAGE%)"
    exit 1
elif [ "$DOCKER_STATUS" != "active" ]; then
    echo "UNHEALTHY: Docker service not running"
    exit 1
else
    echo "HEALTHY: All systems operational"
    exit 0
fi
EOF

chmod +x /var/www/html/health

# Install and configure simple HTTP server for health checks
log "Installing simple HTTP server"
yum install -y python3
cat > /etc/systemd/system/health-server.service << 'EOF'
[Unit]
Description=FinovaBank Health Check Server
After=network.target

[Service]
Type=simple
User=finovaapp
WorkingDirectory=/var/www/html
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable health-server
systemctl start health-server

# Create application startup script
log "Creating application startup script"
cat > /opt/finovabank/start-app.sh << 'EOF'
#!/bin/bash
# FinovaBank application startup script

set -e

APP_DIR="/opt/finovabank/app"
CONFIG_DIR="/opt/finovabank/config"
LOG_DIR="/var/log/finovabank"

# Source environment variables
if [ -f "$CONFIG_DIR/app.env" ]; then
    source "$CONFIG_DIR/app.env"
fi

# Start application container
docker run -d \
    --name finovabank-app \
    --restart unless-stopped \
    -p 8080:8080 \
    -v "$CONFIG_DIR:/app/config:ro" \
    -v "$LOG_DIR:/app/logs" \
    -e ENVIRONMENT="production" \
    -e LOG_LEVEL="info" \
    finovabank/app:latest

# Wait for application to start
sleep 10

# Verify application is running
if ! curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "Application failed to start properly"
    exit 1
fi

echo "FinovaBank application started successfully"
EOF

chmod +x /opt/finovabank/start-app.sh
chown finovaapp:finovaapp /opt/finovabank/start-app.sh

# Create monitoring script
log "Creating monitoring script"
cat > /usr/local/bin/finovabank-monitor.sh << 'EOF'
#!/bin/bash
# FinovaBank monitoring script

CLOUDWATCH_LOG_GROUP="$1"
REGION="$2"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Function to send metric to CloudWatch
send_metric() {
    local metric_name="$1"
    local value="$2"
    local unit="$3"

    aws cloudwatch put-metric-data \
        --namespace "FinovaBank/Application" \
        --metric-data MetricName="$metric_name",Value="$value",Unit="$unit",Dimensions=InstanceId="$INSTANCE_ID" \
        --region "$REGION"
}

# Monitor application health
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    send_metric "ApplicationHealth" 1 "Count"
else
    send_metric "ApplicationHealth" 0 "Count"
fi

# Monitor Docker container status
if docker ps | grep -q finovabank-app; then
    send_metric "ContainerHealth" 1 "Count"
else
    send_metric "ContainerHealth" 0 "Count"
fi

# Monitor disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
send_metric "DiskUsage" "$DISK_USAGE" "Percent"

# Monitor memory usage
MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
send_metric "MemoryUsage" "$MEM_USAGE" "Percent"

# Monitor active connections
CONNECTIONS=$(netstat -an | grep :8080 | grep ESTABLISHED | wc -l)
send_metric "ActiveConnections" "$CONNECTIONS" "Count"
EOF

chmod +x /usr/local/bin/finovabank-monitor.sh

# Schedule monitoring script
echo "*/5 * * * * root /usr/local/bin/finovabank-monitor.sh '$CLOUDWATCH_LOG_GROUP' '$REGION'" >> /etc/crontab

# Configure automatic security updates
log "Configuring automatic security updates"
yum install -y yum-cron
sed -i 's/update_cmd = default/update_cmd = security/' /etc/yum/yum-cron.conf
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
systemctl enable yum-cron
systemctl start yum-cron

# Create backup script for application data
log "Creating backup script"
cat > /usr/local/bin/backup-app-data.sh << 'EOF'
#!/bin/bash
# FinovaBank application data backup script

BACKUP_DIR="/opt/finovabank/backups"
DATE=$(date +%Y%m%d_%H%M%S)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

mkdir -p "$BACKUP_DIR"

# Backup application configuration
tar -czf "$BACKUP_DIR/config_$${INSTANCE_ID}_$${DATE}.tar.gz" -C /opt/finovabank config/

# Backup application logs
tar -czf "$BACKUP_DIR/logs_$${INSTANCE_ID}_$${DATE}.tar.gz" -C /var/log finovabank/

# Clean up old backups (keep last 7 days)
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /usr/local/bin/backup-app-data.sh

# Schedule daily backups
echo "0 1 * * * root /usr/local/bin/backup-app-data.sh" >> /etc/crontab

# Final security hardening
log "Applying final security hardening"

# Remove unnecessary packages
yum remove -y telnet rsh-server rsh ypbind ypserv tftp tftp-server talk talk-server

# Set proper permissions on sensitive files
chmod 600 /etc/ssh/sshd_config
chmod 600 /etc/shadow
chmod 644 /etc/passwd
chmod 644 /etc/group

# Disable core dumps
echo "* hard core 0" >> /etc/security/limits.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf

# Configure banner
cat > /etc/issue << 'EOF'
***************************************************************************
                            FINOVABANK SYSTEMS
                          AUTHORIZED ACCESS ONLY

This system is for the use of authorized users only. Individuals using
this computer system without authority, or in excess of their authority,
are subject to having all of their activities on this system monitored
and recorded by system personnel.

In the course of monitoring individuals improperly using this system, or
in the course of system maintenance, the activities of authorized users
may also be monitored.

Anyone using this system expressly consents to such monitoring and is
advised that if such monitoring reveals possible evidence of criminal
activity, system personnel may provide the evidence to law enforcement
officials.

All activities on this system are logged and monitored.
***************************************************************************
EOF

cp /etc/issue /etc/issue.net

# Restart services to apply all configurations
log "Restarting services"
systemctl restart sshd
systemctl restart rsyslog
systemctl restart crond

# Signal completion
log "FinovaBank application server configuration completed successfully"

# Send completion notification to CloudWatch
aws logs put-log-events \
    --log-group-name "$CLOUDWATCH_LOG_GROUP" \
    --log-stream-name "$${INSTANCE_ID}/user-data" \
    --log-events timestamp=$(date +%s000),message="FinovaBank application server configuration completed successfully" \
    --region "$REGION"

exit 0
