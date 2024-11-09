#!/bin/bash

# Check if a service name is provided
if [ -z "$1" ]; then
  echo "Usage: ./docker-minikube-deploy.sh [service-name]"
  exit 1
fi

SERVICE_NAME=$1
MINIKUBE_PROFILE="minikube"

echo "Starting Minikube..."
minikube start --profile=$MINIKUBE_PROFILE

echo "Using Minikube's Docker environment..."
# Configure shell to use Minikube's Docker daemon
# shellcheck disable=SC2046
eval $(minikube -p $MINIKUBE_PROFILE docker-env)

echo "Building Docker image for $SERVICE_NAME..."
# Set build context to the 'backend' directory and specify the Dockerfile path
docker build -t fintech-"$SERVICE_NAME" -f backend/"$SERVICE_NAME"/Dockerfile backend/

if [ $? -ne 0 ]; then
  echo "Error building Docker image for $SERVICE_NAME."
  exit 1
fi

echo "Deploying $SERVICE_NAME on Minikube..."
case $SERVICE_NAME in
  eureka-server)
    kubectl apply -f paynext-chart/templates/deployment-eureka-server.yaml
    kubectl apply -f paynext-chart/templates/service-eureka-server.yaml
    ;;
  api-gateway)
    kubectl apply -f paynext-chart/templates/deployment-api-gateway.yaml
    kubectl apply -f paynext-chart/templates/service-api-gateway.yaml
    ;;
  user-service)
    kubectl apply -f paynext-chart/templates/deployment-user-service.yaml
    kubectl apply -f paynext-chart/templates/service-user-service.yaml
    ;;
  payment-service)
    kubectl apply -f paynext-chart/templates/deployment-payment-service.yaml
    kubectl apply -f paynext-chart/templates/service-payment-service.yaml
    ;;
  notification-service)
    kubectl apply -f paynext-chart/templates/deployment-notification-service.yaml
    kubectl apply -f paynext-chart/templates/service-notification-service.yaml
    ;;
  fintech-payment-frontend)
    kubectl apply -f paynext-chart/templates/deployment-fintech-payment-frontend.yaml
    kubectl apply -f paynext-chart/templates/service-fintech-payment-frontend.yaml
    ;;
  *)
    echo "Service not recognized: $SERVICE_NAME"
    exit 1
    ;;
esac

echo "$SERVICE_NAME deployed successfully on Minikube."
