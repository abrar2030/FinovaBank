-- V1__Initial_Schema.sql
-- Notification Service Initial Schema

CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    notification_id VARCHAR(36) NOT NULL UNIQUE,
    customer_id VARCHAR(36) NOT NULL,
    type VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'PENDING',
    sent_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_customer_id ON notifications(customer_id);
CREATE INDEX idx_notifications_status ON notifications(status);

-- Notification preferences
CREATE TABLE IF NOT EXISTS notification_preferences (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(36) NOT NULL UNIQUE,
    email_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    sms_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    push_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    email_address VARCHAR(100),
    phone_number VARCHAR(20),
    device_token TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_preferences_customer_id ON notification_preferences(customer_id);
