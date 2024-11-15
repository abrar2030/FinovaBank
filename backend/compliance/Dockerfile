FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/compliance-service-1.0.0.jar compliance-service.jar
EXPOSE 8086
ENTRYPOINT ["java", "-jar", "compliance-service.jar"]
