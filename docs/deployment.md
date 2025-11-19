# FinovaBank Deployment Documentation

## Overview
This document provides detailed instructions for deploying the FinovaBank platform. The deployment is containerized, orchestrated using Kubernetes, and includes configurations for high availability, monitoring, and logging. It covers deployment steps from local development to cloud environments, including Docker, Kubernetes, Helm, and CI/CD integrations.

## Prerequisites

### Software Requirements
- **Docker**: Containerize microservices for consistent deployment.
- **Kubernetes**: Manage container orchestration.
- **Helm**: Package manager for Kubernetes to simplify deployments.
- **kubectl**: Command-line tool for interacting with Kubernetes clusters.
- **Terraform**: Infrastructure as Code (IaC) tool to manage cloud infrastructure.
- **Jenkins/GitHub Actions**: CI/CD tools for automated builds and deployments.

### Cloud Providers
- **AWS**: Used for cloud hosting, with resources such as EC2 instances, RDS for PostgreSQL, and S3 for storage.
- **IAM Credentials**: Access to AWS IAM for creating resources.

## Deployment Steps

### 1. Local Development Environment Setup

#### Step 1.1: Clone Repository
```sh
$ git clone https://github.com/abrar2030/FinovaBank.git
$ cd finovabank
```

#### Step 1.2: docker buildx build
Build Docker images for each microservice.
```sh
$ docker buildx build -t finova/api-gateway:latest -f api-gateway/Dockerfile .
$ docker buildx build -t finova/account-service:latest -f account-service/Dockerfile .
$ docker buildx build -t finova/transaction-service:latest -f transaction-service/Dockerfile .
...
```

#### Step 1.3: Docker Compose
Start the entire environment locally for testing.
```sh
$ docker-compose -f docker-compose.yml up -d
```
This will spin up all services, databases, and other dependencies.

### 2. Kubernetes Deployment

#### Step 2.1: Create Kubernetes Namespace
```sh
$ kubectl apply -f infrastructure/kubernetes/namespace.yaml
```

#### Step 2.2: Deploy Configurations
Deploy Config Server, Eureka Server, and each microservice as follows:
```sh
$ kubectl apply -f infrastructure/kubernetes/deployment.yaml
$ kubectl apply -f infrastructure/kubernetes/service.yaml
```

### 3. Helm Chart Deployment

#### Step 3.1: Install Helm
Ensure that Helm is installed on your local machine.
```sh
$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

#### Step 3.2: Package and Deploy Helm Charts
Each service is configured with Helm charts to facilitate Kubernetes deployment.
```sh
$ helm package helm/finova
$ helm install finova ./finova-0.1.0.tgz -n finova-namespace
```

### 4. Database Setup

#### Step 4.1: PostgreSQL and MongoDB Setup
The databases are deployed as stateful Kubernetes services.
```sh
$ kubectl apply -f infrastructure/kubernetes/postgres-statefulset.yaml
$ kubectl apply -f infrastructure/kubernetes/mongo-statefulset.yaml
```
Ensure the required secrets are stored in Kubernetes for accessing the databases.
```sh
$ kubectl create secret generic db-credentials --from-literal=username=postgres --from-literal=password=password -n finova-namespace
```

### 5. Cloud Deployment (AWS)

#### Step 5.1: Terraform Setup
Use **Terraform** scripts to provision AWS infrastructure.

- Initialize Terraform and plan infrastructure.
```sh
$ cd infrastructure/terraform
$ terraform init
$ terraform plan
```

- Apply the configuration to create VPC, subnets, security groups, and EC2 instances.
```sh
$ terraform apply
```

#### Step 5.2: Deploy to Kubernetes Cluster
- Deploy resources using **AWS EKS**.
```sh
$ aws eks update-kubeconfig --name finova-cluster
$ kubectl apply -f infrastructure/kubernetes/
```

### 6. CI/CD Pipeline

#### Step 6.1: Jenkins Setup
- Use the **Jenkinsfile** in the `ci-cd/jenkins/` directory to create a pipeline.
- **Pipeline Stages**:
    1. **Build**: Compile and create Docker images.
    2. **Test**: Run unit and integration tests.
    3. **Push**: Push Docker images to container registry.
    4. **Deploy**: Deploy services to Kubernetes cluster.

```sh
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build and Test') {
            steps {
                sh 'mvn clean install'
            }
        }
        stage('docker buildx build') {
            steps {
                sh 'docker buildx build -t finova/account-service:latest .'
            }
        }
        stage('Push to Registry') {
            steps {
                sh 'docker push finova/account-service:latest'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f infrastructure/kubernetes/deployment.yaml'
            }
        }
    }
}
```

#### Step 6.2: GitHub Actions
Use GitHub Actions for automatic builds and deployments whenever code is pushed to the `main` branch.
- Workflow is configured in `.github/workflows/build.yml`.

### 7. Monitoring and Logging Setup

#### Step 7.1: Prometheus and Grafana
- **Prometheus**: Deployed to scrape metrics from Kubernetes pods.
- **Grafana**: Deployed to visualize the collected metrics.
```sh
$ kubectl apply -f monitoring/prometheus/prometheus.yml
$ kubectl apply -f monitoring/grafana/datasource.yml
```

#### Step 7.2: ELK Stack for Logs
- Deploy **Elasticsearch**, **Logstash**, and **Kibana** for log aggregation and visualization.
```sh
$ kubectl apply -f monitoring/elk-stack/elasticsearch-deployment.yaml
$ kubectl apply -f monitoring/elk-stack/kibana-deployment.yaml
$ kubectl apply -f monitoring/elk-stack/logstash-deployment.yaml
```

### 8. Rollback and Disaster Recovery

#### Step 8.1: Rollback
If any deployment fails or a rollback is required, the following command can be used to revert to a previous release:
```sh
$ helm rollback finova <REVISION>
```

#### Step 8.2: Database Backups
- Automated backups for **PostgreSQL** and **MongoDB** are configured using cron jobs.
- Backups are stored in **AWS S3** for redundancy.

```sh
$ kubectl apply -f infrastructure/kubernetes/db-backup-cronjob.yaml
```

### 9. Scaling and High Availability

#### Step 9.1: Horizontal Pod Autoscaler (HPA)
Deploy **HPA** to scale the microservices based on CPU and memory usage.
```sh
$ kubectl autoscale deployment account-service --cpu-percent=50 --min=2 --max=10
```

#### Step 9.2: Load Balancer
**AWS Application Load Balancer (ALB)** is used to distribute traffic across instances, ensuring high availability.

### 10. Secrets Management

#### Step 10.1: HashiCorp Vault Integration
- Secrets for database credentials and API keys are managed with **HashiCorp Vault**.
- Vault agent injector is used to inject secrets into Kubernetes pods.
```sh
$ vault kv put secret/finova/db username=postgres password=password
```

### 11. Post-Deployment Validation

#### Step 11.1: Health Checks
Verify the health of all services:
```sh
$ kubectl get pods -n finova-namespace
$ kubectl describe service finova-service
```

#### Step 11.2: End-to-End Testing
Run end-to-end tests to validate that all services are functioning as expected:
```sh
$ mvn verify -f e2e-tests/pom.xml
```

---

This completes the deployment documentation for the FinovaBank platform. For any issues or questions, please reach out to the deployment team.
