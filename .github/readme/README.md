# GitHub Workflows for FinovaBank

## Overview

This directory contains the continuous integration and continuous deployment (CI/CD) workflows for the FinovaBank project. These workflows automate the testing, building, and deployment processes, ensuring code quality and reliability throughout the development lifecycle. The automated pipeline helps maintain consistency across environments and reduces manual intervention during the release process, which is particularly important for a financial services platform that requires high reliability, security, and regulatory compliance.

## Workflow Structure

The FinovaBank project implements a modular workflow architecture consisting of three workflow files:

1. **`backend-workflow.yml`**: Handles CI/CD processes for backend services
2. **`frontend-workflow.yml`**: Handles CI/CD processes for frontend applications
3. **`complete-workflow.yml`**: Orchestrates both backend and frontend workflows and adds production deployment verification and notifications

This modular approach allows for independent execution of backend and frontend pipelines when only specific components change, while also providing a comprehensive workflow for full-system deployments. The structure promotes efficiency, maintainability, and clear separation of concerns.

## Backend Workflow

The `backend-workflow.yml` workflow is designed to handle the CI/CD process for the Java-based microservices that make up the FinovaBank backend.

### Trigger Events

The backend workflow is configured to activate on the following Git events:

- **Push Events**: Automatically triggered when code is pushed to the `main` or `develop` branches, but only when changes affect the `backend` directory or the workflow file itself.

- **Pull Request Events**: Automatically triggered when pull requests target the `main` or `develop` branches, but only when changes affect the `backend` directory or the workflow file itself.

This path-filtered approach ensures that the backend workflow only runs when relevant files are modified, improving CI/CD efficiency.

### Jobs

#### Build and Test

The `build-and-test` job runs on an Ubuntu latest environment and performs the following steps:

1. **Checkout Code**: Uses the `actions/checkout@v3` action to fetch the repository code.

2. **Set up JDK 17**: Configures Java Development Kit 17 using the `actions/setup-java@v3` action with Temurin distribution and Maven caching.

3. **Build with Maven**: Builds the backend services using Maven, skipping tests at this stage.

4. **Run Tests**: Executes the test suite for all backend services.

5. **Upload Test Results**: Uploads test results as artifacts, ensuring they are available even if tests fail.

6. **Upload JAR Artifacts**: Uploads compiled JAR files for use in subsequent jobs.

#### Code Quality

The `code-quality` job runs after the `build-and-test` job completes and performs static code analysis:

1. **SonarQube Scan**: Analyzes the code quality using SonarQube, checking for code smells, bugs, vulnerabilities, and test coverage.

This job ensures that all backend code meets the project's quality standards before proceeding with deployment.

#### Docker Build and Push

The `docker-build-and-push` job runs after both `build-and-test` and `code-quality` jobs complete successfully. It is conditionally executed only when:

1. The trigger event is a push (not a pull request)
2. The target branch is either `main` or `develop`

This job performs the following steps:

1. **Set up Docker Buildx**: Configures the Docker build environment.

2. **Login to Docker Registry**: Authenticates with the Docker registry using stored secrets.

3. **Download JAR Artifacts**: Retrieves the compiled JAR files from the `build-and-test` job.

4. **Set Environment Variables**: Determines the appropriate Docker tag based on the target branch.

5. **Build and Push Microservices**: Builds and pushes Docker images for each of the backend microservices:
   - API Gateway
   - Account Management
   - Transaction Service
   - Loan Management
   - Savings Goals
   - Risk Assessment
   - Compliance
   - Notification Service
   - Reporting

#### Deploy

The `deploy` job runs after the `docker-build-and-push` job completes and is conditionally executed only when the target branch is `main`. It performs the following steps:

1. **Set up kubectl**: Configures the Kubernetes command-line tool.

2. **Configure Kubernetes**: Sets up Kubernetes authentication using stored secrets.

3. **Deploy to Kubernetes**: Applies Kubernetes manifests to deploy the backend services and updates the deployments.

## Frontend Workflow

The `frontend-workflow.yml` workflow is designed to handle the CI/CD process for the React-based frontend application of FinovaBank.

### Trigger Events

The frontend workflow is configured to activate on the following Git events:

- **Push Events**: Automatically triggered when code is pushed to the `main` or `develop` branches, but only when changes affect the `frontend` directory or the workflow file itself.

- **Pull Request Events**: Automatically triggered when pull requests target the `main` or `develop` branches, but only when changes affect the `frontend` directory or the workflow file itself.

This path-filtered approach ensures that the frontend workflow only runs when relevant files are modified, improving CI/CD efficiency.

### Jobs

#### Build and Test

The `build-and-test` job runs on an Ubuntu latest environment and performs the following steps:

1. **Checkout Code**: Uses the `actions/checkout@v3` action to fetch the repository code.

2. **Set up Node.js**: Configures Node.js 18 using the `actions/setup-node@v3` action with npm caching.

3. **Install Dependencies**: Installs frontend dependencies using `npm ci` for a clean installation.

4. **Run Linting**: Performs code linting to ensure code style consistency.

5. **Run Tests**: Executes the frontend test suite with coverage reporting.

6. **Upload Test Coverage**: Uploads test coverage reports as artifacts.

7. **Build**: Creates a production build of the frontend application.

8. **Upload Build Artifacts**: Uploads the build artifacts for use in subsequent jobs.

#### Docker Build and Push

The `docker-build-and-push` job runs after the `build-and-test` job completes successfully. It is conditionally executed only when:

1. The trigger event is a push (not a pull request)
2. The target branch is either `main` or `develop`

This job performs the following steps:

1. **Download Build Artifacts**: Retrieves the built frontend assets from the `build-and-test` job.

2. **Set up Docker Buildx**: Configures the Docker build environment.

3. **Login to Docker Registry**: Authenticates with the Docker registry using stored secrets.

4. **Set Environment Variables**: Determines the appropriate Docker tag based on the target branch.

5. **Build and Push Docker Image**: Builds and pushes the frontend Docker image.

#### Deploy

The `deploy` job runs after the `docker-build-and-push` job completes and is conditionally executed only when the target branch is `main`. It performs the following steps:

1. **Set up kubectl**: Configures the Kubernetes command-line tool.

2. **Configure Kubernetes**: Sets up Kubernetes authentication using stored secrets.

3. **Deploy to Kubernetes**: Applies Kubernetes manifests to deploy the frontend application and updates the deployment.

## Complete Workflow

The `complete-workflow.yml` workflow orchestrates both the backend and frontend workflows and adds additional deployment verification and notification steps.

### Trigger Events

The complete workflow is configured to activate on the following Git events:

- **Push Events**: Automatically triggered when code is pushed to the `main` or `develop` branches.

- **Pull Request Events**: Automatically triggered when pull requests target the `main` or `develop` branches.

- **Manual Trigger**: Can be manually triggered using the `workflow_dispatch` event.

This workflow does not use path filtering, as it is designed to run the complete CI/CD pipeline regardless of which components have changed.

### Jobs

#### Backend

The `backend` job uses the reusable workflow defined in `backend-workflow.yml`, passing through all secrets:

```yaml
backend:
  uses: ./.github/workflows/backend-workflow.yml
  secrets: inherit
```

#### Frontend

The `frontend` job uses the reusable workflow defined in `frontend-workflow.yml`, passing through all secrets:

```yaml
frontend:
  uses: ./.github/workflows/frontend-workflow.yml
  secrets: inherit
```

#### Deploy All

The `deploy-all` job runs after both the `backend` and `frontend` jobs complete successfully. It is conditionally executed only when:

1. The trigger event is a push (not a pull request)
2. The target branch is `main`

This job performs the following steps:

1. **Set up kubectl**: Configures the Kubernetes command-line tool.

2. **Configure Kubernetes**: Sets up Kubernetes authentication using stored secrets.

3. **Verify All Deployments**: Checks the status of all deployments and services to ensure they are running correctly.

4. **Send Deployment Notification**: Sends a notification to Slack indicating that the deployment has completed successfully, including details about the version, environment, and the user who triggered the deployment.

## Workflow Configuration Details

### Environment

All jobs in the workflows run on the latest Ubuntu environment (`ubuntu-latest`), which provides a consistent and up-to-date platform for building and testing the application.

### Caching Mechanisms

The workflows implement several caching mechanisms to improve performance:

- **Maven Cache**: The backend workflow uses Maven caching to speed up dependency resolution and build times.
- **npm Cache**: The frontend workflow uses npm caching to speed up dependency installation.

### Conditional Execution

The workflows use conditional execution based on event types and target branches:

- Docker build and push jobs only run on push events to `main` or `develop` branches.
- Deployment jobs only run on push events to the `main` branch.
- The complete workflow's `deploy-all` job only runs on push events to the `main` branch.

These conditions ensure that deployments only occur when code is pushed directly to production branches, not during pull request validation.

### Reusable Workflows

The complete workflow demonstrates the use of reusable workflows, a GitHub Actions feature that allows workflows to be referenced from other workflows:

```yaml
backend:
  uses: ./.github/workflows/backend-workflow.yml
  secrets: inherit
```

This approach promotes code reuse and maintainability by avoiding duplication of workflow definitions.

### Path Filtering

The backend and frontend workflows use path filtering to only trigger when relevant files are changed:

```yaml
on:
  push:
    branches: [main, develop]
    paths:
      - "backend/**"
      - ".github/workflows/backend-workflow.yml"
```

This improves efficiency by avoiding unnecessary workflow runs when unrelated files are modified.

### Artifact Sharing

The workflows use artifacts to share build outputs between jobs:

- The backend workflow uploads JAR files that are later downloaded by the Docker build job.
- The frontend workflow uploads build assets that are later downloaded by the Docker build job.

This ensures that each job can focus on its specific responsibilities while maintaining a clean separation of concerns.

## Extending the Workflow

The current workflow architecture provides a solid foundation for CI/CD but can be extended in several ways to enhance the development and deployment process for the FinovaBank platform:

### Adding Database Migration Jobs

For a financial platform, database schema changes require careful handling. The workflow could be extended with:

- Automated database migration verification in test environments
- Schema validation steps
- Rollback procedures for failed migrations

### Adding Security Scanning

For a financial services platform, security is paramount. The workflow could be extended with:

- SAST (Static Application Security Testing) using tools like Checkmarx or SonarQube Security
- DAST (Dynamic Application Security Testing) using tools like OWASP ZAP
- Container vulnerability scanning using tools like Trivy or Clair
- Dependency vulnerability scanning using tools like Snyk or OWASP Dependency Check
- Secret scanning to prevent accidental exposure of API keys or credentials

### Adding Compliance Checks

Financial services are heavily regulated. The workflow could be extended with:

- Compliance validation for PCI-DSS, SOX, GDPR, or other relevant regulations
- Audit logging verification
- Data privacy compliance checks

### Adding Performance Testing

Performance is critical for financial applications. The workflow could be extended with:

- Load testing using tools like JMeter or k6
- Performance regression testing
- Database query performance analysis

### Adding Blue-Green or Canary Deployments

To minimize downtime and risk, the workflow could be extended with:

- Blue-green deployment strategy
- Canary releases with gradual traffic shifting
- Automated rollback based on error rates or performance metrics

## Best Practices for Working with These Workflows

When working with the FinovaBank CI/CD workflows, consider the following best practices:

1. **Test Locally Before Pushing**: Run tests locally before pushing to avoid unnecessary workflow runs and get faster feedback on issues.

2. **Keep Dependencies Updated**: Regularly update dependencies to ensure security and compatibility, which is particularly important for financial applications.

3. **Monitor Workflow Runs**: Regularly check workflow runs to identify and address any issues promptly. Set up notifications for workflow failures.

4. **Document Changes**: When modifying the workflows, document the changes and their purpose to maintain institutional knowledge.

5. **Use Secrets for Sensitive Data**: Store sensitive information like API keys, database credentials, and service tokens as GitHub secrets.

6. **Implement Branch Protection**: Configure branch protection rules for main branches to require passing CI checks before merging.

7. **Review Deployment Logs**: After deployment, review logs to ensure all components were deployed correctly and are functioning as expected.

8. **Maintain Workflow Modularity**: When adding new services or components, consider whether they should be part of existing workflows or warrant new workflow files.

9. **Test Workflow Changes**: When modifying workflows, test changes in a branch before merging to main to avoid disrupting the CI/CD pipeline.

10. **Keep Secrets Updated**: Regularly rotate secrets used in the workflows and ensure they are properly scoped.

## Troubleshooting

If you encounter issues with the workflows, consider the following troubleshooting steps:

1. **Check Workflow Logs**: Examine the detailed logs for each job to identify specific errors.

2. **Verify Dependencies**: Ensure all required dependencies are correctly specified in the respective requirements files.

3. **Check Environment Variables**: Verify that any required environment variables are properly set in the GitHub repository settings.

4. **Test Steps Locally**: Try to reproduce the failing steps locally to identify environment-specific issues.

5. **Review Recent Changes**: Check recent code changes that might have introduced incompatibilities.

6. **Validate Configuration Files**: Ensure that all configuration files referenced by the workflows exist and are correctly formatted.

7. **Check Resource Constraints**: Verify that the workflow is not failing due to resource constraints (memory, disk space) in the GitHub Actions environment.

8. **Inspect Test Failures**: For test failures, carefully review the test output to understand which tests are failing and why.

9. **Check Docker Registry Access**: Ensure that Docker registry credentials are valid and have the necessary permissions.

10. **Verify Kubernetes Configuration**: Ensure that the Kubernetes configuration is correct and that the service account has the necessary permissions.

## Conclusion

The GitHub workflow configuration for FinovaBank provides a robust, modular CI/CD pipeline that ensures code quality and simplifies the deployment process. By automating testing and deployment, the workflows help maintain a consistent and reliable application across all environments. This automation is particularly valuable for a financial services platform where reliability, security, and compliance are paramount.

The workflow's modular structure allows for independent execution of backend and frontend pipelines when only specific components change, while also providing a comprehensive workflow for full-system deployments. This approach promotes efficiency, maintainability, and clear separation of concerns, making it easier to extend and adapt the CI/CD process as the FinovaBank platform evolves.
