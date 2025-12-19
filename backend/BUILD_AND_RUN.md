# FinovaBank Backend - Quick Start Guide

## Prerequisites

- **Java 17 JDK** (required)
- **Maven 3.6+** (or use included `./mvnw` wrapper)
- **Ports 8001-8011** available

## Quick Start (Development Mode)

### 1. Build All Services

```bash
cd backend
./mvnw clean package -DskipTests
```

### 2. Run Individual Services

Start services in this order:

```bash
# Terminal 1: Eureka Server (Service Registry)
cd eureka-server
../mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Terminal 2: Auth Service
cd auth-service
../mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Terminal 3: API Gateway
cd api-gateway
../mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Terminal 4: Account Management
cd account-management
../mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### 3. Verify Services Are Running

```bash
# Check health endpoints
curl http://localhost:8001/actuator/health  # Eureka
curl http://localhost:8011/actuator/health  # Auth Service
curl http://localhost:8002/actuator/health  # API Gateway
curl http://localhost:8003/actuator/health  # Account Management
```

## Service Ports

| Service              | Port | URL                   |
| -------------------- | ---- | --------------------- |
| Eureka Server        | 8001 | http://localhost:8001 |
| API Gateway          | 8002 | http://localhost:8002 |
| Account Management   | 8003 | http://localhost:8003 |
| Transaction Service  | 8004 | http://localhost:8004 |
| Loan Management      | 8005 | http://localhost:8005 |
| Notification Service | 8006 | http://localhost:8006 |
| Reporting            | 8007 | http://localhost:8007 |
| Savings Goals        | 8008 | http://localhost:8008 |
| Security Service     | 8009 | http://localhost:8009 |
| Auth Service         | 8011 | http://localhost:8011 |

## Development Features

### H2 Database Console

Each service with H2 database has a console available:

- **URL**: http://localhost:{port}/h2-console
- **JDBC URL**: `jdbc:h2:mem:{servicename}db`
- **Username**: `sa`
- **Password**: (leave empty)

Example for Account Management:

- http://localhost:8003/h2-console
- JDBC URL: `jdbc:h2:mem:accountdb`

### Swagger/OpenAPI Documentation

Services with API documentation:

- http://localhost:8003/swagger-ui.html (Account Management)
- http://localhost:8011/swagger-ui.html (Auth Service)

### Eureka Dashboard

View registered services:

- http://localhost:8001/

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
# Edit .env with your settings
```

Key variables:

- `SPRING_PROFILES_ACTIVE=dev` (use dev profile)
- `EUREKA_ENABLED=false` (disable Eureka for standalone dev)
- `JWT_SECRET` (change for production!)

### Profiles

- **dev**: H2 in-memory database, verbose logging
- **prod**: PostgreSQL, optimized logging (requires DB setup)

## Troubleshooting

### Port Already in Use

Change port in `application.yml` or stop conflicting service.

### Cannot Connect to Database

For dev mode, H2 is embedded - no setup needed.
For production, ensure PostgreSQL is running and configured.

### Service Won't Start

1. Check Java version: `java -version` (should be 17)
2. Check logs for specific error
3. Ensure previous build was successful
4. Try: `./mvnw clean install -DskipTests`

### Tests Fail

Skip tests during build:

```bash
./mvnw clean package -DskipTests
```
