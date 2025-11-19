#!/bin/bash

# Script to run all tests for the FinovaBank project

# Exit immediately if a command exits with a non-zero status.
set -e

# Define project root directory (assuming the script is run from the project root)
PROJECT_ROOT=$(pwd)

# --- Backend Tests ---
echo "-------------------------------------"
echo "--- Running Backend Module Tests ---"
echo "-------------------------------------"

BACKEND_MODULES=(
    "account-management"
    "loan-management"
    "savings-goals"
    "transaction-service"
    # Add other backend modules here if they exist and have tests
    # "auth-service" # Example: Uncomment if auth-service has tests to run
    # "security-service" # Example: Uncomment if security-service has tests to run
)

for module in "${BACKEND_MODULES[@]}"; do
    echo "\n--- Running tests for backend module: $module ---"
    MODULE_DIR="$PROJECT_ROOT/backend/$module"
    if [ -d "$MODULE_DIR" ]; then
        cd "$MODULE_DIR"
        if [ -f "pom.xml" ]; then
            mvn test
            echo "--- Finished tests for $module ---"
        else
            echo "Skipping $module: pom.xml not found."
        fi
        cd "$PROJECT_ROOT" # Return to project root
    else
        echo "Skipping $module: Directory not found."
    fi
done

# --- Web Frontend Tests ---
echo "\n-------------------------------------"
echo "--- Running Web Frontend Tests ---"
echo "-------------------------------------"
WEB_FRONTEND_DIR="$PROJECT_ROOT/web-frontend"
if [ -d "$WEB_FRONTEND_DIR" ]; then
    cd "$WEB_FRONTEND_DIR"
    if [ -f "package.json" ]; then
        # Ensure dependencies are installed (optional, uncomment if needed)
        # echo "Installing web frontend dependencies..."
        # npm install
        echo "Running web frontend tests..."
        npm test -- --watchAll=false
        echo "--- Finished Web Frontend Tests ---"
    else
        echo "Skipping web-frontend: package.json not found."
    fi
    cd "$PROJECT_ROOT" # Return to project root
else
    echo "Skipping web-frontend: Directory not found."
fi

# --- Mobile Frontend Tests ---
echo "\n--------------------------------------"
echo "--- Running Mobile Frontend Tests ---"
echo "--------------------------------------"
MOBILE_FRONTEND_DIR="$PROJECT_ROOT/mobile-frontend"
if [ -d "$MOBILE_FRONTEND_DIR" ]; then
    cd "$MOBILE_FRONTEND_DIR"
    if [ -f "package.json" ]; then
        # Ensure dependencies are installed (optional, uncomment if needed)
        # echo "Installing mobile frontend dependencies..."
        # npm install
        echo "Running mobile frontend tests..."
        npm test -- --watchAll=false
        echo "--- Finished Mobile Frontend Tests ---"
    else
        echo "Skipping mobile-frontend: package.json not found."
    fi
    cd "$PROJECT_ROOT" # Return to project root
else
    echo "Skipping mobile-frontend: Directory not found."
fi

echo "\n-------------------------------------"
echo "--- All Test Executions Attempted ---"
echo "-------------------------------------"
