# FinovaBank Continuous Integration / Continuous Deployment (CI/CD)

This directory contains the CI/CD configuration for the FinovaBank microservices architecture. The setup has been refactored to be more modular, maintainable, and to eliminate redundant files.

## Directory Structure

```
.
├── README.md
├── jenkins/
│   └── Jenkinsfile           # Consolidated, modular CI/CD pipeline
└── scripts/
    └── deploy.sh             # Refactored script for local build/push and Helm deployment
```

## Usage

### 1. Jenkins Pipeline (`jenkins/Jenkinsfile`)

This pipeline is designed to be triggered on a Git push and performs the following stages:

| Stage | Description | Notes |
| :--- | :--- | :--- |
| `Checkout` | Clones the repository. | |
| `Build & Test` | Runs backend (Maven) and frontend (npm) build and unit tests in parallel. | Includes JUnit and test coverage reporting. |
| `Code Quality (SonarQube)` | Runs SonarQube analysis on the backend code. | Requires `SONARQUBE_TOKEN` and `SONARQUBE_URL` credentials. |
| `Docker Build & Push` | Builds and pushes Docker images for all microservices and the frontend. | Uses a loop for all services to prevent duplication. Tags images with build number and `latest` (on `main` branch). |
| `Deploy to Kubernetes` | Deploys the application using the refactored Helm chart. | Only runs on the `main` branch. Requires `KUBE_CONFIG` credential. |
| `Integration & Smoke Tests` | Placeholder for post-deployment testing. | Only runs on the `main` branch. |

**Required Jenkins Credentials:**

*   `docker-registry-url`: URL of the Docker registry (e.g., `docker.io`).
*   `docker-credentials`: Username and password for the Docker registry.
*   `sonarqube-token`: SonarQube authentication token.
*   `sonarqube-url`: SonarQube server URL.
*   `kubernetes-config`: Kubernetes configuration file content for `kubectl` access.

### 2. Deployment Script (`scripts/deploy.sh`)

This script is intended for local or manual CI/CD use. It automates the process of building, tagging, pushing Docker images, and deploying the application using the Helm chart.

**Usage:**

```bash
# Ensure you are in the root of the FinovaBank repository
./ci-cd/scripts/deploy.sh
```

**Prerequisites:**

*   Docker and `docker buildx` installed.
*   `helm` and `kubectl` configured to point to the target Kubernetes cluster.
*   The script assumes you have logged into your Docker registry prior to execution.

