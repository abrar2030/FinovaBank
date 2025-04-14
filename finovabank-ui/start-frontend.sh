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
# Configuration
# --------------------
PORT=${PORT:-3000}
NODE_ENV=${NODE_ENV:-development}
API_URL=${API_URL:-http://localhost:8080/api}

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

# Print warning messages
warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a port is available
check_port() {
    if command_exists lsof; then
        if lsof -i :$1 >/dev/null 2>&1; then
            return 1
        fi
    elif command_exists netstat; then
        if netstat -an | grep -q ":$1 .*LISTEN"; then
            return 1
        fi
    fi
    return 0
}

# Execute a command and handle errors
execute() {
    echo -e "${BLUE}[EXEC]${NC} $1"
    eval "$1"
    if [ $? -ne 0 ]; then
        error "$2"
        exit 1
    fi
}

# --------------------
# Environment Checks
# --------------------

# Check Node.js installation
if ! command_exists node; then
    error "Node.js is not installed. Please install Node.js and try again."
    exit 1
fi

# Check npm installation
if ! command_exists npm; then
    error "npm is not installed. Please install npm and try again."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2)
if [[ "$NODE_VERSION" < "14.0.0" ]]; then
    warn "Node.js version $NODE_VERSION is below recommended version 14.0.0"
fi

# Check port availability
if ! check_port $PORT; then
    error "Port $PORT is already in use. Please choose a different port."
    exit 1
fi

# --------------------
# Main Script
# --------------------

# Set environment variables
export PORT=$PORT
export NODE_ENV=$NODE_ENV
export REACT_APP_API_URL=$API_URL

info "Environment: $NODE_ENV"
info "Port: $PORT"
info "API URL: $API_URL"

# Install dependencies
info "Installing frontend dependencies..."
execute "npm install" "Failed to install dependencies."
success "Dependencies installed successfully."

if [ "$NODE_ENV" = "production" ]; then
    # Build the frontend for production
    info "Building the frontend for production..."
    execute "npm run build" "Failed to build the frontend."
    success "Frontend built successfully."

    # Serve the production build
    info "Starting production server..."
    if command_exists serve; then
        execute "serve -s build -l $PORT" "Failed to start production server."
    else
        warn "serve package not found. Installing globally..."
        execute "npm install -g serve" "Failed to install serve package."
        execute "serve -s build -l $PORT" "Failed to start production server."
    fi
else
    # Start the frontend in development mode
    info "Starting development server..."
    execute "npm start" "Failed to start development server."
fi

# =====================================================
# End of Script
# =====================================================
