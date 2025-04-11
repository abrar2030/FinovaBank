#!/bin/bash

# Set Docker registry from environment variable or use default
DOCKER_REGISTRY=${DOCKER_USERNAME:-abrar2030}

# Build and push images
docker buildx build -t $DOCKER_REGISTRY/finovabackend:api-gateway -f backend/api-gateway/Dockerfile backend/api-gateway
docker push $DOCKER_REGISTRY/finovabackend:api-gateway

docker buildx build -t $DOCKER_REGISTRY/finovabackend:account-management -f backend/account-management/Dockerfile backend/account-management
docker push $DOCKER_REGISTRY/finovabackend:account-management

docker buildx build -t $DOCKER_REGISTRY/finovabackend:transaction-service -f backend/transaction-service/Dockerfile backend/transaction-service
docker push $DOCKER_REGISTRY/finovabackend:transaction-service

docker buildx build -t $DOCKER_REGISTRY/finovabackend:loan-management -f backend/loan-management/Dockerfile backend/loan-management
docker push $DOCKER_REGISTRY/finovabackend:loan-management

docker buildx build -t $DOCKER_REGISTRY/finovabackend:savings-goals -f backend/savings-goals/Dockerfile backend/savings-goals
docker push $DOCKER_REGISTRY/finovabackend:savings-goals

docker buildx build -t $DOCKER_REGISTRY/finovabackend:risk-assessment -f backend/risk-assessment/Dockerfile backend/risk-assessment
docker push $DOCKER_REGISTRY/finovabackend:risk-assessment

docker buildx build -t $DOCKER_REGISTRY/finovabackend:compliance -f backend/compliance/Dockerfile backend/compliance
docker push $DOCKER_REGISTRY/finovabackend:compliance

docker buildx build -t $DOCKER_REGISTRY/finovabackend:notification-service -f backend/notification-service/Dockerfile backend/notification-service
docker push $DOCKER_REGISTRY/finovabackend:notification-service

docker buildx build -t $DOCKER_REGISTRY/finovabackend:reporting -f backend/reporting/Dockerfile backend/reporting
docker push $DOCKER_REGISTRY/finovabackend:reporting

docker buildx build -t $DOCKER_REGISTRY/finovabackend:frontend -f frontend/Dockerfile frontend
docker push $DOCKER_REGISTRY/finovabackend:frontend

# Deploy to Kubernetes
kubectl apply -f infrastructure/kubernetes/namespace.yaml
kubectl apply -f infrastructure/kubernetes/deployment.yaml
kubectl apply -f infrastructure/kubernetes/service.yaml
