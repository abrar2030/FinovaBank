#!/bin/bash
# =====================================================
# FinovaBank Deployment Automation Script
# =====================================================
# This script automates the deployment process for the
# FinovaBank platform to various environments including
# development, staging, and production.
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
ENVIRONMENT="dev"
CONFIG_DIR="./deployment/config"
KUBE_CONFIG=""
DOCKER_REGISTRY="docker.io/finovabank"
VERSION=$(git describe --tags --always || echo "latest")
SKIP_TESTS=false
SKIP_BUILD=false
DEPLOY_ALL=true
DEPLOY_BACKEND=false
DEPLOY_FRONTEND=false
DEPLOY_MOBILE=false
DEPLOY_INFRA=false

# Function to display usage information
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [options] [components]"
    echo -e ""
    echo -e "${BLUE}Components:${NC}"
    echo -e "  all                  Deploy all components (default)"
    echo -e "  backend              Deploy backend services only"
    echo -e "  frontend             Deploy web frontend only"
    echo -e "  mobile               Deploy mobile frontend only"
    echo -e "  infra                Deploy infrastructure only"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --help               Display this help message"
    echo -e "  --env ENV            Target environment (dev, staging, prod) (default: $ENVIRONMENT)"
    echo -e "  --config-dir DIR     Configuration directory (default: $CONFIG_DIR)"
    echo -e "  --kube-config FILE   Kubernetes config file"
    echo -e "  --registry URL       Docker registry URL (default: $DOCKER_REGISTRY)"
    echo -e "  --version VERSION    Version to deploy (default: git-derived or 'latest')"
    echo -e "  --skip-tests         Skip running tests before deployment"
    echo -e "  --skip-build         Skip building images (use existing ones)"
    echo -e "  --dry-run            Show what would be done without making changes"
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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    step_msg "Checking deployment prerequisites..."
    
    # Check for required tools
    local required_tools=("docker" "git")
    
    if [ "$ENVIRONMENT" != "dev" ]; then
        required_tools+=("kubectl")
    fi
    
    for tool in "${required_tools[@]}"; do
        if ! command_exists "$tool"; then
            error_msg "$tool is not installed"
        fi
    done
    
    # Check Docker daemon
    if ! docker info >/dev/null 2>&1; then
        error_msg "Docker daemon is not running"
    fi
    
    # Check Kubernetes connection if needed
    if [ "$ENVIRONMENT" != "dev" ] && [ -n "$KUBE_CONFIG" ]; then
        if ! KUBECONFIG="$KUBE_CONFIG" kubectl get nodes >/dev/null 2>&1; then
            error_msg "Cannot connect to Kubernetes cluster using provided config"
        fi
    fi
    
    # Check configuration directory
    if [ ! -d "$CONFIG_DIR" ]; then
        error_msg "Configuration directory not found: $CONFIG_DIR"
    fi
    
    # Check environment-specific config
    if [ ! -d "$CONFIG_DIR/$ENVIRONMENT" ]; then
        error_msg "Configuration for environment '$ENVIRONMENT' not found in $CONFIG_DIR"
    fi
    
    echo -e "${GREEN}All prerequisites satisfied!${NC}"
}

# Function to run tests before deployment
run_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        warning_msg "Skipping tests as requested"
        return
    fi
    
    step_msg "Running tests before deployment..."
    
    # Run appropriate tests based on components
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_BACKEND" = true ]; then
        echo "Running backend tests..."
        cd backend
        ./mvnw test
        cd ..
    fi
    
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_FRONTEND" = true ]; then
        echo "Running frontend tests..."
        cd web-frontend
        npm test -- --watchAll=false
        cd ..
    fi
    
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_MOBILE" = true ]; then
        echo "Running mobile tests..."
        cd mobile-frontend
        npm test -- --watchAll=false
        cd ..
    fi
    
    echo -e "${GREEN}All tests passed!${NC}"
}

# Function to build Docker images
build_images() {
    if [ "$SKIP_BUILD" = true ]; then
        warning_msg "Skipping image builds as requested"
        return
    fi
    
    step_msg "Building Docker images..."
    
    # Build backend images if needed
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_BACKEND" = true ]; then
        echo "Building backend images..."
        
        # Find all services with Dockerfiles
        for service_dir in backend/*/; do
            if [ -f "${service_dir}Dockerfile" ]; then
                service_name=$(basename "$service_dir")
                echo "Building $service_name service..."
                
                docker build -t "$DOCKER_REGISTRY/$service_name:$VERSION" -f "${service_dir}Dockerfile" "$service_dir"
                
                if [ "$DRY_RUN" != true ]; then
                    docker push "$DOCKER_REGISTRY/$service_name:$VERSION"
                else
                    echo "[DRY RUN] Would push $DOCKER_REGISTRY/$service_name:$VERSION"
                fi
            fi
        done
    fi
    
    # Build frontend image if needed
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_FRONTEND" = true ]; then
        echo "Building web frontend image..."
        
        docker build -t "$DOCKER_REGISTRY/web-frontend:$VERSION" -f web-frontend/Dockerfile web-frontend
        
        if [ "$DRY_RUN" != true ]; then
            docker push "$DOCKER_REGISTRY/web-frontend:$VERSION"
        else
            echo "[DRY RUN] Would push $DOCKER_REGISTRY/web-frontend:$VERSION"
        fi
    fi
    
    echo -e "${GREEN}All images built and pushed successfully!${NC}"
}

# Function to deploy to development environment
deploy_to_dev() {
    step_msg "Deploying to development environment..."
    
    # Use docker-compose for local development
    if [ ! -f "docker-compose.yml" ]; then
        error_msg "docker-compose.yml not found"
    fi
    
    # Apply environment-specific configuration
    if [ -f "$CONFIG_DIR/dev/.env" ]; then
        cp "$CONFIG_DIR/dev/.env" .env
    fi
    
    # Start the services
    if [ "$DRY_RUN" != true ]; then
        docker-compose down
        docker-compose up -d
    else
        echo "[DRY RUN] Would run: docker-compose down && docker-compose up -d"
    fi
    
    echo -e "${GREEN}Deployment to development environment completed!${NC}"
    echo -e "You can access the application at: ${BLUE}http://localhost:3000${NC}"
}

# Function to deploy to Kubernetes (staging/production)
deploy_to_kubernetes() {
    step_msg "Deploying to $ENVIRONMENT environment using Kubernetes..."
    
    # Set KUBECONFIG if provided
    if [ -n "$KUBE_CONFIG" ]; then
        export KUBECONFIG="$KUBE_CONFIG"
    fi
    
    # Apply environment-specific configuration
    local kube_dir="$CONFIG_DIR/$ENVIRONMENT/kubernetes"
    
    if [ ! -d "$kube_dir" ]; then
        error_msg "Kubernetes configuration directory not found: $kube_dir"
    fi
    
    # Update image versions in Kubernetes manifests
    echo "Updating image versions in Kubernetes manifests..."
    
    find "$kube_dir" -name "*.yaml" -type f -exec sed -i "s|image: $DOCKER_REGISTRY/.*:|image: $DOCKER_REGISTRY/\1:$VERSION|g" {} \;
    
    # Apply Kubernetes manifests
    echo "Applying Kubernetes manifests..."
    
    if [ "$DRY_RUN" != true ]; then
        # Apply infrastructure manifests first if needed
        if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_INFRA" = true ]; then
            if [ -d "$kube_dir/infrastructure" ]; then
                kubectl apply -f "$kube_dir/infrastructure"
            fi
        fi
        
        # Apply backend manifests if needed
        if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_BACKEND" = true ]; then
            if [ -d "$kube_dir/backend" ]; then
                kubectl apply -f "$kube_dir/backend"
            fi
        fi
        
        # Apply frontend manifests if needed
        if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_FRONTEND" = true ]; then
            if [ -d "$kube_dir/frontend" ]; then
                kubectl apply -f "$kube_dir/frontend"
            fi
        fi
    else
        echo "[DRY RUN] Would apply Kubernetes manifests from $kube_dir"
    fi
    
    echo -e "${GREEN}Deployment to $ENVIRONMENT environment completed!${NC}"
    
    # Show access information if available
    if [ -f "$CONFIG_DIR/$ENVIRONMENT/access.txt" ]; then
        echo -e "Access information:"
        cat "$CONFIG_DIR/$ENVIRONMENT/access.txt"
    fi
}

# Function to verify deployment
verify_deployment() {
    step_msg "Verifying deployment..."
    
    if [ "$ENVIRONMENT" = "dev" ]; then
        # Verify local deployment
        echo "Checking if services are running..."
        
        if [ "$DRY_RUN" != true ]; then
            docker-compose ps
            
            # Wait for services to be ready
            echo "Waiting for services to be ready..."
            sleep 10
            
            # Check if web frontend is accessible
            if curl -s http://localhost:3000 >/dev/null; then
                echo -e "${GREEN}Web frontend is accessible!${NC}"
            else
                warning_msg "Web frontend is not accessible yet. It might still be starting up."
            fi
        else
            echo "[DRY RUN] Would verify services are running"
        fi
    else
        # Verify Kubernetes deployment
        echo "Checking deployment status..."
        
        if [ "$DRY_RUN" != true ]; then
            kubectl get deployments -n finovabank
            
            # Check if pods are running
            echo "Checking if pods are running..."
            kubectl get pods -n finovabank
            
            # Check if services are accessible
            echo "Checking if services are accessible..."
            kubectl get svc -n finovabank
        else
            echo "[DRY RUN] Would verify Kubernetes deployment status"
        fi
    fi
    
    echo -e "${GREEN}Deployment verification completed!${NC}"
}

# Parse command line arguments
DRY_RUN=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        all)
            DEPLOY_ALL=true
            DEPLOY_BACKEND=false
            DEPLOY_FRONTEND=false
            DEPLOY_MOBILE=false
            DEPLOY_INFRA=false
            ;;
        backend)
            DEPLOY_ALL=false
            DEPLOY_BACKEND=true
            ;;
        frontend)
            DEPLOY_ALL=false
            DEPLOY_FRONTEND=true
            ;;
        mobile)
            DEPLOY_ALL=false
            DEPLOY_MOBILE=true
            ;;
        infra)
            DEPLOY_ALL=false
            DEPLOY_INFRA=true
            ;;
        --help)
            usage
            ;;
        --env)
            ENVIRONMENT="$2"
            shift
            ;;
        --config-dir)
            CONFIG_DIR="$2"
            shift
            ;;
        --kube-config)
            KUBE_CONFIG="$2"
            shift
            ;;
        --registry)
            DOCKER_REGISTRY="$2"
            shift
            ;;
        --version)
            VERSION="$2"
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            ;;
        --skip-build)
            SKIP_BUILD=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        *)
            error_msg "Unknown option: $1"
            ;;
    esac
    shift
done

# Main execution
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}FinovaBank Deployment Automation${NC}"
echo -e "${BLUE}======================================================${NC}"
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "Version: ${YELLOW}$VERSION${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
fi
echo -e "${BLUE}======================================================${NC}"

# Check if we're in the right directory
if [ ! -f "README.md" ] || ! grep -q "FinovaBank" "README.md"; then
    error_msg "Please run this script from the root of the FinovaBank repository"
fi

# Check prerequisites
check_prerequisites

# Run tests
run_tests

# Build images
build_images

# Deploy based on environment
if [ "$ENVIRONMENT" = "dev" ]; then
    deploy_to_dev
else
    deploy_to_kubernetes
fi

# Verify deployment
verify_deployment

echo -e "\n${GREEN}Deployment process completed successfully!${NC}"
echo -e "${BLUE}======================================================${NC}"

exit 0
