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
docker build -t finovabank-"$SERVICE_NAME" -f backend/"$SERVICE_NAME"/Dockerfile backend/

if [ $? -ne 0 ]; then
  echo "Error building Docker image for $SERVICE_NAME."
  exit 1
fi

echo "Deploying $SERVICE_NAME on Minikube..."
case $SERVICE_NAME in
  eureka-server)
    kubectl apply -f finovabank-chart/templates/deployment-eureka-server.yaml
    kubectl apply -f finovabank-chart/templates/service-eureka-server.yaml
    ;;
  api-gateway)
    kubectl apply -f finovabank-chart/templates/deployment-api-gateway.yaml
    kubectl apply -f finovabank-chart/templates/service-api-gateway.yaml
    ;;
  account-management)
    kubectl apply -f finovabank-chart/templates/deployment-account-management.yaml
    kubectl apply -f finovabank-chart/templates/service-account-management.yaml
    ;;
  transaction)
    kubectl apply -f finovabank-chart/templates/deployment-transaction.yaml
    kubectl apply -f finovabank-chart/templates/service-transaction.yaml
    ;;
  notification)
    kubectl apply -f finovabank-chart/templates/deployment-notification.yaml
    kubectl apply -f finovabank-chart/templates/service-notification.yaml
    ;;
  user-profile)
    kubectl apply -f finovabank-chart/templates/deployment-user-profile.yaml
    kubectl apply -f finovabank-chart/templates/service-user-profile.yaml
    ;;
  finovabank-frontend)
    kubectl apply -f finovabank-chart/templates/deployment-finovabank-frontend.yaml
    kubectl apply -f finovabank-chart/templates/service-finovabank-frontend.yaml
    ;;
  *)
    echo "Service not recognized: $SERVICE_NAME"
    exit 1
    ;;
esac

echo "$SERVICE_NAME deployed successfully on Minikube."
