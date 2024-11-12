#!/bin/bash

# =====================================================
#   Frontend Deployment Script
#   Description: Installs dependencies, builds, and starts the frontend.
# =====================================================

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

# --------------------
# Main Script
# --------------------

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

# =====================================================
# End of Script
# =====================================================
