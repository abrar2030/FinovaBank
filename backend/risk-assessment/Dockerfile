FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/risk-assessment-service.jar risk-assessment-service.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "risk-assessment-service.jar"]
