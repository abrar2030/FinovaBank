-- V1__Initial_Schema.sql
-- Loan Management Service Initial Schema

CREATE TABLE IF NOT EXISTS loans (
    id SERIAL PRIMARY KEY,
    loan_number VARCHAR(20) NOT NULL UNIQUE,
    customer_id VARCHAR(36) NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    term_months INTEGER NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'PENDING',
    purpose VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_loans_customer_id ON loans(customer_id);
CREATE INDEX idx_loans_status ON loans(status);

-- Loan payments tracking
CREATE TABLE IF NOT EXISTS loan_payments (
    id SERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL REFERENCES loans(id),
    payment_amount DECIMAL(19, 4) NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(20) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'COMPLETED',
    transaction_reference VARCHAR(36)
);

CREATE INDEX idx_loan_payments_loan_id ON loan_payments(loan_id);
