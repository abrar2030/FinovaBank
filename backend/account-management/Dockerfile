FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/account-management-1.0.0.jar account-management.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "account-management.jar"]
