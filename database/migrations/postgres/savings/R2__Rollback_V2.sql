-- R2__Rollback_V2.sql
-- Savings Goals Service Rollback for V2

-- Drop the functions first
DROP FUNCTION IF EXISTS log_migration_success;
DROP FUNCTION IF EXISTS log_migration_failure;

-- Then drop the migrations table
DROP TABLE IF EXISTS schema_migrations;
