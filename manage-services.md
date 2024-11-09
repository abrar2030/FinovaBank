# Usage Scenarios for `manage-services.sh` Script

## 1. Cleaning Services

### Clean a Specific Backend Service (`eureka-server`)
```bash
cd PayNext && ./manage-services.sh clean eureka-server
```

### Clean a Specific Backend Service (`api-gateway`)
```bash
cd PayNext && ./manage-services.sh clean api-gateway
```

### Clean a Specific Backend Service (`user-service`)
```bash
cd PayNext && ./manage-services.sh clean user-service
```

### Clean a Specific Backend Service (`payment-service`)
```bash
cd PayNext && ./manage-services.sh clean payment-service
```

### Clean a Specific Backend Service (`fintech-payment-frontend`)
```bash
cd PayNext && ./manage-services.sh clean fintech-payment-frontend
```

### Clean All Backend and Frontend Services
```bash
cd PayNext && ./manage-services.sh clean all
```

---

## 2. Building Services

### Build a Specific Backend Service (`eureka-server`)
```bash
cd PayNext && ./manage-services.sh build eureka-server
```

### Build a Specific Backend Service (`api-gateway`)
```bash
cd PayNext && ./manage-services.sh build api-gateway
```

### Build a Specific Backend Service (`user-service`)
```bash
cd PayNext && ./manage-services.sh build user-service
```

### Build a Specific Backend Service (`payment-service`)
```bash
cd PayNext && ./manage-services.sh build payment-service
```

### Build a Specific Backend Service (`notification-service`)
```bash
cd PayNext && ./manage-services.sh build notification-service
```

### Build a Specific Frontend Service (`fintech-payment-frontend`)
```bash
cd PayNext && ./manage-services.sh build fintech-payment-frontend
```

### Build All Backend and Frontend Services
```bash
cd PayNext && ./manage-services.sh build all
```

---

## 3. Running Services

### Run a Specific Backend Service (`eureka-server`)
```bash
cd PayNext && ./manage-services.sh run eureka-server
```

### Run a Specific Backend Service (`api-gateway`)
```bash
cd PayNext && ./manage-services.sh run api-gateway
```

### Run a Specific Backend Service (e.g., `user-service`)
```bash
cd PayNext && ./manage-services.sh run user-service
```

### Run a Specific Backend Service (e.g., `payment-service`)
```bash
cd PayNext && ./manage-services.sh run payment-service
```

### Run a Specific Backend Service (`notification-service`)
```bash
cd PayNext && ./manage-services.sh run notification-service
```

### Run a Specific Frontend Service (e.g., `fintech-payment-frontend`)
```bash
cd PayNext && ./manage-services.sh run fintech-payment-frontend
```

### Run All Backend and Frontend Services
```bash
cd PayNext && ./manage-services.sh run all
```

---

## 4. Setting Up All Services

### Perform a Full Setup (Clean, Build, Run) for All Services
```bash
cd PayNext && ./manage-services.sh setup all
```

---

## 5. Cleaning, Building and Running Services

### Clean, Build, and Run the `eureka-server` Backend
```bash
cd PayNext && ./manage-services.sh clean eureka-server
cd PayNext && ./manage-services.sh build eureka-server
cd PayNext && ./manage-services.sh run eureka-server
```

### Clean, Build, and Run the `api-gateway` Backend
```bash
cd PayNext && ./manage-services.sh clean api-gateway
cd PayNext && ./manage-services.sh build api-gateway
cd PayNext && ./manage-services.sh run api-gateway
```

### Clean, Build, and Run the `user-service` Backend
```bash
cd PayNext && ./manage-services.sh clean user-service
cd PayNext && ./manage-services.sh build user-service
cd PayNext && ./manage-services.sh run user-service
```

### Clean, Build, and Run the `payment-service` Backend
```bash
cd PayNext && ./manage-services.sh clean payment-service
cd PayNext && ./manage-services.sh build payment-service
cd PayNext && ./manage-services.sh run payment-service
```

### Clean, Build, and Run the `notification-service` Backend
```bash
cd PayNext && ./manage-services.sh clean notification-service
cd PayNext && ./manage-services.sh build notification-service
cd PayNext && ./manage-services.sh run notification-service
```

### Clean, Build, and Run the `fintech-payment-frontend`
```bash
cd PayNext && ./manage-services.sh clean fintech-payment-frontend
cd PayNext && ./manage-services.sh build fintech-payment-frontend
cd PayNext && ./manage-services.sh run fintech-payment-frontend
```

### Clean, Build, and Run All Services in One Go
```bash
cd PayNext && ./manage-services.sh clean all
cd PayNext && ./manage-services.sh build all
cd PayNext && ./manage-services.sh run all
```

### Setup All Services (Clean, Build, Run) with a Single Command
```bash
cd PayNext && ./manage-services.sh setup all
```

---

## Summary

The `manage-services.sh` script provides a streamlined way to manage your backend and frontend services through various commands. Whether you need to clean, build, run, or set up services individually or collectively, the script offers flexibility to handle your development workflow efficiently.

### Quick Reference

- **Clean Services:** `./manage-services.sh clean <service-name|all>`
- **Build Services:** `./manage-services.sh build <service-name|all>`
- **Run Services:** `./manage-services.sh run <service-name|all>`
- **Setup All Services:** `./manage-services.sh setup all`

Replace `<service-name>` with the specific service you intend to manage, such as `eureka-server`, `fintech-payment-frontend`, `api-gateway`, etc.

---

Feel free to customize this documentation further to fit your project's specific needs!
