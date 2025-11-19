#!/bin/bash
# FinovaBank Infrastructure Validation Script
# Comprehensive validation for financial-grade infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Function to run a check
run_check() {
    local check_name="$1"
    local check_command="$2"
    local is_critical="${3:-true}"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    log "Running check: $check_name"

    if eval "$check_command" > /dev/null 2>&1; then
        success "$check_name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [ "$is_critical" = "true" ]; then
            error "$check_name"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        else
            warning "$check_name"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        fi
        return 1
    fi
}

# Header
echo "=================================================="
echo "    FinovaBank Infrastructure Validation"
echo "=================================================="
echo ""

# 1. Prerequisites Check
log "Checking prerequisites..."

run_check "Terraform installed" "command -v terraform"
run_check "Ansible installed" "command -v ansible"
run_check "AWS CLI installed" "command -v aws"
run_check "Docker installed" "command -v docker" false
run_check "kubectl installed" "command -v kubectl" false

# Check tool versions
if command -v terraform > /dev/null; then
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | cut -d' ' -f2)
    log "Terraform version: $TERRAFORM_VERSION"
fi

if command -v ansible > /dev/null; then
    ANSIBLE_VERSION=$(ansible --version | head -n1 | cut -d' ' -f2)
    log "Ansible version: $ANSIBLE_VERSION"
fi

# 2. AWS Configuration Check
log "Checking AWS configuration..."

run_check "AWS credentials configured" "aws sts get-caller-identity"
run_check "AWS region set" "test -n \"\$AWS_DEFAULT_REGION\" || aws configure get region"

if aws sts get-caller-identity > /dev/null 2>&1; then
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_USER=$(aws sts get-caller-identity --query Arn --output text)
    log "AWS Account: $AWS_ACCOUNT"
    log "AWS User/Role: $AWS_USER"
fi

# 3. File Structure Validation
log "Validating file structure..."

run_check "Terraform directory exists" "test -d terraform"
run_check "Ansible directory exists" "test -d ansible"
run_check "Security directory exists" "test -d security"
run_check "Compliance directory exists" "test -d compliance"
run_check "Monitoring directory exists" "test -d monitoring"
run_check "Secrets directory exists" "test -d secrets"

# Check critical files
run_check "Terraform main.tf exists" "test -f terraform/main.tf"
run_check "Terraform variables.tf exists" "test -f terraform/variables.tf"
run_check "Terraform outputs.tf exists" "test -f terraform/outputs.tf"
run_check "Ansible playbook.yml exists" "test -f ansible/playbook.yml"
run_check "Ansible inventory.yml exists" "test -f ansible/inventory.yml"
run_check "Security policies exist" "test -f security/security-policies.yml"
run_check "Compliance framework exists" "test -f compliance/compliance-framework.yml"
run_check "Monitoring config exists" "test -f monitoring/monitoring-config.yml"

# 4. Terraform Validation
log "Validating Terraform configuration..."

if [ -d "terraform" ]; then
    cd terraform

    run_check "Terraform init successful" "terraform init -backend=false"
    run_check "Terraform validate successful" "terraform validate"
    run_check "Terraform format check" "terraform fmt -check=true -diff=true"

    # Check for security best practices
    run_check "No hardcoded secrets in Terraform" "! grep -r 'password.*=' . --include='*.tf' | grep -v variable"
    run_check "Encryption enabled for storage" "grep -q 'encrypted.*=.*true' *.tf"
    run_check "Backup retention configured" "grep -q 'backup_retention_period' *.tf"

    cd ..
fi

# 5. Ansible Validation
log "Validating Ansible configuration..."

if [ -d "ansible" ]; then
    cd ansible

    run_check "Ansible syntax check" "ansible-playbook --syntax-check playbook.yml"
    run_check "Ansible inventory valid" "ansible-inventory --list > /dev/null"

    # Check for security best practices
    run_check "No plaintext passwords in Ansible" "! grep -r 'password:' . --include='*.yml' | grep -v vault"
    run_check "Sudo configuration present" "grep -q 'become.*true' playbook.yml"
    run_check "Security hardening tasks present" "grep -q 'security' playbook.yml"

    cd ..
fi

# 6. Security Configuration Validation
log "Validating security configuration..."

if [ -f "security/security-policies.yml" ]; then
    run_check "Security policies YAML valid" "python3 -c 'import yaml; yaml.safe_load(open(\"security/security-policies.yml\"))'"
    run_check "Multi-factor auth configured" "grep -q 'multi_factor_required.*true' security/security-policies.yml"
    run_check "Encryption policies defined" "grep -q 'encryption:' security/security-policies.yml"
    run_check "Access control policies defined" "grep -q 'access_control:' security/security-policies.yml"
    run_check "Incident response procedures defined" "grep -q 'incident_response:' security/security-policies.yml"
fi

# 7. Compliance Configuration Validation
log "Validating compliance configuration..."

if [ -f "compliance/compliance-framework.yml" ]; then
    run_check "Compliance framework YAML valid" "python3 -c 'import yaml; yaml.safe_load(open(\"compliance/compliance-framework.yml\"))'"
    run_check "PCI-DSS compliance configured" "grep -q 'pci_dss:' compliance/compliance-framework.yml"
    run_check "GLBA compliance configured" "grep -q 'glba:' compliance/compliance-framework.yml"
    run_check "SOX compliance configured" "grep -q 'sox:' compliance/compliance-framework.yml"
    run_check "GDPR compliance configured" "grep -q 'gdpr:' compliance/compliance-framework.yml"
    run_check "Audit logging configured" "grep -q 'audit_logging:' compliance/compliance-framework.yml"
fi

# 8. Monitoring Configuration Validation
log "Validating monitoring configuration..."

if [ -f "monitoring/monitoring-config.yml" ]; then
    run_check "Monitoring config YAML valid" "python3 -c 'import yaml; yaml.safe_load(open(\"monitoring/monitoring-config.yml\"))'"
    run_check "Infrastructure monitoring configured" "grep -q 'infrastructure_monitoring:' monitoring/monitoring-config.yml"
    run_check "Security monitoring configured" "grep -q 'security_monitoring:' monitoring/monitoring-config.yml"
    run_check "Compliance monitoring configured" "grep -q 'compliance_monitoring:' monitoring/monitoring-config.yml"
    run_check "Alerting configured" "grep -q 'alerting:' monitoring/monitoring-config.yml"
    run_check "Long-term retention configured" "grep -q '2555' monitoring/monitoring-config.yml"
fi

# 9. Secrets Management Validation
log "Validating secrets management..."

if [ -f "secrets/secrets.yml" ]; then
    run_check "Secrets config YAML valid" "python3 -c 'import yaml; yaml.safe_load(open(\"secrets/secrets.yml\"))'"
    run_check "Vault configuration present" "grep -q 'vault_config:' secrets/secrets.yml"
    run_check "Secret rotation configured" "grep -q 'secret_rotation:' secrets/secrets.yml"
    run_check "Audit logging for secrets configured" "grep -q 'secret_audit:' secrets/secrets.yml"
    run_check "Emergency access procedures defined" "grep -q 'emergency_access:' secrets/secrets.yml"
fi

# 10. Documentation Validation
log "Validating documentation..."

run_check "README.md exists" "test -f README.md"
run_check "README.md not empty" "test -s README.md"

if [ -f "README.md" ]; then
    run_check "README contains prerequisites" "grep -q -i 'prerequisite' README.md"
    run_check "README contains quick start" "grep -q -i 'quick start' README.md"
    run_check "README contains security section" "grep -q -i 'security' README.md"
    run_check "README contains compliance section" "grep -q -i 'compliance' README.md"
fi

# 11. Financial Services Specific Checks
log "Validating financial services requirements..."

run_check "7-year data retention configured" "grep -q '2555' */**.yml"
run_check "Financial compliance standards referenced" "grep -q 'PCI-DSS\|GLBA\|SOX\|GDPR' */**.yml"
run_check "Encryption at rest configured" "grep -q 'encryption.*rest' */**.yml"
run_check "Encryption in transit configured" "grep -q 'encryption.*transit' */**.yml"
run_check "Multi-region backup configured" "grep -q 'multi.*region' */**.yml"
run_check "Disaster recovery procedures defined" "grep -q 'disaster.*recovery' */**.yml"

# 12. Security Best Practices Check
log "Validating security best practices..."

run_check "No hardcoded credentials found" "! find . -name '*.tf' -o -name '*.yml' -o -name '*.yaml' | xargs grep -l 'password.*=' | grep -v vault"
run_check "Principle of least privilege implemented" "grep -q 'least_privilege' */**.yml"
run_check "Network segmentation configured" "grep -q 'segmentation\|subnet' terraform/*.tf"
run_check "Firewall rules configured" "grep -q 'security_group\|firewall' terraform/*.tf"
run_check "Monitoring and alerting configured" "grep -q 'alert\|monitor' */**.yml"

# 13. Performance and Scalability Checks
log "Validating performance and scalability..."

run_check "Auto-scaling configured" "grep -q 'auto.*scal' terraform/*.tf"
run_check "Load balancing configured" "grep -q 'load.*balanc' terraform/*.tf"
run_check "Database replication configured" "grep -q 'replica\|replication' terraform/*.tf"
run_check "Caching configured" "grep -q 'redis\|cache' */**.yml"
run_check "Performance monitoring configured" "grep -q 'performance' monitoring/*.yml"

# Summary
echo ""
echo "=================================================="
echo "           Validation Summary"
echo "=================================================="
echo "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
echo -e "Warnings: ${YELLOW}$WARNING_CHECKS${NC}"
echo ""

# Calculate success rate
SUCCESS_RATE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
echo "Success Rate: $SUCCESS_RATE%"

# Determine overall status
if [ $FAILED_CHECKS -eq 0 ]; then
    if [ $WARNING_CHECKS -eq 0 ]; then
        echo -e "Overall Status: ${GREEN}EXCELLENT${NC} - All checks passed!"
    else
        echo -e "Overall Status: ${YELLOW}GOOD${NC} - All critical checks passed with some warnings"
    fi
    exit 0
elif [ $SUCCESS_RATE -ge 80 ]; then
    echo -e "Overall Status: ${YELLOW}ACCEPTABLE${NC} - Most checks passed but some issues need attention"
    exit 1
else
    echo -e "Overall Status: ${RED}NEEDS IMPROVEMENT${NC} - Multiple critical issues found"
    exit 2
fi
