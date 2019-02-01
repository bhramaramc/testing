#!/bin/bash
set -e

GIT_REV=$(git log -n 1 --pretty=format:%h)

echo "Building FAT JAR..."
# ./gradlew build upload
./gradlew build

LOCAL_IMAGE=$APP_IMAGE_NAME:$GIT_REV
REMOTE_IMAGE=$IMAGE_REGISTRY/$APP_IMAGE_NAME:$GIT_REV
REMOTE_IMAGE_LATEST=$IMAGE_REGISTRY/$APP_IMAGE_NAME:latest

echo "Creating local image $LOCAL_IMAGE ..."
docker build -t $LOCAL_IMAGE .

echo "[BRANCH]: $BUILDKITE_BRANCH"

if [[ $BUILDKITE_BRANCH = master ]] || [[ $BUILDKITE_BRANCH = release/* ]]
then
	echo "gcloud configure docker"
	gcloud auth configure-docker --quiet

	echo "TAG/PUSH GIT HASH IMAGE $REMOTE_IMAGE ..."
	docker tag $LOCAL_IMAGE $REMOTE_IMAGE
	docker push $REMOTE_IMAGE

	echo "TAG/PUSH LATEST $REMOTE_IMAGE_LATEST"
	docker tag $LOCAL_IMAGE $REMOTE_IMAGE_LATEST
	docker push $REMOTE_IMAGE_LATEST
else
	echo "Skipping branch tagging and push to private image repository"
fi
