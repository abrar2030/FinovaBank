# Docker and Kubernetes Commands for FinovaBank Services

This guide provides commands to build, tag, push Docker images, and deploy Kubernetes resources for each service in the **FinovaBank** project.

## Prerequisites

- **Docker**: For creating images.
- **Docker Hub Account**: To push images.
- **Git**: To clone the repository.
- **Kubernetes & kubectl**: To deploy services to a Kubernetes cluster.
- **Repository Access**: Login to Docker Hub with `docker login`.

---

## Docker Commands for Each Service

### Eureka Server
```bash
docker build -t eureka-server ./backend/eureka-server
docker tag eureka-server abrar2030/backend:eureka-server
docker push abrar2030/backend:eureka-server
kubectl apply -f kubernetes/templates/deployment-eureka-server.yaml -f kubernetes/templates/service-eureka-server.yaml
```

### API Gateway
```bash
docker build -t api-gateway ./backend/api-gateway
docker tag api-gateway abrar2030/backend:api-gateway
docker push abrar2030/backend:api-gateway
kubectl apply -f kubernetes/templates/deployment-api-gateway.yaml -f kubernetes/templates/service-api-gateway.yaml
```

### User Service
```bash
docker build -t user-service ./backend/user-service
docker tag user-service abrar2030/backend:user-service
docker push abrar2030/backend:user-service
kubectl apply -f kubernetes/templates/deployment-user-service.yaml -f kubernetes/templates/service-user-service.yaml
```

### Payment Service
```bash
docker build -t payment-service ./backend/payment-service
docker tag payment-service abrar2030/backend:payment-service
docker push abrar2030/backend:payment-service
kubectl apply -f kubernetes/templates/deployment-payment-service.yaml -f kubernetes/templates/service-payment-service.yaml
```

### Notification Service
```bash
docker build -t notification-service ./backend/notification-service
docker tag notification-service abrar2030/backend:notification-service
docker push abrar2030/backend:notification-service
kubectl apply -f kubernetes/templates/deployment-notification-service.yaml -f kubernetes/templates/service-notification-service.yaml
```

### Fintech Payment Frontend
```bash
docker build -t finovabank-frontend ./frontend/finovabank-frontend
docker tag finovabank-frontend abrar2030/frontend:finovabank-frontend
docker push abrar2030/frontend:finovabank-frontend
kubectl apply -f kubernetes/templates/deployment-finovabank-frontend.yaml -f kubernetes/templates/service-finovabank-frontend.yaml
```

---

## Notes

- **Login to Docker Hub**: Run `docker login` before pushing images.
- **Tag Format**: Images are tagged as `abrar2030/backend:service-name` or `abrar2030/frontend:service-name`.
- **Build Context**: The build context (`./backend/service-name`) specifies the Dockerfile location.

## Summary

Follow these commands to build, tag, and push Docker images for the **FinovaBank** services and deploy them to Kubernetes, facilitating easy deployment via Docker Hub and Kubernetes.
