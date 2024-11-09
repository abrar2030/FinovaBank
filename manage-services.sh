#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define project root
PROJECT_ROOT=$(pwd)

# Define backend and frontend directories
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

# Define frontend subdirectories
FINTECH_PAYMENT_FRONTEND_DIR="$FRONTEND_DIR/fintech-payment-frontend"

# Define backend and frontend services
BACKEND_SERVICES=("eureka-server" "api-gateway" "user-service" "payment-service" "notification-service")
FRONTEND_SERVICES=("frontend" "fintech-payment-frontend")

# Function to display usage information
usage() {
    echo "Usage: $0 {clean|build|run} {service-name|all}"
    echo ""
    echo "Commands:"
    echo "  clean     Clean build artifacts for the specified service."
    echo "  build     Build the specified service."
    echo "  run       Run the specified service."
    echo ""
    echo "Services:"
    echo "  Backend Services:"
    for service in "${BACKEND_SERVICES[@]}"; do
        echo "    - $service"
    done
    echo "  Frontend Services:"
    for service in "${FRONTEND_SERVICES[@]}"; do
        echo "    - $service"
    done
    echo ""
    echo "Examples:"
    echo "  $0 clean user-service"
    echo "  $0 build frontend"
    echo "  $0 run fintech-payment-frontend"
    echo "  $0 build all"
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

# Function to clean a backend service
clean_backend() {
    SERVICE=$1
    SERVICE_DIR="$BACKEND_DIR/$SERVICE"

    if [ -d "$SERVICE_DIR" ]; then
        echo "Cleaning backend service: $SERVICE"
        cd "$SERVICE_DIR"
        mvn clean
        echo "Backend service '$SERVICE' cleaned successfully."
        cd "$PROJECT_ROOT"
    else
        echo "Error: Backend service directory '$SERVICE_DIR' does not exist."
        exit 1
    fi
}

# Function to build a backend service
build_backend() {
    SERVICE=$1
    SERVICE_DIR="$BACKEND_DIR/$SERVICE"

    if [ -d "$SERVICE_DIR" ]; then
        echo "Building backend service: $SERVICE"
        cd "$SERVICE_DIR"
        mvn clean install -DskipTests
        echo "Backend service '$SERVICE' built successfully."
        cd "$PROJECT_ROOT"
    else
        echo "Error: Backend service directory '$SERVICE_DIR' does not exist."
        exit 1
    fi
}

# Function to run a backend service
run_backend() {
    SERVICE=$1
    SERVICE_DIR="$BACKEND_DIR/$SERVICE"

    if [ -d "$SERVICE_DIR" ]; then
        echo "Running backend service: $SERVICE"
        cd "$PROJECT_ROOT"
        docker-compose up -d "$SERVICE"
        echo "Backend service '$SERVICE' is now running."
    else
        echo "Error: Backend service directory '$SERVICE_DIR' does not exist."
        exit 1
    fi
}

# Function to clean a frontend service
clean_frontend() {
    SERVICE=$1
    if [ "$SERVICE" == "frontend" ]; then
        SERVICE_DIR="$FRONTEND_DIR"
    elif [ "$SERVICE" == "fintech-payment-frontend" ]; then
        SERVICE_DIR="$FINTECH_PAYMENT_FRONTEND_DIR"
    else
        echo "Error: Invalid frontend service '$SERVICE'."
        exit 1
    fi

    if [ -d "$SERVICE_DIR" ]; then
        echo "Cleaning frontend service: $SERVICE"
        cd "$SERVICE_DIR"
        # Remove node_modules and build directories
        rm -rf node_modules
        rm -rf build
        echo "Frontend service '$SERVICE' cleaned successfully."
        cd "$PROJECT_ROOT"
    else
        echo "Error: Frontend service directory '$SERVICE_DIR' does not exist."
        exit 1
    fi
}

# Function to build a frontend service
build_frontend() {
    SERVICE=$1
    if [ "$SERVICE" == "frontend" ]; then
        SERVICE_DIR="$FRONTEND_DIR"
    elif [ "$SERVICE" == "fintech-payment-frontend" ]; then
        SERVICE_DIR="$FINTECH_PAYMENT_FRONTEND_DIR"
    else
        echo "Error: Invalid frontend service '$SERVICE'."
        exit 1
    fi

    if [ -d "$SERVICE_DIR" ]; then
        echo "Building frontend service: $SERVICE"
        cd "$SERVICE_DIR"
        npm install
        npm run build
        echo "Frontend service '$SERVICE' built successfully."
        cd "$PROJECT_ROOT"
    else
        echo "Error: Frontend service directory '$SERVICE_DIR' does not exist."
        exit 1
    fi
}

# Function to run a frontend service
run_frontend() {
    SERVICE=$1
    if [ "$SERVICE" == "frontend" ]; then
        SERVICE_DIR="$FRONTEND_DIR"
    elif [ "$SERVICE" == "fintech-payment-frontend" ]; then
        SERVICE_DIR="$FINTECH_PAYMENT_FRONTEND_DIR"
    else
        echo "Error: Invalid frontend service '$SERVICE'."
        exit 1
    fi

    if [ -d "$SERVICE_DIR" ]; then
        echo "Running frontend service: $SERVICE"
        cd "$PROJECT_ROOT"
        docker-compose up -d "$SERVICE"
        echo "Frontend service '$SERVICE' is now running."
    else
        echo "Error: Frontend service directory '$SERVICE_DIR' does not exist."
        exit 1
    fi
}

# Function to perform actions on all services
all_services() {
    ACTION=$1

    echo "Performing '$ACTION' on all backend services..."
    for service in "${BACKEND_SERVICES[@]}"; do
        case "$ACTION" in
            clean)
                clean_backend "$service"
                ;;
            build)
                build_backend "$service"
                ;;
            run)
                run_backend "$service"
                ;;
            *)
                echo "Error: Invalid action '$ACTION'."
                usage
                ;;
        esac
    done

    echo "Performing '$ACTION' on all frontend services..."
    for service in "${FRONTEND_SERVICES[@]}"; do
        case "$ACTION" in
            clean)
                clean_frontend "$service"
                ;;
            build)
                build_frontend "$service"
                ;;
            run)
                run_frontend "$service"
                ;;
            *)
                echo "Error: Invalid action '$ACTION'."
                usage
                ;;
        esac
    done
}

# Main function to handle commands
main() {
    # Check if the correct number of arguments is provided
    if [ "$#" -ne 2 ]; then
        usage
    fi

    COMMAND=$1
    SERVICE=$2

    # Check for Docker and Docker Compose
    check_docker
    check_docker_compose

    if [ "$SERVICE" == "all" ]; then
        # Perform action on all services
        all_services "$COMMAND"
        exit 0
    fi

    # Determine if the service is backend or frontend
    # shellcheck disable=SC2199
    # shellcheck disable=SC2076
    if [[ " ${BACKEND_SERVICES[@]} " =~ " ${SERVICE} " ]]; then
        SERVICE_TYPE="backend"
    elif [[ " ${FRONTEND_SERVICES[@]} " =~ " ${SERVICE} " ]]; then
        SERVICE_TYPE="frontend"
    else
        echo "Error: Service '$SERVICE' not recognized."
        usage
    fi

    # Execute the appropriate command based on service type
    case "$SERVICE_TYPE" in
        backend)
            case "$COMMAND" in
                clean)
                    clean_backend "$SERVICE"
                    ;;
                build)
                    build_backend "$SERVICE"
                    ;;
                run)
                    run_backend "$SERVICE"
                    ;;
                *)
                    echo "Error: Invalid command '$COMMAND' for backend service."
                    usage
                    ;;
            esac
            ;;
        frontend)
            case "$COMMAND" in
                clean)
                    clean_frontend "$SERVICE"
                    ;;
                build)
                    build_frontend "$SERVICE"
                    ;;
                run)
                    run_frontend "$SERVICE"
                    ;;
                *)
                    echo "Error: Invalid command '$COMMAND' for frontend service."
                    usage
                    ;;
            esac
            ;;
        *)
            echo "Error: Unknown service type for '$SERVICE'."
            usage
            ;;
    esac
}

# Invoke main with all script arguments
main "$@"
