# Backend Services

The backend directory contains the core microservices architecture that powers the FinovaBank application. This comprehensive financial solution is built using Spring Boot and follows a microservices design pattern to ensure scalability, maintainability, and resilience.

## Architecture Overview

The backend is structured as a collection of independent microservices, each responsible for a specific domain of the banking application. These services communicate with each other through RESTful APIs and message queues, allowing for loose coupling and independent deployment. The architecture follows industry best practices for microservices, including service discovery, API gateway pattern, and centralized configuration.

The parent project uses Maven as the build tool, with a multi-module structure that allows for both independent and collective building of services. Spring Boot serves as the foundation framework, providing robust capabilities for creating production-ready applications with minimal configuration.

## Key Components

The backend consists of several critical microservices:

Account Management handles all aspects of customer accounts, including creation, updates, and retrieval of account information. It maintains the core banking account data and provides APIs for account operations.

API Gateway serves as the single entry point for all client requests, routing them to appropriate microservices. It handles cross-cutting concerns like authentication, logging, and request transformation.

Auth Service manages user authentication and authorization, implementing OAuth2 and JWT for secure access control. It integrates with the security infrastructure to ensure proper access management.

Compliance service ensures that all banking operations adhere to regulatory requirements and internal policies, monitoring transactions and operations for compliance issues.

Eureka Server provides service discovery capabilities, allowing microservices to locate and communicate with each other without hardcoded endpoints.

Loan Management handles all aspects of loan processing, from application to approval, disbursement, and repayment tracking.

Notification Service manages all customer communications, including email, SMS, and push notifications for account activities, alerts, and marketing messages.

Reporting generates financial and operational reports for both customers and internal use, processing data from various services to create comprehensive insights.

Risk Assessment evaluates customer and transaction risk levels, applying algorithms and rules to detect potential fraud or high-risk activities.

Savings Goals helps customers set and track financial goals, integrating with account management to monitor progress and automate savings.

Security Service implements additional security measures beyond basic authentication, including fraud detection, unusual activity monitoring, and security policy enforcement.

Transaction Service processes all financial transactions, ensuring atomicity, consistency, isolation, and durability (ACID properties) for banking operations.

## Development Workflow

The backend includes several utility scripts to simplify development and deployment:

- `build-all.sh` compiles all microservices and runs unit tests
- `run-all.sh` launches all services in the correct order with proper configuration

Each microservice follows a standard structure with controllers, services, repositories, and models organized according to Spring Boot conventions. The codebase adheres to clean code principles and includes comprehensive test coverage at unit, integration, and system levels.

## Getting Started

To work with the backend services, ensure you have:

1. JDK 11 or higher installed
2. Maven 3.6+ configured
3. Docker and Docker Compose for containerized development
4. Access to the required databases (PostgreSQL and MongoDB)

The backend services can be run individually for focused development or collectively using the provided scripts. Configuration is externalized through Spring Cloud Config, allowing for environment-specific settings without code changes.

## Integration Points

The backend services integrate with:

- Database layer for persistent storage
- Frontend applications (web and mobile) through the API Gateway
- External services through secure API connections
- Monitoring and logging infrastructure for operational visibility
- CI/CD pipeline for automated testing and deployment

This modular architecture allows for independent scaling, deployment, and maintenance of each component while ensuring the overall system remains cohesive and reliable.
