#!/bin/bash
set -e

GIT_REV=$(git log -n 1 --pretty=format:%h)

echo "Running ./gradlew test sonarqube"
./gradlew -Dsonar.host.url=$SONAR_HOST_URL test jacocoTestReport sonarqube
