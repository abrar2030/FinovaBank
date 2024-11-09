#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define project root
PROJECT_ROOT=$(pwd)

# Define backend and frontend directories
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

# Define backend services
BACKEND_SERVICES=("eureka-server" "api-gateway" "user-service" "payment-service" "notification-service")

# Function to build backend services
build_backend_services() {
    echo "=============================="
    echo "Building Backend Services..."
    echo "=============================="

    for SERVICE in "${BACKEND_SERVICES[@]}"
    do
        SERVICE_PATH="$BACKEND_DIR/$SERVICE"
        echo "----------------------------------"
        echo "Building $SERVICE..."
        echo "----------------------------------"

        if [ -d "$SERVICE_PATH" ]; then
            cd "$SERVICE_PATH"
            mvn clean install -DskipTests
            echo "$SERVICE built successfully."
            cd "$PROJECT_ROOT"
        else
            echo "Error: Directory $SERVICE_PATH does not exist."
            exit 1
        fi
    done
}

# Function to build frontend
build_frontend() {
    echo "================="
    echo "Building Frontend..."
    echo "================="

    if [ -d "$FRONTEND_DIR" ]; then
        echo "----------------------------------"
        echo "Building Frontend..."
        echo "----------------------------------"
        cd "$FRONTEND_DIR"
        npm install
        npm run build
        echo "Frontend built successfully."
        cd "$PROJECT_ROOT"
    else
        echo "Error: Frontend directory $FRONTEND_DIR does not exist."
        exit 1
    fi
}

# Function to build Docker images
build_docker_images() {
    echo "====================="
    echo "Building Docker Images..."
    echo "====================="

    for SERVICE in "${BACKEND_SERVICES[@]}"
    do
        SERVICE_PATH="$BACKEND_DIR/$SERVICE"
        echo "----------------------------------"
        echo "Building Docker image for $SERVICE..."
        echo "----------------------------------"

        if [ -d "$SERVICE_PATH" ]; then
            cd "$SERVICE_PATH"
            docker build -t fintech/$SERVICE:1.0 .
            echo "Docker image for $SERVICE built successfully."
            cd "$PROJECT_ROOT"
        else
            echo "Error: Directory $SERVICE_PATH does not exist."
            exit 1
        fi
    done

    # Build Docker image for frontend
    echo "----------------------------------"
    echo "Building Docker image for frontend..."
    echo "----------------------------------"

    if [ -d "$FRONTEND_DIR" ]; then
        cd "$FRONTEND_DIR"
        docker build -t fintech/frontend:1.0 .
        echo "Docker image for frontend built successfully."
        cd "$PROJECT_ROOT"
    else
        echo "Error: Frontend directory $FRONTEND_DIR does not exist."
        exit 1
    fi
}

# Function to start all services using Docker Compose
start_services() {
    echo "=============================="
    echo "Starting All Services with Docker Compose..."
    echo "=============================="

    if [ -f "$PROJECT_ROOT/docker-compose.yml" ]; then
        cd "$PROJECT_ROOT"
        docker-compose up -d --build
        echo "All services started successfully."
    else
        echo "Error: docker-compose.yml not found in the root directory."
        exit 1
    fi
}

# Function to stop all services using Docker Compose
stop_services() {
    echo "=============================="
    echo "Stopping All Services with Docker Compose..."
    echo "=============================="

    if [ -f "$PROJECT_ROOT/docker-compose.yml" ]; then
        cd "$PROJECT_ROOT"
        docker-compose down
        echo "All services stopped successfully."
    else
        echo "Error: docker-compose.yml not found in the root directory."
        exit 1
    fi
}

# Function to display usage
usage() {
    echo "Usage: $0 {build|start|stop|all}"
    echo "  build - Builds backend services, frontend, and Docker images."
    echo "  start - Starts all services using Docker Compose."
    echo "  stop  - Stops all services using Docker Compose."
    echo "  all   - Builds and starts all services."
    exit 1
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null
    then
        echo "Docker could not be found. Please install Docker before running this script."
        exit 1
    fi
}

# Function to check if Docker Compose is installed
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null
    then
        echo "Docker Compose could not be found. Please install Docker Compose before running this script."
        exit 1
    fi
}

# Main script execution
main() {
    # Ensure script is run from the project root
    if [ ! -d "$BACKEND_DIR" ] || [ ! -d "$FRONTEND_DIR" ]; then
        echo "Error: Please run this script from the project root where 'backend' and 'frontend' directories exist."
        exit 1
    fi

    # Check for Docker and Docker Compose
    check_docker
    check_docker_compose

    # Parse command-line arguments
    case "$1" in
        build)
            build_backend_services
            build_frontend
            build_docker_images
            ;;
        start)
            start_services
            ;;
        stop)
            stop_services
            ;;
        all)
            build_backend_services
            build_frontend
            build_docker_images
            start_services
            ;;
        *)
            usage
            ;;
    esac
}

# Invoke main with all script arguments
main "$@"
