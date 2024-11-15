FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/savings-goals-service-1.0.0.jar savings-goals-service.jar
EXPOSE 8084
ENTRYPOINT ["java", "-jar", "savings-goals-service.jar"]
