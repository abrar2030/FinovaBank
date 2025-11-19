#!/bin/bash
# =====================================================
# FinovaBank Development Environment Setup Script
# =====================================================
# This script automates the complete setup of the FinovaBank
# development environment, including dependency installation,
# environment configuration, and initial database setup.
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

# Function to display usage information
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [options]"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --help                 Display this help message"
    echo -e "  --skip-prereqs         Skip prerequisites check"
    echo -e "  --skip-backend         Skip backend setup"
    echo -e "  --skip-frontend        Skip frontend setup"
    echo -e "  --skip-mobile          Skip mobile frontend setup"
    echo -e "  --skip-ai              Skip AI services setup"
    echo -e "  --skip-db              Skip database initialization"
    echo -e "  --env-only             Only set up environment variables"
    echo -e "  --with-test-data       Initialize database with test data"
    echo -e ""
    exit 0
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display a step message
step_msg() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

# Function to display an error message
error_msg() {
    echo -e "\n${RED}ERROR:${NC} $1"
}

# Function to display a warning message
warning_msg() {
    echo -e "\n${YELLOW}WARNING:${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    step_msg "Checking prerequisites..."

    local missing_prereqs=false

    # Check for required software
    local required_commands=("git" "docker" "docker-compose" "java" "node" "npm" "python3")

    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            error_msg "$cmd is not installed"
            missing_prereqs=true
        fi
    done

    # Check Java version
    if command_exists java; then
        java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed 's/^1\.//' | cut -d'.' -f1)
        if [ "$java_version" -lt 11 ]; then
            error_msg "Java 11 or higher is required (found version $java_version)"
            missing_prereqs=true
        fi
    fi

    # Check Node.js version
    if command_exists node; then
        node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$node_version" -lt 14 ]; then
            error_msg "Node.js 14 or higher is required (found version $node_version)"
            missing_prereqs=true
        fi
    fi

    # Check Python version
    if command_exists python3; then
        python_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f2)
        if [ "$python_version" -lt 8 ]; then
            error_msg "Python 3.8 or higher is required"
            missing_prereqs=true
        fi
    fi

    # Check Docker and Docker Compose
    if command_exists docker; then
        if ! docker info >/dev/null 2>&1; then
            error_msg "Docker daemon is not running"
            missing_prereqs=true
        fi
    fi

    if [ "$missing_prereqs" = true ]; then
        error_msg "Please install the missing prerequisites and try again."
        exit 1
    fi

    echo -e "${GREEN}All prerequisites are satisfied!${NC}"
}

# Function to set up environment variables
setup_env_vars() {
    step_msg "Setting up environment variables..."

    if [ ! -f .env.example ]; then
        error_msg ".env.example file not found"
        exit 1
    fi

    if [ -f .env ]; then
        warning_msg ".env file already exists. Do you want to overwrite it? (y/n)"
        read -r overwrite
        if [ "$overwrite" != "y" ]; then
            echo "Keeping existing .env file."
            return
        fi
    fi

    cp .env.example .env
    echo -e "${GREEN}Environment variables set up successfully!${NC}"
    echo "Please edit the .env file with your configuration if needed."
}

# Function to set up backend services
setup_backend() {
    step_msg "Setting up backend services..."

    if [ ! -d "backend" ]; then
        error_msg "Backend directory not found"
        exit 1
    fi

    cd backend

    # Check if Maven wrapper exists, if not, download it
    if [ ! -f "mvnw" ]; then
        echo "Maven wrapper not found, downloading..."
        mvn -N io.takari:maven:wrapper
    fi

    # Make the Maven wrapper executable
    chmod +x mvnw

    # Install dependencies
    ./mvnw clean install -DskipTests

    cd ..

    echo -e "${GREEN}Backend services set up successfully!${NC}"
}

# Function to set up frontend
setup_frontend() {
    step_msg "Setting up web frontend..."

    if [ ! -d "web-frontend" ]; then
        error_msg "Web frontend directory not found"
        exit 1
    fi

    cd web-frontend

    # Install dependencies
    npm install

    cd ..

    echo -e "${GREEN}Web frontend set up successfully!${NC}"
}

# Function to set up mobile frontend
setup_mobile_frontend() {
    step_msg "Setting up mobile frontend..."

    if [ ! -d "mobile-frontend" ]; then
        error_msg "Mobile frontend directory not found"
        exit 1
    fi

    cd mobile-frontend

    # Install dependencies
    npm install

    cd ..

    echo -e "${GREEN}Mobile frontend set up successfully!${NC}"
}

# Function to set up AI services
setup_ai_services() {
    step_msg "Setting up AI services..."

    # Check if AI services directory exists
    if [ ! -d "ai-services" ]; then
        warning_msg "AI services directory not found, creating it..."
        mkdir -p ai-services
    fi

    cd ai-services

    # Check if requirements.txt exists
    if [ ! -f "requirements.txt" ]; then
        warning_msg "requirements.txt not found, skipping pip install"
    else
        # Create and activate virtual environment
        if [ ! -d "venv" ]; then
            python3 -m venv venv
        fi

        # Activate virtual environment and install dependencies
        source venv/bin/activate
        pip install -r requirements.txt
        deactivate
    fi

    cd ..

    echo -e "${GREEN}AI services set up successfully!${NC}"
}

# Function to initialize the database
init_database() {
    step_msg "Initializing database..."

    # Start database containers if they're not already running
    if ! docker-compose ps | grep -q "database"; then
        echo "Starting database containers..."
        docker-compose up -d database
    fi

    # Wait for database to be ready
    echo "Waiting for database to be ready..."
    sleep 10

    # Run database migrations
    cd backend
    ./mvnw flyway:migrate
    cd ..

    # Load test data if requested
    if [ "$WITH_TEST_DATA" = true ]; then
        step_msg "Loading test data..."
        cd database
        if [ -f "seed-test-data.sql" ]; then
            # Execute the seed script
            docker-compose exec -T database psql -U postgres -d finovabank -f /scripts/seed-test-data.sql
        else
            warning_msg "Test data script not found, skipping"
        fi
        cd ..
    fi

    echo -e "${GREEN}Database initialized successfully!${NC}"
}

# Function to start the application
start_application() {
    step_msg "Starting the application..."

    # Start all containers
    docker-compose up -d

    echo -e "${GREEN}Application started successfully!${NC}"
    echo -e "You can access the application at: ${BLUE}http://localhost:3000${NC}"
}

# Parse command line arguments
SKIP_PREREQS=false
SKIP_BACKEND=false
SKIP_FRONTEND=false
SKIP_MOBILE=false
SKIP_AI=false
SKIP_DB=false
ENV_ONLY=false
WITH_TEST_DATA=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        --help)
            usage
            ;;
        --skip-prereqs)
            SKIP_PREREQS=true
            ;;
        --skip-backend)
            SKIP_BACKEND=true
            ;;
        --skip-frontend)
            SKIP_FRONTEND=true
            ;;
        --skip-mobile)
            SKIP_MOBILE=true
            ;;
        --skip-ai)
            SKIP_AI=true
            ;;
        --skip-db)
            SKIP_DB=true
            ;;
        --env-only)
            ENV_ONLY=true
            ;;
        --with-test-data)
            WITH_TEST_DATA=true
            ;;
        *)
            error_msg "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

# Main execution
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}FinovaBank Development Environment Setup${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check if we're in the right directory
if [ ! -f "README.md" ] || ! grep -q "FinovaBank" "README.md"; then
    error_msg "Please run this script from the root of the FinovaBank repository"
    exit 1
fi

# Check prerequisites
if [ "$SKIP_PREREQS" = false ]; then
    check_prerequisites
fi

# Set up environment variables
setup_env_vars

# If env-only flag is set, exit after setting up environment variables
if [ "$ENV_ONLY" = true ]; then
    echo -e "\n${GREEN}Environment variables set up successfully!${NC}"
    exit 0
fi

# Set up backend services
if [ "$SKIP_BACKEND" = false ]; then
    setup_backend
fi

# Set up frontend
if [ "$SKIP_FRONTEND" = false ]; then
    setup_frontend
fi

# Set up mobile frontend
if [ "$SKIP_MOBILE" = false ]; then
    setup_mobile_frontend
fi

# Set up AI services
if [ "$SKIP_AI" = false ]; then
    setup_ai_services
fi

# Initialize database
if [ "$SKIP_DB" = false ]; then
    init_database
fi

# Start the application
start_application

echo -e "\n${GREEN}FinovaBank development environment has been set up successfully!${NC}"
echo -e "To stop the application, run: ${BLUE}docker-compose down${NC}"
echo -e "To view logs, run: ${BLUE}docker-compose logs -f${NC}"
echo -e "${BLUE}======================================================${NC}"
