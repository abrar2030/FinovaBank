#!/bin/bash
# =====================================================
# FinovaBank Database Management Script
# =====================================================
# This script automates database operations including
# initialization, migration, backup, restore, and
# seeding test data.
# 
# Author: Manus AI
# Date: May 22, 2025
# =====================================================

set -e

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="finovabank"
DB_USER="postgres"
DB_PASSWORD="postgres"
BACKUP_DIR="./database/backups"
MIGRATIONS_DIR="./database/migrations"
SEED_DIR="./database/seed"

# Function to display usage information
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [command] [options]"
    echo -e ""
    echo -e "${BLUE}Commands:${NC}"
    echo -e "  init                Initialize database and run all migrations"
    echo -e "  migrate             Run pending migrations"
    echo -e "  backup              Create a database backup"
    echo -e "  restore FILE        Restore database from a backup file"
    echo -e "  seed                Seed database with test data"
    echo -e "  reset               Reset database (drop and recreate)"
    echo -e "  status              Show migration status"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --help              Display this help message"
    echo -e "  --host HOST         Database host (default: $DB_HOST)"
    echo -e "  --port PORT         Database port (default: $DB_PORT)"
    echo -e "  --name NAME         Database name (default: $DB_NAME)"
    echo -e "  --user USER         Database user (default: $DB_USER)"
    echo -e "  --password PASS     Database password (default: $DB_PASSWORD)"
    echo -e "  --backup-dir DIR    Backup directory (default: $BACKUP_DIR)"
    echo -e ""
    exit 0
}

# Function to display a step message
step_msg() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

# Function to display an error message
error_msg() {
    echo -e "\n${RED}ERROR:${NC} $1"
    exit 1
}

# Function to display a warning message
warning_msg() {
    echo -e "\n${YELLOW}WARNING:${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        error_msg "Docker daemon is not running"
    fi
}

# Function to check if database container is running
check_db_container() {
    if ! docker-compose ps | grep -q "database.*Up"; then
        warning_msg "Database container is not running. Starting it now..."
        docker-compose up -d database
        echo "Waiting for database to be ready..."
        sleep 10
    fi
}

# Function to initialize the database
init_database() {
    step_msg "Initializing database..."
    
    check_db_container
    
    # Create database if it doesn't exist
    if ! docker-compose exec -T database psql -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        echo "Creating database $DB_NAME..."
        docker-compose exec -T database psql -U "$DB_USER" -c "CREATE DATABASE $DB_NAME;"
    else
        echo "Database $DB_NAME already exists."
    fi
    
    # Run all migrations
    run_migrations
    
    echo -e "${GREEN}Database initialized successfully!${NC}"
}

# Function to run migrations
run_migrations() {
    step_msg "Running database migrations..."
    
    check_db_container
    
    # Check if we're using Flyway or custom migrations
    if [ -d "backend" ] && [ -f "backend/pom.xml" ] && grep -q "flyway" "backend/pom.xml"; then
        echo "Using Flyway for migrations..."
        cd backend
        ./mvnw flyway:migrate -Dflyway.url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME -Dflyway.user=$DB_USER -Dflyway.password=$DB_PASSWORD
        cd ..
    elif [ -d "$MIGRATIONS_DIR" ]; then
        echo "Using custom migrations from $MIGRATIONS_DIR..."
        
        # Get list of migration files sorted by name
        migration_files=$(find "$MIGRATIONS_DIR" -name "*.sql" | sort)
        
        # Apply each migration
        for migration in $migration_files; do
            echo "Applying migration: $(basename "$migration")..."
            docker-compose exec -T database psql -U "$DB_USER" -d "$DB_NAME" -f "/scripts/migrations/$(basename "$migration")"
        done
    else
        warning_msg "No migrations found. Skipping migration step."
    fi
    
    echo -e "${GREEN}Migrations completed successfully!${NC}"
}

# Function to backup the database
backup_database() {
    step_msg "Creating database backup..."
    
    check_db_container
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Generate backup filename with timestamp
    backup_file="$BACKUP_DIR/${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"
    
    # Create backup
    echo "Backing up database to $backup_file..."
    docker-compose exec -T database pg_dump -U "$DB_USER" "$DB_NAME" > "$backup_file"
    
    # Compress backup
    gzip "$backup_file"
    
    echo -e "${GREEN}Database backup created successfully: ${backup_file}.gz${NC}"
}

# Function to restore the database from a backup
restore_database() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        error_msg "Backup file not specified"
    fi
    
    if [ ! -f "$backup_file" ]; then
        error_msg "Backup file not found: $backup_file"
    fi
    
    step_msg "Restoring database from backup: $backup_file..."
    
    check_db_container
    
    # Check if we need to decompress the backup
    if [[ "$backup_file" == *.gz ]]; then
        echo "Decompressing backup file..."
        gunzip -c "$backup_file" | docker-compose exec -T database psql -U "$DB_USER" "$DB_NAME"
    else
        cat "$backup_file" | docker-compose exec -T database psql -U "$DB_USER" "$DB_NAME"
    fi
    
    echo -e "${GREEN}Database restored successfully!${NC}"
}

# Function to seed the database with test data
seed_database() {
    step_msg "Seeding database with test data..."
    
    check_db_container
    
    if [ ! -d "$SEED_DIR" ]; then
        error_msg "Seed directory not found: $SEED_DIR"
    fi
    
    # Get list of seed files sorted by name
    seed_files=$(find "$SEED_DIR" -name "*.sql" | sort)
    
    if [ -z "$seed_files" ]; then
        error_msg "No seed files found in $SEED_DIR"
    fi
    
    # Apply each seed file
    for seed in $seed_files; do
        echo "Applying seed file: $(basename "$seed")..."
        docker-compose exec -T database psql -U "$DB_USER" -d "$DB_NAME" -f "/scripts/seed/$(basename "$seed")"
    done
    
    echo -e "${GREEN}Database seeded successfully!${NC}"
}

# Function to reset the database
reset_database() {
    step_msg "Resetting database..."
    
    check_db_container
    
    echo -e "${YELLOW}WARNING: This will delete all data in the database. Are you sure? (y/n)${NC}"
    read -r confirm
    
    if [ "$confirm" != "y" ]; then
        echo "Database reset cancelled."
        return
    fi
    
    # Drop and recreate database
    echo "Dropping database $DB_NAME..."
    docker-compose exec -T database psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS $DB_NAME;"
    
    echo "Creating database $DB_NAME..."
    docker-compose exec -T database psql -U "$DB_USER" -c "CREATE DATABASE $DB_NAME;"
    
    # Run migrations
    run_migrations
    
    echo -e "${GREEN}Database reset successfully!${NC}"
}

# Function to show migration status
show_status() {
    step_msg "Showing migration status..."
    
    check_db_container
    
    # Check if we're using Flyway
    if [ -d "backend" ] && [ -f "backend/pom.xml" ] && grep -q "flyway" "backend/pom.xml"; then
        echo "Using Flyway for migrations..."
        cd backend
        ./mvnw flyway:info -Dflyway.url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME -Dflyway.user=$DB_USER -Dflyway.password=$DB_PASSWORD
        cd ..
    else
        # For custom migrations, we need to check if a migrations table exists
        echo "Checking migration status..."
        docker-compose exec -T database psql -U "$DB_USER" -d "$DB_NAME" -c "
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'schema_version'
            );"
        
        if [ $? -eq 0 ]; then
            docker-compose exec -T database psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT * FROM schema_version ORDER BY installed_rank;"
        else
            warning_msg "No migration tracking table found. Cannot determine migration status."
        fi
    fi
}

# Parse command line arguments
COMMAND=""
RESTORE_FILE=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        init|migrate|backup|restore|seed|reset|status)
            COMMAND="$1"
            ;;
        --help)
            usage
            ;;
        --host)
            DB_HOST="$2"
            shift
            ;;
        --port)
            DB_PORT="$2"
            shift
            ;;
        --name)
            DB_NAME="$2"
            shift
            ;;
        --user)
            DB_USER="$2"
            shift
            ;;
        --password)
            DB_PASSWORD="$2"
            shift
            ;;
        --backup-dir)
            BACKUP_DIR="$2"
            shift
            ;;
        *)
            if [ "$COMMAND" = "restore" ] && [ -z "$RESTORE_FILE" ]; then
                RESTORE_FILE="$1"
            else
                error_msg "Unknown option: $1"
            fi
            ;;
    esac
    shift
done

# Check if command is provided
if [ -z "$COMMAND" ]; then
    error_msg "No command specified"
    usage
fi

# Check if Docker is running
check_docker

# Execute the requested command
case "$COMMAND" in
    init)
        init_database
        ;;
    migrate)
        run_migrations
        ;;
    backup)
        backup_database
        ;;
    restore)
        restore_database "$RESTORE_FILE"
        ;;
    seed)
        seed_database
        ;;
    reset)
        reset_database
        ;;
    status)
        show_status
        ;;
    *)
        error_msg "Unknown command: $COMMAND"
        ;;
esac

exit 0
