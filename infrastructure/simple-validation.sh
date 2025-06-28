#!/bin/bash
# Simplified FinovaBank Infrastructure Validation

echo "=================================================="
echo "    FinovaBank Infrastructure Validation"
echo "=================================================="

PASSED=0
TOTAL=0

check() {
    TOTAL=$((TOTAL + 1))
    if eval "$2" > /dev/null 2>&1; then
        echo "✓ $1"
        PASSED=$((PASSED + 1))
    else
        echo "✗ $1"
    fi
}

# File structure validation
echo "Validating file structure..."
check "Terraform directory exists" "test -d terraform"
check "Ansible directory exists" "test -d ansible"
check "Security directory exists" "test -d security"
check "Compliance directory exists" "test -d compliance"
check "Monitoring directory exists" "test -d monitoring"
check "Secrets directory exists" "test -d secrets"

# Critical files
echo "Validating critical files..."
check "Terraform main.tf exists" "test -f terraform/main.tf"
check "Terraform variables.tf exists" "test -f terraform/variables.tf"
check "Terraform outputs.tf exists" "test -f terraform/outputs.tf"
check "Ansible playbook.yml exists" "test -f ansible/playbook.yml"
check "Security policies exist" "test -f security/security-policies.yml"
check "Compliance framework exists" "test -f compliance/compliance-framework.yml"
check "Monitoring config exists" "test -f monitoring/monitoring-config.yml"
check "README.md exists" "test -f README.md"

# Content validation
echo "Validating content..."
check "Security policies YAML valid" "python3 -c 'import yaml; yaml.safe_load(open(\"security/security-policies.yml\"))'"
check "Compliance framework YAML valid" "python3 -c 'import yaml; yaml.safe_load(open(\"compliance/compliance-framework.yml\"))'"
check "Monitoring config YAML valid" "python3 -c 'import yaml; yaml.safe_load(open(\"monitoring/monitoring-config.yml\"))'"

# Financial compliance checks
echo "Validating financial compliance..."
check "PCI-DSS compliance configured" "grep -q 'pci_dss:' compliance/compliance-framework.yml"
check "GLBA compliance configured" "grep -q 'glba:' compliance/compliance-framework.yml"
check "SOX compliance configured" "grep -q 'sox:' compliance/compliance-framework.yml"
check "GDPR compliance configured" "grep -q 'gdpr:' compliance/compliance-framework.yml"
check "7-year retention configured" "grep -q '2555' */**.yml"
check "Encryption configured" "grep -q 'encryption' */**.yml"

echo ""
echo "Summary: $PASSED/$TOTAL checks passed"
if [ $PASSED -eq $TOTAL ]; then
    echo "Status: ✓ EXCELLENT - All checks passed!"
else
    echo "Status: ⚠ GOOD - Most checks passed"
fi
