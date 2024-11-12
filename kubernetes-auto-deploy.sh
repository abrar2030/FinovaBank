#!/bin/bash

# Check if a service name is provided
if [ -z "$1" ]; then
  echo "Usage: ./docker-minikube-deploy.sh [service-name]"
  exit 1
fi

SERVICE_NAME=$1
MINIKUBE_PROFILE="minikube"

# Check if Minikube is already running
if ! minikube status --profile=$MINIKUBE_PROFILE | grep -q "Running"; then
  echo "Starting Minikube..."
  minikube start --profile=$MINIKUBE_PROFILE
else
  echo "Minikube is already running. Skipping start."
fi

echo "Using Minikube's Docker environment..."
# Configure shell to use Minikube's Docker daemon
# shellcheck disable=SC2046
eval $(minikube -p $MINIKUBE_PROFILE docker-env)

echo "Building Docker image for $SERVICE_NAME..."
# Set build context to the 'backend' directory and specify the Dockerfile path
docker build -t finovabank-"$SERVICE_NAME" -f backend/"$SERVICE_NAME"/Dockerfile backend/

if [ $? -ne 0 ]; then
  echo "Error building Docker image for $SERVICE_NAME."
  exit 1
fi

echo "Deploying $SERVICE_NAME on Minikube..."
case $SERVICE_NAME in
  eureka-server)
    kubectl apply -f kubernetes/templates/deployment-eureka-server.yaml
    kubectl apply -f kubernetes/templates/service-eureka-server.yaml
    ;;
  api-gateway)
    kubectl apply -f kubernetes/templates/deployment-api-gateway.yaml
    kubectl apply -f kubernetes/templates/service-api-gateway.yaml
    ;;
  account-management)
    kubectl apply -f kubernetes/templates/deployment-account-management.yaml
    kubectl apply -f kubernetes/templates/service-account-management.yaml
    ;;
  transaction)
    kubectl apply -f kubernetes/templates/deployment-transaction.yaml
    kubectl apply -f kubernetes/templates/service-transaction.yaml
    ;;
  notification)
    kubectl apply -f kubernetes/templates/deployment-notification.yaml
    kubectl apply -f kubernetes/templates/service-notification.yaml
    ;;
  user-profile)
    kubectl apply -f kubernetes/templates/deployment-user-profile.yaml
    kubectl apply -f kubernetes/templates/service-user-profile.yaml
    ;;
  finovabank-frontend)
    kubectl apply -f kubernetes/templates/deployment-finovabank-frontend.yaml
    kubectl apply -f kubernetes/templates/service-finovabank-frontend.yaml
    ;;
  *)
    echo "Service not recognized: $SERVICE_NAME"
    exit 1
    ;;
esac

echo "$SERVICE_NAME deployed successfully on Minikube."
