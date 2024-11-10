FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/notification-service.jar notification-service.jar
EXPOSE 8087
ENTRYPOINT ["java", "-jar", "notification-service.jar"]
