#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# =========================
# Configuration
# =========================

# Array of services to manage
# Ensuring eureka-server starts first, then api-gateway, followed by the rest
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
BASE_DIR="/mnt/c/Users/36202/OneDrive/Desktop/FinovaBank/backend"

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
    if [[ -n "${SERVICE_PORTS[$SERVICE]}" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if a service is up by port
check_service_health() {
    local SERVICE_NAME=$1
    local PORT=$2
    local MAX_RETRIES=30          # Number of retries
    local RETRY_INTERVAL=5        # Seconds between retries

    echo "Checking health for $SERVICE_NAME on port $PORT..."

    for ((i=1;i<=MAX_RETRIES;i++)); do
        if nc -z 127.0.0.1 "$PORT"; then
            echo "$SERVICE_NAME is up (Port $PORT)."
            return 0
        else
            echo "Waiting for $SERVICE_NAME to start... ($i/$MAX_RETRIES)"
            sleep "$RETRY_INTERVAL"
        fi
    done

    echo "Failed to start $SERVICE_NAME after $MAX_RETRIES attempts."
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
            echo "[$SERVICE] is already running with PID $EXISTING_PID."
            return
        else
            echo "Found stale PID file for [$SERVICE]. Removing."
            rm -f "$PID_FILE"
        fi
    fi

    echo "----------------------------------------"
    echo "Starting $SERVICE on port $PORT..."

    cd "$BASE_DIR/$SERVICE" || { echo "Directory $BASE_DIR/$SERVICE not found. Exiting."; exit 1; }

    # Start the service in the background using nohup with proper environment variables
    # Redirect output to a dedicated log file
    nohup mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=$PORT" > "$LOG_FILE" 2>&1 &
    SERVICE_PID=$!
    echo "$SERVICE_PID" > "$PID_FILE"
    echo "[$SERVICE] started with PID $SERVICE_PID. Checking if it's running..."

    # Give the service a moment to initialize
    sleep 5

    # Check if the service is up
    if check_service_health "$SERVICE" "$PORT"; then
        echo "[$SERVICE] started successfully."
    else
        echo "Failed to start [$SERVICE]. Check $LOG_FILE for details."
        # Optionally, stop the service if health check fails
        kill "$SERVICE_PID" || true
        rm -f "$PID_FILE"
        exit 1
    fi

    cd "$BASE_DIR" || { echo "Failed to navigate back to $BASE_DIR. Exiting."; exit 1; }
}

# Function to stop a service
stop_service() {
    local SERVICE=$1
    local PID_FILE="$PID_DIR/$SERVICE.pid"

    if [ ! -f "$PID_FILE" ]; then
        echo "[$SERVICE] is not running (no PID file found)."
        return
    fi

    local SERVICE_PID
    SERVICE_PID=$(cat "$PID_FILE")

    if ! ps -p "$SERVICE_PID" > /dev/null 2>&1; then
        echo "[$SERVICE] process with PID $SERVICE_PID is not running. Removing PID file."
        rm -f "$PID_FILE"
        return
    fi

    echo "Stopping [$SERVICE] with PID $SERVICE_PID..."
    kill "$SERVICE_PID"

    # Wait for the process to terminate
    local WAIT_TIME=0
    local MAX_WAIT=30  # seconds
    while ps -p "$SERVICE_PID" > /dev/null 2>&1; do
        if [ "$WAIT_TIME" -ge "$MAX_WAIT" ]; then
            echo "[$SERVICE] did not stop within $MAX_WAIT seconds. Sending SIGKILL..."
            kill -9 "$SERVICE_PID"
            break
        fi
        sleep 1
        WAIT_TIME=$((WAIT_TIME + 1))
    done

    echo "[$SERVICE] stopped."
    rm -f "$PID_FILE"
}

# Function to start all services
start_all() {
    for SERVICE in "${SERVICES[@]}"; do
        start_service "$SERVICE"
    done
    echo "========================================"
    echo "All services started successfully."
    echo "========================================"
}

# Function to stop all services
stop_all() {
    for SERVICE in "${SERVICES[@]}"; do
        stop_service "$SERVICE"
    done
    echo "========================================"
    echo "All services stopped successfully."
    echo "========================================"
}

# Function to list all PIDs
list_pids() {
    echo "========================================"
    echo "Listing PIDs of All Managed Services"
    echo "========================================"
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
    echo "========================================"
}

# Function to display usage instructions
usage() {
    echo "Usage: $0 {start|stop|list} [service]"
    echo ""
    echo "Commands:"
    echo "  start       - Start all services"
    echo "  start <svc> - Start a specific service"
    echo "  stop        - Stop all services"
    echo "  stop <svc>  - Stop a specific service"
    echo "  list        - List all service PIDs and statuses"
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

# Ensure 'nc' (Netcat) is installed for port checking
if ! command -v nc &> /dev/null
then
    echo "'nc' command not found. Please install Netcat to proceed."
    exit 1
fi

# Ensure 'mvn' (Maven) is installed
if ! command -v mvn &> /dev/null
then
    echo "'mvn' command not found. Please install Maven to proceed."
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
    start)
        if [ -n "$SERVICE" ]; then
            if is_valid_service "$SERVICE"; then
                start_service "$SERVICE"
            else
                echo "Invalid service name: $SERVICE"
                echo "Use one of the following services:"
                for S in "${SERVICES[@]}"; do
                    echo "  - $S"
                done
                exit 1
            fi
        else
            start_all
        fi
        ;;
    stop)
        if [ -n "$SERVICE" ]; then
            if is_valid_service "$SERVICE"; then
                stop_service "$SERVICE"
            else
                echo "Invalid service name: $SERVICE"
                echo "Use one of the following services:"
                for S in "${SERVICES[@]}"; do
                    echo "  - $S"
                done
                exit 1
            fi
        else
            stop_all
        fi
        ;;
    list)
        if [ -n "$SERVICE" ]; then
            echo "'list' command does not take any arguments."
            usage
        fi
        list_pids
        ;;
    *)
        echo "Invalid command: $COMMAND"
        usage
        ;;
esac
