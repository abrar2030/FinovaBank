-- V2__Add_Rollback_Support.sql
-- Savings Goals Service Rollback Support

-- Create a migrations history table to track applied migrations
CREATE TABLE IF NOT EXISTS schema_migrations (
    id SERIAL PRIMARY KEY,
    version VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    type VARCHAR(10) NOT NULL,
    script TEXT NOT NULL,
    installed_by VARCHAR(100) NOT NULL,
    installed_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    execution_time INTEGER NOT NULL,
    success BOOLEAN NOT NULL
);

-- Create a function to log successful migrations
CREATE OR REPLACE FUNCTION log_migration_success(
    p_version VARCHAR(100),
    p_description TEXT,
    p_type VARCHAR(10),
    p_script TEXT,
    p_execution_time INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO schema_migrations (
        version, description, type, script, installed_by, execution_time, success
    ) VALUES (
        p_version, p_description, p_type, p_script, current_user, p_execution_time, TRUE
    );
END;
$$ LANGUAGE plpgsql;

-- Create a function to log failed migrations
CREATE OR REPLACE FUNCTION log_migration_failure(
    p_version VARCHAR(100),
    p_description TEXT,
    p_type VARCHAR(10),
    p_script TEXT,
    p_execution_time INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO schema_migrations (
        version, description, type, script, installed_by, execution_time, success
    ) VALUES (
        p_version, p_description, p_type, p_script, current_user, p_execution_time, FALSE
    );
END;
$$ LANGUAGE plpgsql;
