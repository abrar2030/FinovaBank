FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/transaction-service.jar transaction-service.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "transaction-service.jar"]
