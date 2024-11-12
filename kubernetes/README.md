# FinovaBank Kubernetes Helm Chart

This directory contains Kubernetes resources for deploying the **FinovaBank** services using Helm charts. The Helm chart helps to package and manage the deployment of microservices in a Kubernetes cluster.

## Project Structure

```
.
├── Chart.yaml
├── charts
├── templates
│   ├── _helpers.tpl
│   ├── deployment-api-gateway.yaml
│   ├── deployment-eureka-server.yaml
│   ├── deployment-finovabank-frontend.yaml
│   ├── deployment-notification-service.yaml
│   ├── deployment-loan-management.yaml
│   ├── deployment-compliance.yaml
│   ├── deployment-risk-assessment.yaml
│   ├── deployment-reporting.yaml
│   ├── deployment-savings-goals.yaml
│   ├── service-api-gateway.yaml
│   ├── service-eureka-server.yaml
│   ├── service-finovabank-frontend.yaml
│   ├── service-notification-service.yaml
│   ├── service-loan-management.yaml
│   ├── service-compliance.yaml
│   ├── service-risk-assessment.yaml
│   ├── service-reporting.yaml
│   ├── service-savings-goals.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

## Files Description

- **Chart.yaml**: Defines the metadata for the Helm chart.
- **values.yaml**: Contains default configuration values that can be overridden during deployment.
- **templates**: Contains Kubernetes manifests for deploying and exposing services in the cluster.
    - **Deployment YAML Files**: Deploys each microservice as a Kubernetes Deployment.
    - **Service YAML Files**: Creates services to expose each microservice to the network.
    - **tests/test-connection.yaml**: A test Pod to verify connectivity between services.

## Prerequisites

- Kubernetes cluster (Minikube or a cloud-based Kubernetes provider)
- Helm 3.x or later
- Docker (for building images)

## Usage

### 1. Clone the Repository

```sh
git clone https://github.com/abrar2030/FinovaBank.git
cd FinovaBank/kubernetes
```

### 2. Install Helm Chart

To deploy the FinovaBank application using the Helm chart, run:

```sh
helm install finovabank .
```

This command will deploy all the services defined in the `templates` directory.

### 3. Uninstall the Chart

To uninstall the `finovabank` release, run:

```sh
helm uninstall finovabank
```

This command will remove all resources associated with the FinovaBank deployment.

### 4. Verify the Deployment

After installing the chart, verify that all services are up and running:

```sh
kubectl get pods
kubectl get services
```

You should see all the services such as **eureka-server**, **api-gateway**, **user-service**, **payment-service**, etc., in the running state.

### 5. Test Connectivity

To test the connection between services, use the provided `test-connection.yaml`:

```sh
kubectl apply -f templates/tests/test-connection.yaml
kubectl logs test-connection
```

## Customization

You can customize the configuration values by editing `values.yaml` or passing parameters directly via the command line during installation:

```sh
helm install finovabank . --set replicaCount=2
```

## Notes

- Ensure that the `REACT_APP_API_BASE_URL` in **values.yaml** points to the correct API Gateway URL.
- Adjust resource limits in **values.yaml** based on your cluster capacity.

## License

This project is licensed under the MIT License. See the [LICENSE](../LICENSE) file for more details.
