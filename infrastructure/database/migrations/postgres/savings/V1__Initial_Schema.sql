-- V1__Initial_Schema.sql
-- Savings Goals Service Initial Schema

CREATE TABLE IF NOT EXISTS savings_goals (
    id SERIAL PRIMARY KEY,
    goal_id VARCHAR(36) NOT NULL UNIQUE,
    customer_id VARCHAR(36) NOT NULL,
    account_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    target_amount DECIMAL(19, 4) NOT NULL,
    current_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    start_date DATE NOT NULL,
    target_date DATE NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_savings_goals_customer_id ON savings_goals(customer_id);
CREATE INDEX idx_savings_goals_account_id ON savings_goals(account_id);

-- Savings contributions tracking
CREATE TABLE IF NOT EXISTS savings_contributions (
    id SERIAL PRIMARY KEY,
    goal_id INTEGER NOT NULL REFERENCES savings_goals(id),
    amount DECIMAL(19, 4) NOT NULL,
    contribution_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_account_id VARCHAR(20) NOT NULL,
    transaction_reference VARCHAR(36)
);

CREATE INDEX idx_savings_contributions_goal_id ON savings_contributions(goal_id);
