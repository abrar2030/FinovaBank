# FinovaBank Infrastructure Outputs
# Comprehensive output definitions for infrastructure components

# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.finova_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.finova_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.database_subnets[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.finova_igw.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.finova_nat[*].id
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app_sg.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database_sg.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion_sg.id
}

# Load Balancer Outputs
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.finova_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.finova_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.finova_alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.finova_app_tg.arn
}

# Database Outputs
output "primary_database_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.finova_primary_db.endpoint
  sensitive   = true
}

output "primary_database_port" {
  description = "RDS instance port"
  value       = aws_db_instance.finova_primary_db.port
}

output "read_replica_endpoint" {
  description = "RDS read replica endpoint"
  value       = aws_db_instance.finova_read_replica.endpoint
  sensitive   = true
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.finova_db_subnet_group.name
}

output "database_parameter_group_name" {
  description = "Name of the database parameter group"
  value       = aws_db_parameter_group.finova_db_params.name
}

# Auto Scaling Outputs
output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.finova_app_asg.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.finova_app_asg.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.finova_app_lt.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.finova_app_lt.latest_version
}

# Bastion Host Outputs
output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = aws_instance.finova_bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.finova_bastion.public_ip
  sensitive   = true
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = aws_instance.finova_bastion.private_ip
}

# KMS Outputs
output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.finova_kms.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.finova_kms.arn
}

output "kms_alias_name" {
  description = "Name of the KMS alias"
  value       = aws_kms_alias.finova_kms_alias.name
}

# S3 Outputs
output "logs_bucket_name" {
  description = "Name of the logs S3 bucket"
  value       = aws_s3_bucket.finova_logs.bucket
}

output "logs_bucket_arn" {
  description = "ARN of the logs S3 bucket"
  value       = aws_s3_bucket.finova_logs.arn
}

# CloudWatch Outputs
output "app_log_group_name" {
  description = "Name of the application log group"
  value       = aws_cloudwatch_log_group.finova_app_logs.name
}

output "security_log_group_name" {
  description = "Name of the security log group"
  value       = aws_cloudwatch_log_group.finova_security_logs.name
}

output "app_log_group_arn" {
  description = "ARN of the application log group"
  value       = aws_cloudwatch_log_group.finova_app_logs.arn
}

output "security_log_group_arn" {
  description = "ARN of the security log group"
  value       = aws_cloudwatch_log_group.finova_security_logs.arn
}

# SNS Outputs
output "alerts_topic_arn" {
  description = "ARN of the alerts SNS topic"
  value       = aws_sns_topic.finova_alerts.arn
}

output "alerts_topic_name" {
  description = "Name of the alerts SNS topic"
  value       = aws_sns_topic.finova_alerts.name
}

# WAF Outputs
output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.finova_waf.id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.finova_waf.arn
}

# SSL Certificate Outputs
output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = aws_acm_certificate.finova_cert.arn
}

output "ssl_certificate_domain_name" {
  description = "Domain name of the SSL certificate"
  value       = aws_acm_certificate.finova_cert.domain_name
}

# Backup Outputs
output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = aws_backup_vault.finova_backup_vault.arn
}

output "backup_plan_id" {
  description = "ID of the backup plan"
  value       = aws_backup_plan.finova_backup_plan.id
}

output "backup_plan_arn" {
  description = "ARN of the backup plan"
  value       = aws_backup_plan.finova_backup_plan.arn
}

# IAM Outputs
output "app_instance_profile_name" {
  description = "Name of the application instance profile"
  value       = aws_iam_instance_profile.finova_app_profile.name
}

output "app_role_arn" {
  description = "ARN of the application IAM role"
  value       = aws_iam_role.finova_app_role.arn
}

output "backup_role_arn" {
  description = "ARN of the backup IAM role"
  value       = aws_iam_role.finova_backup_role.arn
}

output "rds_monitoring_role_arn" {
  description = "ARN of the RDS monitoring IAM role"
  value       = aws_iam_role.rds_monitoring_role.arn
}

# CloudWatch Alarms Outputs
output "high_cpu_alarm_name" {
  description = "Name of the high CPU alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "database_cpu_alarm_name" {
  description = "Name of the database CPU alarm"
  value       = aws_cloudwatch_metric_alarm.database_cpu.alarm_name
}

# Connection Information
output "application_url" {
  description = "URL to access the application"
  value       = "https://${aws_lb.finova_alb.dns_name}"
}

output "database_connection_string" {
  description = "Database connection string (without password)"
  value       = "mysql://${aws_db_instance.finova_primary_db.username}@${aws_db_instance.finova_primary_db.endpoint}:${aws_db_instance.finova_primary_db.port}/${aws_db_instance.finova_primary_db.db_name}"
  sensitive   = true
}

# Monitoring and Logging URLs
output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:"
}

output "waf_dashboard_url" {
  description = "URL to WAF dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/wafv2/homev2/web-acl/${aws_wafv2_web_acl.finova_waf.id}/overview?region=${var.aws_region}"
}

# Security Information
output "security_groups_summary" {
  description = "Summary of security groups created"
  value = {
    alb_sg      = aws_security_group.alb_sg.id
    app_sg      = aws_security_group.app_sg.id
    database_sg = aws_security_group.database_sg.id
    bastion_sg  = aws_security_group.bastion_sg.id
  }
}

output "encryption_summary" {
  description = "Summary of encryption configurations"
  value = {
    kms_key_id           = aws_kms_key.finova_kms.key_id
    database_encrypted   = aws_db_instance.finova_primary_db.storage_encrypted
    s3_bucket_encrypted  = "AES256-KMS"
    ebs_volumes_encrypted = "true"
  }
}

# Compliance Information
output "compliance_summary" {
  description = "Summary of compliance configurations"
  value = {
    backup_retention_days    = aws_db_instance.finova_primary_db.backup_retention_period
    log_retention_days      = aws_cloudwatch_log_group.finova_app_logs.retention_in_days
    deletion_protection     = aws_db_instance.finova_primary_db.deletion_protection
    encryption_at_rest      = "enabled"
    encryption_in_transit   = "enabled"
    waf_protection         = "enabled"
    monitoring_enabled     = "enhanced"
  }
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (USD)"
  value = {
    note = "Costs are estimates and may vary based on usage patterns"
    ec2_instances = "~$50-150/month (depending on usage)"
    rds_database  = "~$100-300/month (depending on instance size)"
    load_balancer = "~$20-30/month"
    data_transfer = "~$10-50/month (depending on traffic)"
    storage       = "~$10-30/month"
    monitoring    = "~$5-15/month"
    total_estimate = "~$195-575/month"
  }
}

# Disaster Recovery Information
output "disaster_recovery_summary" {
  description = "Summary of disaster recovery configurations"
  value = {
    multi_az_database     = "enabled"
    automated_backups     = "enabled"
    backup_retention      = "${aws_db_instance.finova_primary_db.backup_retention_period} days"
    read_replica         = "enabled"
    cross_region_backup  = "configurable"
    point_in_time_recovery = "enabled"
  }
}

# Network Security Summary
output "network_security_summary" {
  description = "Summary of network security configurations"
  value = {
    vpc_isolation        = "enabled"
    private_subnets      = "enabled"
    nat_gateways        = "enabled"
    security_groups     = "restrictive"
    network_acls        = "default"
    vpc_flow_logs       = "configurable"
    waf_protection      = "enabled"
  }
}

# Operational Information
output "operational_summary" {
  description = "Summary of operational configurations"
  value = {
    auto_scaling         = "enabled"
    health_checks       = "enabled"
    monitoring          = "enhanced"
    alerting            = "configured"
    log_aggregation     = "centralized"
    backup_automation   = "enabled"
    patch_management    = "manual"
    incident_response   = "sns_notifications"
  }
}

