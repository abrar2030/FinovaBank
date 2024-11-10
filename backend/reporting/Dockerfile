FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/reporting-service.jar reporting-service.jar
EXPOSE 8088
ENTRYPOINT ["java", "-jar", "reporting-service.jar"]
