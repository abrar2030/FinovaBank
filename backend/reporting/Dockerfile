FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/reporting-service-1.0.0.jar reporting-service.jar
EXPOSE 8088
ENTRYPOINT ["java", "-jar", "reporting-service.jar"]
