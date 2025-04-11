# Use a lightweight base image with OpenJDK
FROM openjdk:17-jdk-alpine

# Copy the built JAR file from the host into the Docker image
COPY target/api-gateway-1.0.0.jar api-gateway.jar

# Expose the API Gateway port
EXPOSE 8002

# Define the entrypoint to run the API Gateway
ENTRYPOINT ["java", "-jar", "api-gateway.jar"]
