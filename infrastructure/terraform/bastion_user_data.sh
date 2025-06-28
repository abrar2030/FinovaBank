#!/bin/bash
# FinovaBank Bastion Host User Data Script
# This script configures the bastion host with enhanced security and monitoring

set -e

# Variables
CLOUDWATCH_LOG_GROUP="${cloudwatch_log_group}"
REGION="${region}"
LOG_FILE="/var/log/bastion-setup.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "Starting FinovaBank bastion host configuration"

# Update system packages
log "Updating system packages"
yum update -y

# Install required packages
log "Installing required packages"
yum install -y \
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
    audit \
    tcpdump \
    nmap \
    telnet \
    nc \
    traceroute \
    mtr \
    iperf3

# Configure NTP for time synchronization
log "Configuring NTP"
systemctl enable ntpd
systemctl start ntpd

# Configure and start SSM agent
log "Configuring SSM agent"
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Enhanced SSH security configuration for bastion
log "Configuring enhanced SSH security"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

cat > /etc/ssh/sshd_config << 'EOF'
# FinovaBank Bastion Host SSH Configuration
# Enhanced security configuration for financial services

# Protocol and encryption
Protocol 2
Port 22

# Host keys
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and algorithms
Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# Authentication
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
AuthenticationMethods publickey

# Access control
AllowUsers ec2-user
DenyUsers root
MaxAuthTries 3
MaxSessions 2
MaxStartups 2

# Session management
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
TCPKeepAlive no

# Logging
SyslogFacility AUTHPRIV
LogLevel VERBOSE

# Forwarding and tunneling
AllowAgentForwarding yes
AllowTcpForwarding yes
GatewayPorts no
X11Forwarding no
PermitTunnel no

# Banner and MOTD
Banner /etc/ssh/banner
PrintMotd yes
PrintLastLog yes

# Miscellaneous
Compression no
UseDNS no
PermitEmptyPasswords no
PermitUserEnvironment no
StrictModes yes
EOF

# Create SSH banner
cat > /etc/ssh/banner << 'EOF'
***************************************************************************
                        FINOVABANK BASTION HOST
                          AUTHORIZED ACCESS ONLY

This bastion host provides secure administrative access to FinovaBank
infrastructure. All connections are monitored and logged.

By connecting to this system, you acknowledge that:
- All activities are subject to monitoring and recording
- Unauthorized access is strictly prohibited
- All actions must comply with FinovaBank security policies
- Evidence of unauthorized activity may be provided to law enforcement

For support, contact: infrastructure@finovabank.com
***************************************************************************
EOF

systemctl restart sshd

# Configure fail2ban with enhanced rules
log "Configuring fail2ban"
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 7200
findtime = 600
maxretry = 3
backend = systemd
destemail = security@finovabank.com
sendername = FinovaBank-Bastion-Security
mta = sendmail

[sshd]
enabled = true
port = ssh
logpath = /var/log/secure
maxretry = 3
bantime = 7200
findtime = 600

[sshd-ddos]
enabled = true
port = ssh
logpath = /var/log/secure
maxretry = 6
bantime = 7200
findtime = 120

[recidive]
enabled = true
logpath = /var/log/fail2ban.log
banaction = iptables-allports
bantime = 86400
findtime = 86400
maxretry = 3
EOF

systemctl enable fail2ban
systemctl start fail2ban

# Configure enhanced firewall rules
log "Configuring enhanced firewall"
systemctl enable firewalld
systemctl start firewalld

# Allow SSH from admin networks only
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.0.0/8" service name="ssh" accept'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.0.0/12" service name="ssh" accept'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.0.0/16" service name="ssh" accept'

# Log dropped packets
firewall-cmd --permanent --set-log-denied=all

firewall-cmd --reload

# Configure comprehensive audit logging
log "Configuring comprehensive audit logging"
cat > /etc/audit/rules.d/bastion.rules << 'EOF'
# FinovaBank Bastion Host Audit Rules
# Comprehensive logging for administrative access

# Remove any existing rules
-D

# Buffer size
-b 8192

# Failure mode (0=silent, 1=printk, 2=panic)
-f 1

# Monitor all authentication events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins
-w /var/log/wtmp -p wa -k logins
-w /var/log/btmp -p wa -k logins

# Monitor user and group modifications
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# Monitor sudo usage
-w /var/log/sudo.log -p wa -k actions
-w /etc/sudoers -p wa -k actions
-w /etc/sudoers.d/ -p wa -k actions

# Monitor SSH configuration
-w /etc/ssh/sshd_config -p wa -k sshd
-w /etc/ssh/ssh_config -p wa -k ssh_config

# Monitor network configuration
-w /etc/hosts -p wa -k network
-w /etc/sysconfig/network -p wa -k network
-w /etc/sysconfig/network-scripts/ -p wa -k network

# Monitor system administration
-w /bin/su -p x -k priv_esc
-w /usr/bin/sudo -p x -k priv_esc
-w /usr/bin/ssh -p x -k ssh_usage
-w /usr/bin/scp -p x -k file_transfer
-w /usr/bin/sftp -p x -k file_transfer

# Monitor file system mounts
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts

# Monitor file deletions
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete

# Monitor system calls
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change

# Monitor kernel module loading
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules

# Monitor system startup scripts
-w /etc/inittab -p wa -k init
-w /etc/init.d/ -p wa -k init
-w /etc/init/ -p wa -k init

# Make the configuration immutable
-e 2
EOF

systemctl enable auditd
systemctl restart auditd

# Configure CloudWatch agent for bastion-specific monitoring
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
                        "file_path": "/var/log/secure",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/ssh-access",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/audit/audit.log",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/audit",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/fail2ban.log",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/fail2ban",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/system",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/bastion-setup.log",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/setup",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "FinovaBank/Bastion",
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

# Create SSH session monitoring script
log "Creating SSH session monitoring script"
cat > /usr/local/bin/monitor-ssh-sessions.sh << 'EOF'
#!/bin/bash
# SSH session monitoring script for FinovaBank bastion host

CLOUDWATCH_LOG_GROUP="$1"
REGION="$2"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Function to send metric to CloudWatch
send_metric() {
    local metric_name="$1"
    local value="$2"
    local unit="$3"
    
    aws cloudwatch put-metric-data \
        --namespace "FinovaBank/Bastion" \
        --metric-data MetricName="$metric_name",Value="$value",Unit="$unit",Dimensions=InstanceId="$INSTANCE_ID" \
        --region "$REGION"
}

# Count active SSH sessions
ACTIVE_SESSIONS=$(who | wc -l)
send_metric "ActiveSSHSessions" "$ACTIVE_SESSIONS" "Count"

# Count failed login attempts in the last 5 minutes
FAILED_LOGINS=$(grep "Failed password" /var/log/secure | grep "$(date '+%b %d %H:%M' -d '5 minutes ago')" | wc -l)
send_metric "FailedLoginAttempts" "$FAILED_LOGINS" "Count"

# Count successful logins in the last 5 minutes
SUCCESSFUL_LOGINS=$(grep "Accepted publickey" /var/log/secure | grep "$(date '+%b %d %H:%M' -d '5 minutes ago')" | wc -l)
send_metric "SuccessfulLogins" "$SUCCESSFUL_LOGINS" "Count"

# Check for banned IPs
BANNED_IPS=$(fail2ban-client status sshd | grep "Banned IP list" | awk -F: '{print $2}' | wc -w)
send_metric "BannedIPs" "$BANNED_IPS" "Count"

# Monitor disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
send_metric "DiskUsage" "$DISK_USAGE" "Percent"

# Monitor memory usage
MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
send_metric "MemoryUsage" "$MEM_USAGE" "Percent"
EOF

chmod +x /usr/local/bin/monitor-ssh-sessions.sh

# Schedule SSH session monitoring
echo "*/5 * * * * root /usr/local/bin/monitor-ssh-sessions.sh '$CLOUDWATCH_LOG_GROUP' '$REGION'" >> /etc/crontab

# Create connection logging script
log "Creating connection logging script"
cat > /usr/local/bin/log-connections.sh << 'EOF'
#!/bin/bash
# Connection logging script for FinovaBank bastion host

LOG_FILE="/var/log/bastion-connections.log"
CLOUDWATCH_LOG_GROUP="$1"
REGION="$2"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Function to log connection details
log_connection() {
    local event_type="$1"
    local user="$2"
    local source_ip="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "$timestamp - $event_type - User: $user - Source IP: $source_ip" >> $LOG_FILE
    
    # Send to CloudWatch
    aws logs put-log-events \
        --log-group-name "$CLOUDWATCH_LOG_GROUP" \
        --log-stream-name "$INSTANCE_ID/connections" \
        --log-events timestamp=$(date +%s000),message="$event_type - User: $user - Source IP: $source_ip" \
        --region "$REGION"
}

# Monitor for new SSH connections
tail -F /var/log/secure | while read line; do
    if echo "$line" | grep -q "Accepted publickey"; then
        USER=$(echo "$line" | awk '{print $9}')
        SOURCE_IP=$(echo "$line" | awk '{print $11}')
        log_connection "SSH_LOGIN" "$USER" "$SOURCE_IP"
    elif echo "$line" | grep -q "session closed"; then
        USER=$(echo "$line" | awk '{print $11}')
        log_connection "SSH_LOGOUT" "$USER" "N/A"
    elif echo "$line" | grep -q "Failed password"; then
        USER=$(echo "$line" | awk '{print $9}')
        SOURCE_IP=$(echo "$line" | awk '{print $11}')
        log_connection "SSH_FAILED" "$USER" "$SOURCE_IP"
    fi
done &
EOF

chmod +x /usr/local/bin/log-connections.sh

# Start connection logging as a service
cat > /etc/systemd/system/bastion-logger.service << 'EOF'
[Unit]
Description=FinovaBank Bastion Connection Logger
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/log-connections.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable bastion-logger
systemctl start bastion-logger

# Configure log rotation for bastion-specific logs
log "Configuring log rotation"
cat > /etc/logrotate.d/bastion << 'EOF'
/var/log/bastion-*.log {
    daily
    missingok
    rotate 365
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
EOF

# Install and configure AIDE
log "Configuring AIDE"
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Create AIDE check script for bastion
cat > /usr/local/bin/bastion-aide-check.sh << 'EOF'
#!/bin/bash
# AIDE integrity check script for FinovaBank bastion host

AIDE_LOG="/var/log/bastion-aide.log"
AIDE_REPORT="/tmp/aide-report.txt"
CLOUDWATCH_LOG_GROUP="$1"
REGION="$2"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Run AIDE check
aide --check > $AIDE_REPORT 2>&1

# Check if there are any changes
if [ $? -ne 0 ]; then
    echo "$(date): AIDE detected file system changes on bastion host" >> $AIDE_LOG
    cat $AIDE_REPORT >> $AIDE_LOG
    
    # Send critical alert to CloudWatch
    aws logs put-log-events \
        --log-group-name "$CLOUDWATCH_LOG_GROUP" \
        --log-stream-name "$INSTANCE_ID/aide-alerts" \
        --log-events timestamp=$(date +%s000),message="CRITICAL: AIDE detected file system changes on bastion host: $(cat $AIDE_REPORT)" \
        --region "$REGION"
else
    echo "$(date): AIDE check completed - no changes detected" >> $AIDE_LOG
fi

# Clean up
rm -f $AIDE_REPORT
EOF

chmod +x /usr/local/bin/bastion-aide-check.sh

# Schedule AIDE checks every 4 hours for bastion
echo "0 */4 * * * root /usr/local/bin/bastion-aide-check.sh '$CLOUDWATCH_LOG_GROUP' '$REGION'" >> /etc/crontab

# Create security hardening script
log "Applying security hardening"
cat > /usr/local/bin/harden-bastion.sh << 'EOF'
#!/bin/bash
# Security hardening script for FinovaBank bastion host

# Disable unnecessary services
systemctl disable postfix
systemctl stop postfix

# Remove unnecessary packages
yum remove -y telnet rsh-server rsh ypbind ypserv tftp tftp-server talk talk-server

# Set proper file permissions
chmod 700 /root
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub
chmod 600 /etc/shadow
chmod 644 /etc/passwd
chmod 644 /etc/group

# Configure umask
echo "umask 027" >> /etc/profile
echo "umask 027" >> /etc/bashrc

# Disable core dumps
echo "* hard core 0" >> /etc/security/limits.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf

# Configure kernel parameters for security
cat >> /etc/sysctl.conf << 'SYSCTL_EOF'
# FinovaBank bastion host security parameters

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
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# IPv6 security (disable if not needed)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# Process restrictions
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1

# File system security
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
SYSCTL_EOF

sysctl -p

echo "Bastion host hardening completed"
EOF

chmod +x /usr/local/bin/harden-bastion.sh
/usr/local/bin/harden-bastion.sh

# Create daily security report script
log "Creating daily security report script"
cat > /usr/local/bin/daily-security-report.sh << 'EOF'
#!/bin/bash
# Daily security report for FinovaBank bastion host

REPORT_FILE="/tmp/daily-security-report.txt"
CLOUDWATCH_LOG_GROUP="$1"
REGION="$2"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
DATE=$(date '+%Y-%m-%d')

# Generate security report
cat > $REPORT_FILE << REPORT_EOF
FinovaBank Bastion Host Daily Security Report
Date: $DATE
Instance ID: $INSTANCE_ID

=== SSH ACCESS SUMMARY ===
Total SSH sessions today: $(grep "$(date '+%b %d')" /var/log/secure | grep "Accepted publickey" | wc -l)
Failed login attempts today: $(grep "$(date '+%b %d')" /var/log/secure | grep "Failed password" | wc -l)
Unique source IPs: $(grep "$(date '+%b %d')" /var/log/secure | grep "Accepted publickey" | awk '{print $11}' | sort -u | wc -l)

=== FAIL2BAN STATUS ===
$(fail2ban-client status)

=== SYSTEM STATUS ===
Uptime: $(uptime)
Disk Usage: $(df -h / | awk 'NR==2 {print $5}')
Memory Usage: $(free -h | awk 'NR==2{printf "%.1f%%", $3/$2*100}')
Load Average: $(uptime | awk -F'load average:' '{print $2}')

=== SECURITY UPDATES ===
Available security updates: $(yum check-update --security | grep -c "updates")

=== ACTIVE PROCESSES ===
$(ps aux --sort=-%cpu | head -10)

=== NETWORK CONNECTIONS ===
$(netstat -tuln | grep LISTEN)

=== RECENT AUDIT EVENTS ===
$(tail -20 /var/log/audit/audit.log)

REPORT_EOF

# Send report to CloudWatch
aws logs put-log-events \
    --log-group-name "$CLOUDWATCH_LOG_GROUP" \
    --log-stream-name "$INSTANCE_ID/daily-reports" \
    --log-events timestamp=$(date +%s000),message="$(cat $REPORT_FILE)" \
    --region "$REGION"

# Clean up
rm -f $REPORT_FILE

echo "Daily security report generated and sent to CloudWatch"
EOF

chmod +x /usr/local/bin/daily-security-report.sh

# Schedule daily security report
echo "0 6 * * * root /usr/local/bin/daily-security-report.sh '$CLOUDWATCH_LOG_GROUP' '$REGION'" >> /etc/crontab

# Configure automatic security updates
log "Configuring automatic security updates"
yum install -y yum-cron
sed -i 's/update_cmd = default/update_cmd = security/' /etc/yum/yum-cron.conf
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
sed -i 's/emit_via = stdio/emit_via = email/' /etc/yum/yum-cron.conf
sed -i 's/email_from = root@localhost/email_from = bastion@finovabank.com/' /etc/yum/yum-cron.conf
sed -i 's/email_to = root/email_to = security@finovabank.com/' /etc/yum/yum-cron.conf
systemctl enable yum-cron
systemctl start yum-cron

# Create emergency access script
log "Creating emergency access script"
cat > /usr/local/bin/emergency-access.sh << 'EOF'
#!/bin/bash
# Emergency access script for FinovaBank bastion host
# This script should only be used in emergency situations

CLOUDWATCH_LOG_GROUP="$1"
REGION="$2"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EMERGENCY_USER="$3"
REASON="$4"

if [ -z "$EMERGENCY_USER" ] || [ -z "$REASON" ]; then
    echo "Usage: $0 <cloudwatch_log_group> <region> <emergency_user> <reason>"
    exit 1
fi

# Log emergency access
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "$TIMESTAMP - EMERGENCY ACCESS GRANTED - User: $EMERGENCY_USER - Reason: $REASON" >> /var/log/emergency-access.log

# Send alert to CloudWatch
aws logs put-log-events \
    --log-group-name "$CLOUDWATCH_LOG_GROUP" \
    --log-stream-name "$INSTANCE_ID/emergency-access" \
    --log-events timestamp=$(date +%s000),message="EMERGENCY ACCESS GRANTED - User: $EMERGENCY_USER - Reason: $REASON" \
    --region "$REGION"

echo "Emergency access logged and reported"
EOF

chmod +x /usr/local/bin/emergency-access.sh

# Configure MOTD (Message of the Day)
log "Configuring MOTD"
cat > /etc/motd << 'EOF'

 ███████╗██╗███╗   ██╗ ██████╗ ██╗   ██╗ █████╗ ██████╗  █████╗ ███╗   ██╗██╗  ██╗
 ██╔════╝██║████╗  ██║██╔═══██╗██║   ██║██╔══██╗██╔══██╗██╔══██╗████╗  ██║██║ ██╔╝
 █████╗  ██║██╔██╗ ██║██║   ██║██║   ██║███████║██████╔╝███████║██╔██╗ ██║█████╔╝ 
 ██╔══╝  ██║██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║██╔══██╗██╔══██║██║╚██╗██║██╔═██╗ 
 ██║     ██║██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║██████╔╝██║  ██║██║ ╚████║██║  ██╗
 ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝

                                BASTION HOST
                           SECURE ADMINISTRATIVE ACCESS

Welcome to the FinovaBank bastion host. This system provides secure administrative
access to the FinovaBank infrastructure.

SECURITY NOTICE:
- All activities on this system are monitored and logged
- Unauthorized access is strictly prohibited
- All actions must comply with FinovaBank security policies
- Report any suspicious activity immediately

USAGE GUIDELINES:
- Use this host only for authorized administrative tasks
- Follow the principle of least privilege
- Document all administrative actions
- Log out when finished

For support: infrastructure@finovabank.com
For security incidents: security@finovabank.com

EOF

# Final system configuration
log "Applying final system configuration"

# Restart all services to apply configurations
systemctl restart sshd
systemctl restart rsyslog
systemctl restart auditd
systemctl restart crond
systemctl restart firewalld

# Set proper timezone
timedatectl set-timezone UTC

# Enable and start all monitoring services
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Signal completion
log "FinovaBank bastion host configuration completed successfully"

# Send completion notification to CloudWatch
aws logs put-log-events \
    --log-group-name "$CLOUDWATCH_LOG_GROUP" \
    --log-stream-name "$INSTANCE_ID/setup" \
    --log-events timestamp=$(date +%s000),message="FinovaBank bastion host configuration completed successfully" \
    --region "$REGION"

exit 0

