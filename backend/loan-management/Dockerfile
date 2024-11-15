FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/loan-management-service-1.0.0.jar loan-management-service.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "loan-management-service.jar"]
