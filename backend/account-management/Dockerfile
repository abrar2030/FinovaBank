FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/account-management-service.jar account-management-service.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "account-management-service.jar"]
