# Minikube Deployment Script

## Overview

This script is designed to automate the process of building Docker images and deploying services on Minikube. It checks if Minikube is running, builds a Docker image for the specified service, and deploys the corresponding Kubernetes resources.

## Usage

```bash
./kubernetes-auto-deploy.sh [service-name]
```

- `[service-name]`: The name of the service to build and deploy. This is a required argument.

## Prerequisites

- Minikube should be installed and set up on your system.
- Docker should be installed and properly configured.
- Kubernetes `kubectl` command-line tool should be available.
- Ensure that you have the proper directory structure for Dockerfiles and Kubernetes templates.

## Script Workflow

1. **Service Name Check**
   - The script first checks if a service name is provided as an argument.
   - If no service name is provided, it outputs the usage and exits.

2. **Minikube Status Check**
   - The script checks if Minikube is already running with the specified profile (`minikube` by default).
   - If Minikube is not running, it starts Minikube.
   - If Minikube is already running, it skips starting it.

3. **Configure Docker Environment**
   - The script configures the shell to use Minikube's Docker daemon using the `docker-env` command.

4. **Build Docker Image**
   - The script builds the Docker image for the specified service.
   - The build context is set to the `backend` directory, and the Dockerfile path is specified based on the service name.

5. **Deploy Service on Minikube**
   - Depending on the service name, the script deploys the appropriate Kubernetes resources (Deployment and Service) using `kubectl apply`.
   - If the service name is not recognized, the script exits with an error.

## Supported Services

The script supports deploying the following services:

- `eureka-server`
- `api-gateway`
- `account-management`
- `transaction`
- `notification`
- `user-profile`
- `frontend`

Each service has corresponding Kubernetes deployment and service YAML files located in the `kubernetes/templates/` directory.

## Example Usage

To deploy the `api-gateway` service:

```bash
./kubernetes-auto-deploy.sh api-gateway
```

## Error Handling

- If the Docker image build fails, the script will output an error message and exit.
- If the service name is not recognized, the script will output an error message and exit.

## Directory Structure

The script assumes the following directory structure:

```
project-root/
  ├── backend/
  │     ├── [service-name]/
  │     │       └── Dockerfile
  ├── kubernetes/
  │     └── templates/
  │           ├── deployment-[service-name].yaml
  │           └── service-[service-name].yaml
```

## Notes

- Ensure Minikube has enough resources (CPU, Memory) allocated to handle the deployment of multiple services.
- Minikube must be running before using the Docker environment for building images.
- The script uses the default Minikube profile (`minikube`). If you have a different profile, modify the `MINIKUBE_PROFILE` variable accordingly.

## Common Issues

- **Minikube Not Starting**: If Minikube fails to start, make sure virtualization is enabled on your system and that you have sufficient resources allocated.
- **docker buildx build Errors**: Verify that the Dockerfile exists in the specified path and that all necessary dependencies are available.
- **Kubernetes Deployment Errors**: Check that the YAML files for deployments and services are correctly defined and that the Kubernetes cluster has sufficient resources.

## License

This script is open-source and can be modified as needed. Please ensure you have the necessary permissions to deploy the services.

## Author

This script was created to simplify the deployment of microservices on a Minikube Kubernetes cluster.
