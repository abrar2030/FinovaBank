#!/bin/bash

# =====================================================
#   Combined Backend and Frontend Deployment Script
# =====================================================

# Exit immediately if a command exits with a non-zero status
set -e

# --------------------
# Color Definitions
# --------------------
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --------------------
# Helper Functions
# --------------------

# Print informational messages
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Print success messages
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Print error messages
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Execute a command and handle errors
execute() {
    eval "$1" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        error "$2"
        exit 1
    fi
}

# =========================
# Configuration
# =========================

# Array of services to build and manage
SERVICES=(
    "eureka-server"
    "api-gateway"
    "account-management"
    "compliance"
    "loan-management"
    "notification-service"
    "reporting"
    "risk-assessment"
    "savings-goals"
    "transaction-service"
)

# Base directory where all services are located
BASE_DIR="$(pwd)/backend"

# Directory to store log files
LOG_DIR="$BASE_DIR/logs"

# Directory to store PID files
PID_DIR="$BASE_DIR/pids"

# Create log and PID directories if they don't exist
mkdir -p "$LOG_DIR"
mkdir -p "$PID_DIR"

# Declare associative array for service ports (update these ports as per your configuration)
declare -A SERVICE_PORTS
SERVICE_PORTS=(
    ["eureka-server"]=8001
    ["api-gateway"]=8002
    ["account-management"]=8003
    ["compliance"]=8004
    ["loan-management"]=8005
    ["notification-service"]=8006
    ["reporting"]=8007
    ["risk-assessment"]=8008
    ["savings-goals"]=8009
    ["transaction-service"]=8010
)

# =========================
# Functions
# =========================

# Function to check if a service is valid
is_valid_service() {
    local SERVICE=$1
    for S in "${SERVICES[@]}"; do
        if [[ "$S" == "$SERVICE" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to build a single service
build_service() {
    local SERVICE=$1
    info "Building $SERVICE..."

    # Navigate to the service directory
    cd "$BASE_DIR/$SERVICE" || {
        error "Directory $BASE_DIR/$SERVICE not found. Exiting."
        exit 1
    }

    # Execute Maven build
    execute "mvn clean install" "Build failed for $SERVICE."

    success "$SERVICE built successfully."

    # Navigate back to the base directory
    cd "$BASE_DIR" || {
        error "Failed to navigate back to $BASE_DIR. Exiting."
        exit 1
    }
}

# Function to build all services
build_all_services() {
    for SERVICE in "${SERVICES[@]}"; do
        build_service "$SERVICE"
    done
    info "========================================"
    success "All services built successfully."
    info "========================================"
}

# Function to check if a service is up by port
check_service_health() {
    local SERVICE_NAME=$1
    local PORT=$2
    local MAX_RETRIES=30          # Number of retries
    local RETRY_INTERVAL=5        # Seconds between retries

    info "Checking health for $SERVICE_NAME on port $PORT..."

    for ((i=1;i<=MAX_RETRIES;i++)); do
        if nc -z 127.0.0.1 "$PORT"; then
            success "$SERVICE_NAME is up (Port $PORT)."
            return 0
        else
            info "Waiting for $SERVICE_NAME to start... ($i/$MAX_RETRIES)"
            sleep "$RETRY_INTERVAL"
        fi
    done

    error "Failed to start $SERVICE_NAME after $MAX_RETRIES attempts."
    return 1
}

# Function to start a service
start_service() {
    local SERVICE=$1
    local PORT=${SERVICE_PORTS[$SERVICE]}
    local LOG_FILE="$LOG_DIR/$SERVICE.log"
    local PID_FILE="$PID_DIR/$SERVICE.pid"

    # Check if the service is already running
    if [ -f "$PID_FILE" ]; then
        local EXISTING_PID
        EXISTING_PID=$(cat "$PID_FILE")
        if ps -p "$EXISTING_PID" > /dev/null 2>&1; then
            info "[$SERVICE] is already running with PID $EXISTING_PID."
            return
        else
            info "Found stale PID file for [$SERVICE]. Removing."
            rm -f "$PID_FILE"
        fi
    fi

    info "Starting $SERVICE on port $PORT..."

    cd "$BASE_DIR/$SERVICE" || { error "Directory $BASE_DIR/$SERVICE not found. Exiting."; exit 1; }

    # Start the service in the background using nohup with proper environment variables
    # Redirect output to a dedicated log file
    nohup mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=$PORT" > "$LOG_FILE" 2>&1 &
    SERVICE_PID=$!
    echo "$SERVICE_PID" > "$PID_FILE"
    info "[$SERVICE] started with PID $SERVICE_PID. Checking if it's running..."

    # Give the service a moment to initialize
    sleep 5

    # Check if the service is up
    if check_service_health "$SERVICE" "$PORT"; then
        success "[$SERVICE] started successfully."
    else
        error "Failed to start [$SERVICE]. Check $LOG_FILE for details."
        # Optionally, stop the service if health check fails
        kill "$SERVICE_PID" || true
        rm -f "$PID_FILE"
        exit 1
    fi

    cd "$BASE_DIR" || { error "Failed to navigate back to $BASE_DIR. Exiting."; exit 1; }
}

# Function to stop a service
stop_service() {
    local SERVICE=$1
    local PID_FILE="$PID_DIR/$SERVICE.pid"

    if [ ! -f "$PID_FILE" ]; then
        info "[$SERVICE] is not running (no PID file found)."
        return
    fi

    local SERVICE_PID
    SERVICE_PID=$(cat "$PID_FILE")

    if ! ps -p "$SERVICE_PID" > /dev/null 2>&1; then
        info "[$SERVICE] process with PID $SERVICE_PID is not running. Removing PID file."
        rm -f "$PID_FILE"
        return
    fi

    info "Stopping [$SERVICE] with PID $SERVICE_PID..."
    kill "$SERVICE_PID"

    # Wait for the process to terminate
    local WAIT_TIME=0
    local MAX_WAIT=30  # seconds
    while ps -p "$SERVICE_PID" > /dev/null 2>&1; do
        if [ "$WAIT_TIME" -ge "$MAX_WAIT" ]; then
            error "[$SERVICE] did not stop within $MAX_WAIT seconds. Sending SIGKILL..."
            kill -9 "$SERVICE_PID"
            break
        fi
        sleep 1
        WAIT_TIME=$((WAIT_TIME + 1))
    done

    success "[$SERVICE] stopped."
    rm -f "$PID_FILE"
}

# Function to start all services
start_all_services() {
    for SERVICE in "${SERVICES[@]}"; do
        start_service "$SERVICE"
    done
    info "========================================"
    success "All services started successfully."
    info "========================================"
}

# Function to stop all services
stop_all_services() {
    for SERVICE in "${SERVICES[@]}"; do
        stop_service "$SERVICE"
    done
    info "========================================"
    success "All services stopped successfully."
    info "========================================"
}

# Function to list all PIDs
list_pids() {
    info "========================================"
    info "Listing PIDs of All Managed Services"
    info "========================================"
    printf "%-25s %-10s %-10s\n" "Service" "PID" "Status"
    printf "%-25s %-10s %-10s\n" "-------" "---" "------"
    for SERVICE in "${SERVICES[@]}"; do
        local PID_FILE="$PID_DIR/$SERVICE.pid"
        if [ -f "$PID_FILE" ]; then
            local SERVICE_PID
            SERVICE_PID=$(cat "$PID_FILE")
            if ps -p "$SERVICE_PID" > /dev/null 2>&1; then
                STATUS="Running"
            else
                STATUS="Stopped"
            fi
        else
            SERVICE_PID="N/A"
            STATUS="Stopped"
        fi
        printf "%-25s %-10s %-10s\n" "$SERVICE" "$SERVICE_PID" "$STATUS"
    done
    info "========================================"
}

# Function to deploy the frontend
deploy_frontend() {
    info "Deploying frontend..."

    cd "$(pwd)/frontend" || { error "Frontend directory not found. Exiting."; exit 1; }

    # Install dependencies
    info "Installing frontend dependencies..."
    execute "npm install" "Failed to install dependencies."
    success "Dependencies installed successfully."

    # Build the frontend for production
    info "Building the frontend..."
    execute "npm run build" "Failed to build the frontend."
    success "Frontend built successfully."

    # Start the frontend in development mode
    info "Starting the frontend..."
    # Using a subshell to allow graceful exit if needed
    (npm start) || error "Frontend failed to start."

    # Optional: You can add a message indicating that the frontend is running
    success "Frontend is now running."

    cd "$(pwd)" || { error "Failed to navigate back to root directory. Exiting."; exit 1; }
}

# Function to display usage instructions
usage() {
    echo "Usage: $0 {build|start|stop|list|frontend} [service]"
    echo ""
    echo "Commands:"
    echo "  build             - Build all backend services"
    echo "  build <service>   - Build a specific backend service"
    echo "  start             - Start all backend services"
    echo "  start <service>   - Start a specific backend service"
    echo "  stop              - Stop all backend services"
    echo "  stop <service>    - Stop a specific backend service"
    echo "  list              - List all backend service PIDs and statuses"
    echo "  frontend   - Deploy the frontend"
    echo ""
    echo "Available Services:"
    for SERVICE in "${SERVICES[@]}"; do
        echo "  - $SERVICE"
    done
    exit 1
}

# =========================
# Main Script Logic
# =========================

# Ensure required commands are installed
if ! command -v mvn &> /dev/null
then
    error "'mvn' command not found. Please install Maven to proceed."
    exit 1
fi

if ! command -v nc &> /dev/null
then
    error "'nc' command not found. Please install Netcat to proceed."
    exit 1
fi

if ! command -v npm &> /dev/null
then
    error "'npm' command not found. Please install Node.js and npm to proceed."
    exit 1
fi

# Ensure at least one argument is provided
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
fi

# Parse the command and optional service
COMMAND=$1
SERVICE=$2

case "$COMMAND" in
    build)
        if [ -n "$SERVICE" ]; then
            if is_valid_service "$SERVICE"; then
                build_service "$SERVICE"
            else
                error "Invalid service name: $SERVICE"
                echo "Use one of the following services:"
                for S in "${SERVICES[@]}"; do
                    echo "  - $S"
                done
                exit 1
            fi
        else
            build_all_services
        fi
        ;;
    start)
        if [ -n "$SERVICE" ]; then
            if is_valid_service "$SERVICE"; then
                start_service "$SERVICE"
            else
                error "Invalid service name: $SERVICE"
                echo "Use one of the following services:"
                for S in "${SERVICES[@]}"; do
                    echo "  - $S"
                done
                exit 1
            fi
        else
            start_all_services
        fi
        ;;
    stop)
        if [ -n "$SERVICE" ]; then
            if is_valid_service "$SERVICE"; then
                stop_service "$SERVICE"
            else
                error "Invalid service name: $SERVICE"
                echo "Use one of the following services:"
                for S in "${SERVICES[@]}"; do
                    echo "  - $S"
                done
                exit 1
            fi
        else
            stop_all_services
        fi
        ;;
    list)
        if [ -n "$SERVICE" ]; then
            error "'list' command does not take any arguments."
            usage
        fi
        list_pids
        ;;
    frontend)
        if [ -n "$SERVICE" ]; then
            error "'frontend' command does not take any arguments."
            usage
        fi
        deploy_frontend
        ;;
    *)
        error "Invalid command: $COMMAND"
        usage
        ;;
esac

# =====================================================
# End of Script
# =====================================================
