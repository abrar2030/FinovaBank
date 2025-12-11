-- V1__Initial_Schema.sql
-- Transaction Service Initial Schema

CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(36) NOT NULL UNIQUE,
    source_account_id VARCHAR(20) NOT NULL,
    destination_account_id VARCHAR(20) NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'PENDING',
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transactions_source_account ON transactions(source_account_id);
CREATE INDEX idx_transactions_destination_account ON transactions(destination_account_id);
CREATE INDEX idx_transactions_status ON transactions(status);

-- Transaction audit trail
CREATE TABLE IF NOT EXISTS transaction_audit (
    id SERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL REFERENCES transactions(id),
    action VARCHAR(10) NOT NULL,
    old_status VARCHAR(10),
    new_status VARCHAR(10),
    changed_by VARCHAR(50) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transaction_audit_transaction_id ON transaction_audit(transaction_id);
