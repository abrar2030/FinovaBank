#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# =========================
# Configuration
# =========================

# Array of services to build
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
    echo "----------------------------------------"
    echo "Building $SERVICE..."

    # Navigate to the service directory
    cd "$BASE_DIR/$SERVICE" || {
        echo "Directory $BASE_DIR/$SERVICE not found. Exiting."
        exit 1
    }

    # Execute Maven build
    mvn clean install

    # Check if the build was successful
    if [ $? -ne 0 ]; then
        echo "Build failed for $SERVICE. Exiting."
        exit 1
    fi

    echo "$SERVICE built successfully."

    # Navigate back to the base directory
    cd "$BASE_DIR" || {
        echo "Failed to navigate back to $BASE_DIR. Exiting."
        exit 1
    }
}

# Function to build all services
build_all_services() {
    for SERVICE in "${SERVICES[@]}"; do
        build_service "$SERVICE"
    done
    echo "========================================"
    echo "All services built successfully."
    echo "========================================"
}

# Function to display usage instructions
usage() {
    echo "Usage: $0 [service]"
    echo ""
    echo "If no service is specified, all services will be built."
    echo "If a service name is specified, only that service will be built."
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

# Ensure 'mvn' (Maven) is installed
if ! command -v mvn &> /dev/null
then
    echo "'mvn' command not found. Please install Maven to proceed."
    exit 1
fi

# Ensure at least zero or one argument is provided
if [ $# -gt 1 ]; then
    usage
fi

# Parse arguments
if [ $# -eq 1 ]; then
    SERVICE=$1
    if is_valid_service "$SERVICE"; then
        build_service "$SERVICE"
    else
        echo "Invalid service name: $SERVICE"
        echo "Use one of the following services:"
        for S in "${SERVICES[@]}"; do
            echo "  - $S"
        done
        exit 1
    fi
else
    build_all_services
fi
