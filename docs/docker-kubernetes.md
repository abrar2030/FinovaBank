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
docker buildx build -t eureka-server ./backend/eureka-server
docker tag eureka-server abrar2030/backend:eureka-server
docker push abrar2030/backend:eureka-server
kubectl apply -f kubernetes/templates/deployment-eureka-server.yaml -f kubernetes/templates/service-eureka-server.yaml
```

### API Gateway

```bash
docker buildx build -t api-gateway ./backend/api-gateway
docker tag api-gateway abrar2030/backend:api-gateway
docker push abrar2030/backend:api-gateway
kubectl apply -f kubernetes/templates/deployment-api-gateway.yaml -f kubernetes/templates/service-api-gateway.yaml
```

### Account Management

```bash
docker buildx build -t account-management ./backend/account-management
docker tag account-management abrar2030/backend:account-management
docker push abrar2030/backend:account-management
kubectl apply -f kubernetes/templates/deployment-account-management.yaml -f kubernetes/templates/service-account-management.yaml
```

### Compliance Service

```bash
docker buildx build -t compliance ./backend/compliance
docker tag compliance abrar2030/backend:compliance
docker push abrar2030/backend:compliance
kubectl apply -f kubernetes/templates/deployment-compliance.yaml -f kubernetes/templates/service-compliance.yaml
```

### Loan Management

```bash
docker buildx build -t loan-management ./backend/loan-management
docker tag loan-management abrar2030/backend:loan-management
docker push abrar2030/backend:loan-management
kubectl apply -f kubernetes/templates/deployment-loan-management.yaml -f kubernetes/templates/service-loan-management.yaml
```

### Notification Service

```bash
docker buildx build -t notification-service ./backend/notification-service
docker tag notification-service abrar2030/backend:notification-service
docker push abrar2030/backend:notification-service
kubectl apply -f kubernetes/templates/deployment-notification-service.yaml -f kubernetes/templates/service-notification-service.yaml
```

### Reporting Service

```bash
docker buildx build -t reporting ./backend/reporting
docker tag reporting abrar2030/backend:reporting
docker push abrar2030/backend:reporting
kubectl apply -f kubernetes/templates/deployment-reporting.yaml -f kubernetes/templates/service-reporting.yaml
```

### Risk Assessment

```bash
docker buildx build -t risk-assessment ./backend/risk-assessment
docker tag risk-assessment abrar2030/backend:risk-assessment
docker push abrar2030/backend:risk-assessment
kubectl apply -f kubernetes/templates/deployment-risk-assessment.yaml -f kubernetes/templates/service-risk-assessment.yaml
```

### Savings Goals

```bash
docker buildx build -t savings-goals ./backend/savings-goals
docker tag savings-goals abrar2030/backend:savings-goals
docker push abrar2030/backend:savings-goals
kubectl apply -f kubernetes/templates/deployment-savings-goals.yaml -f kubernetes/templates/service-savings-goals.yaml
```

### Transaction Service

```bash
docker buildx build -t transaction-service ./backend/transaction-service
docker tag transaction-service abrar2030/backend:transaction-service
docker push abrar2030/backend:transaction-service
kubectl apply -f kubernetes/templates/deployment-transaction-service.yaml -f kubernetes/templates/service-transaction-service.yaml
```

---

## Notes

- **Login to Docker Hub**: Run `docker login` before pushing images.
- **Tag Format**: Images are tagged as `abrar2030/backend:service-name`.
- **Build Context**: The build context (`./backend/service-name`) specifies the Dockerfile location.

## Summary

Follow these commands to build, tag, and push Docker images for the **FinovaBank** services and deploy them to Kubernetes, facilitating easy deployment via Docker Hub and Kubernetes.
