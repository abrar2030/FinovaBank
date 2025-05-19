-- V1__Initial_Schema.sql
-- Compliance Service Initial Schema

CREATE TABLE IF NOT EXISTS compliance_rules (
    id SERIAL PRIMARY KEY,
    rule_code VARCHAR(20) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    severity VARCHAR(10) NOT NULL DEFAULT 'MEDIUM',
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_compliance_rules_status ON compliance_rules(status);

-- Compliance checks history
CREATE TABLE IF NOT EXISTS compliance_checks (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(36) NOT NULL,
    rule_id INTEGER NOT NULL REFERENCES compliance_rules(id),
    transaction_id VARCHAR(36),
    result VARCHAR(10) NOT NULL,
    details TEXT,
    checked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_compliance_checks_customer_id ON compliance_checks(customer_id);
CREATE INDEX idx_compliance_checks_rule_id ON compliance_checks(rule_id);
CREATE INDEX idx_compliance_checks_transaction_id ON compliance_checks(transaction_id);
