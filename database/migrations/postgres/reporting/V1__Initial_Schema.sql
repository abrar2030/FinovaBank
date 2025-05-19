-- V1__Initial_Schema.sql
-- Reporting Service Initial Schema

CREATE TABLE IF NOT EXISTS reports (
    id SERIAL PRIMARY KEY,
    report_id VARCHAR(36) NOT NULL UNIQUE,
    customer_id VARCHAR(36) NOT NULL,
    report_type VARCHAR(30) NOT NULL,
    parameters JSONB,
    status VARCHAR(15) NOT NULL DEFAULT 'PENDING',
    result_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reports_customer_id ON reports(customer_id);
CREATE INDEX idx_reports_status ON reports(status);

-- Report schedules
CREATE TABLE IF NOT EXISTS report_schedules (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(36) NOT NULL,
    report_type VARCHAR(30) NOT NULL,
    frequency VARCHAR(20) NOT NULL,
    parameters JSONB,
    next_run TIMESTAMP NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_report_schedules_customer_id ON report_schedules(customer_id);
CREATE INDEX idx_report_schedules_next_run ON report_schedules(next_run);
