#!/bin/bash
set -e

GIT_REV=$(git log -n 1 --pretty=format:%h)
VERSION=$(cat gradle.properties | cut -d '=' -f2 | cut -d '-' -f1)
echo "[GIT_BRANCH]: $BUILDKITE_BRANCH, [GIT_REV]: $GIT_REV, [VERSION]: $VERSION"
buildkite-agent meta-data set "release-version" "$VERSION"

IMG_TO_TAG_FROM=$IMAGE_REGISTRY/$APP_IMAGE_NAME:$GIT_REV
IMG_TAG=$IMAGE_REGISTRY/$APP_IMAGE_NAME:$VERSION

# Issue to get around detached head (need to be on a branch to release)
git checkout $BUILDKITE_BRANCH
git reset --hard $BUILDKITE_COMMIT

echo "gradle release using automatic versioning..."
./gradlew release -Prelease.useAutomaticVersion=true

GIT_REV=$(git log -n 1 --pretty=format:%h)
VERSION=$(cat gradle.properties | cut -d '=' -f2 | cut -d '-' -f1)
echo "[GIT_BRANCH]: $BUILDKITE_BRANCH, [GIT_REV]: $GIT_REV, [VERSION]: $VERSION"

echo "gcloud configure docker"
gcloud auth configure-docker --quiet

echo docker pull $IMG_TO_TAG_FROM
docker pull $IMG_TO_TAG_FROM

echo docker tag $IMG_TO_TAG_FROM $IMG_TAG
docker tag $IMG_TO_TAG_FROM $IMG_TAG

echo docker push $IMG_TAG
docker push $IMG_TAG