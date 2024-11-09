#!/bin/bash

# =====================================================
# Docker Auto Build & Push Script
# =====================================================
# This script automates the process of building, tagging,
# and pushing Docker images for changed services to Docker Hub.
#
# Usage:
#   ./docker-auto-build-push.sh
# =====================================================

# Function to display usage information
usage() {
    echo "Usage: $0"
    echo ""
    echo "This script detects changes, builds, tags, and pushes Docker images to Docker Hub."
    exit 1
}

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Error: Docker is not installed. Please install Docker before running this script."
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null
then
    echo "Error: Git is not installed. Please install Git before running this script."
    exit 1
fi

# Check if inside a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null
then
    echo "Error: This script must be run inside a Git repository."
    exit 1
fi

# Prompt for Docker Hub credentials
read -p "Docker Hub Username: " DOCKERHUB_USERNAME
read -s -p "Docker Hub Password: " DOCKERHUB_PASSWORD
echo ""

# Log in to Docker Hub
if ! echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin; then
    echo "Error: Docker login failed. Please check your credentials."
    exit 1
fi

# Services to build and push
SERVICES=("eureka-server" "api-gateway" "user-service" "payment-service" "notification-service" "fintech-payment-frontend")

# Iterate over each service to check for changes
for SERVICE in "${SERVICES[@]}"
do
    SERVICE_PATH="./backend/$SERVICE"
    if [ "$SERVICE" == "fintech-payment-frontend" ]; then
        SERVICE_PATH="./frontend/fintech-payment-frontend"
    fi

    # Check if there are any changes in the service directory
    if git diff --quiet HEAD -- "$SERVICE_PATH"; then
        echo "No changes detected in $SERVICE. Skipping build and push."
    else
        echo "Changes detected in $SERVICE. Proceeding with build and push."

        # Build Docker image
        IMAGE_NAME="abrar2030/$SERVICE"
        echo "Building Docker image for $SERVICE..."
        if docker build -t "$IMAGE_NAME" "$SERVICE_PATH"; then
            echo "Successfully built $IMAGE_NAME."
        else
            echo "Error: Failed to build Docker image for $SERVICE."
            exit 1
        fi

        # Tag and push Docker image
        echo "Tagging and pushing Docker image for $SERVICE..."
        if docker push "$IMAGE_NAME"; then
            echo "Successfully pushed $IMAGE_NAME to Docker Hub."
        else
            echo "Error: Failed to push Docker image for $SERVICE."
            exit 1
        fi
    fi
done

# Logout from Docker Hub
docker logout

echo "All done!"