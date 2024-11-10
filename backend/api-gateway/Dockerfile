# Use an official OpenJDK image as a parent image
FROM openjdk:17-jdk-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the API Gateway JAR file into the container
COPY target/api-gateway.jar api-gateway.jar

# Expose the port for the API Gateway
EXPOSE 8080

# Run the API Gateway JAR file
ENTRYPOINT ["java", "-jar", "api-gateway.jar"]
