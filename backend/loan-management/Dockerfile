FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/loan-management-service.jar loan-management-service.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "loan-management-service.jar"]
