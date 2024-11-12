FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/account-management.jar account-management.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "account-management.jar"]
