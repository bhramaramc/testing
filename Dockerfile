FROM openjdk:8-jre-alpine

WORKDIR /app
COPY build/libs/*.jar /app/app.jar
COPY kube/healthcheck.sh /app

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]