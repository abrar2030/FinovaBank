FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/savings-goals-service.jar savings-goals-service.jar
EXPOSE 8084
ENTRYPOINT ["java", "-jar", "savings-goals-service.jar"]
