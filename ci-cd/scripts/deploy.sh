#!/bin/bash

# Set Docker registry
DOCKER_REGISTRY=your-docker-registry

# Build and push images
docker build -t $DOCKER_REGISTRY/api-gateway:latest -f api-gateway/Dockerfile .
docker push $DOCKER_REGISTRY/api-gateway:latest

docker build -t $DOCKER_REGISTRY/account-service:latest -f account-service/Dockerfile .
docker push $DOCKER_REGISTRY/account-service:latest

docker build -t $DOCKER_REGISTRY/transaction-service:latest -f transaction-service/Dockerfile .
docker push $DOCKER_REGISTRY/transaction-service:latest

docker build -t $DOCKER_REGISTRY/loan-service:latest -f loan-service/Dockerfile .
docker push $DOCKER_REGISTRY/loan-service:latest

docker build -t $DOCKER_REGISTRY/savings-goals-service:latest -f savings-goals-service/Dockerfile .
docker push $DOCKER_REGISTRY/savings-goals-service:latest

docker build -t $DOCKER_REGISTRY/risk-assessment-service:latest -f risk-assessment-service/Dockerfile .
docker push $DOCKER_REGISTRY/risk-assessment-service:latest

docker build -t $DOCKER_REGISTRY/compliance-service:latest -f compliance-service/Dockerfile .
docker push $DOCKER_REGISTRY/compliance-service:latest

docker build -t $DOCKER_REGISTRY/notification-service:latest -f notification-service/Dockerfile .
docker push $DOCKER_REGISTRY/notification-service:latest

docker build -t $DOCKER_REGISTRY/reporting-service:latest -f reporting-service/Dockerfile .
docker push $DOCKER_REGISTRY/reporting-service:latest

# Deploy to Kubernetes
kubectl apply -f infrastructure/kubernetes/namespace.yaml
kubectl apply -f infrastructure/kubernetes/deployment.yaml
kubectl apply -f infrastructure/kubernetes/service.yaml
