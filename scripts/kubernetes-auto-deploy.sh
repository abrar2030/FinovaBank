#!/bin/bash

# Check if a service name is provided
if [ -z "$1" ]; then
  echo "Usage: ./docker-minikube-deploy.sh [service-name|all]"
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

build_java_project() {
  local svc=$1
  echo "Building Java project for $svc..."
  cd backend/"$svc" || { echo "Directory backend/$svc not found."; exit 1; }

  if [ -f "pom.xml" ]; then
    mvn clean package
  elif [ -f "build.gradle" ]; then
    ./gradlew build
  else
    echo "No recognized build file found for $svc."
    exit 1
  fi

  cd ../../
}

deploy_service() {
  local svc=$1
  build_java_project "$svc"

  echo "Building Docker image for $svc..."
  docker buildx build -t finovabackend-"$svc" -f backend/"$svc"/Dockerfile backend/"$svc"/

  if [ $? -ne 0 ]; then
    echo "Error building Docker image for $svc."
    exit 1
  fi

  echo "Deploying $svc on Minikube..."
  kubectl apply -f kubernetes/templates/deployment-"$svc".yaml
  kubectl apply -f kubernetes/templates/service-"$svc".yaml

  if [ $? -ne 0 ]; then
    echo "Error deploying $svc."
    exit 1
  fi

  echo "$svc deployed successfully on Minikube."
}

echo "Deploying $SERVICE_NAME on Minikube..."
case $SERVICE_NAME in
  eureka-server)
    deploy_service "eureka-server"
    ;;
  api-gateway)
    deploy_service "api-gateway"
    ;;
  account-management)
    deploy_service "account-management"
    ;;
  transaction-service)
    deploy_service "transaction-service"
    ;;
  notification-service)
    deploy_service "notification-service"
    ;;
  loan-management)
    deploy_service "loan-management"
    ;;
  compliance-service)
    deploy_service "compliance-service"
    ;;
  reporting-service)
    deploy_service "reporting-service"
    ;;
  risk-assessment-service)
    deploy_service "risk-assessment-service"
    ;;
  savings-goals-service)
    deploy_service "savings-goals-service"
    ;;
  frontend)
    deploy_service "frontend"
    ;;
  all)
    services=(
      "eureka-server"
      "api-gateway"
      "account-management"
      "transaction-service"
      "notification-service"
      "loan-management"
      "compliance-service"
      "reporting-service"
      "risk-assessment-service"
      "savings-goals-service"
      "frontend"
    )
    for svc in "${services[@]}"; do
      deploy_service "$svc"
    done
    ;;
  *)
    echo "Service not recognized: $SERVICE_NAME"
    exit 1
    ;;
esac
