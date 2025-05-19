-- V1__Initial_Schema.sql
-- Risk Assessment Service Initial Schema

CREATE TABLE IF NOT EXISTS risk_profiles (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(36) NOT NULL UNIQUE,
    risk_score INTEGER NOT NULL,
    credit_score INTEGER,
    fraud_likelihood VARCHAR(10) NOT NULL DEFAULT 'LOW',
    last_assessment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_risk_profiles_customer_id ON risk_profiles(customer_id);
CREATE INDEX idx_risk_profiles_risk_score ON risk_profiles(risk_score);

-- Risk assessment history
CREATE TABLE IF NOT EXISTS risk_assessments (
    id SERIAL PRIMARY KEY,
    profile_id INTEGER NOT NULL REFERENCES risk_profiles(id),
    previous_score INTEGER,
    new_score INTEGER NOT NULL,
    assessment_reason TEXT NOT NULL,
    assessed_by VARCHAR(50) NOT NULL,
    assessed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_risk_assessments_profile_id ON risk_assessments(profile_id);
