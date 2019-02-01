#!/bin/bash
set -e

ENV=$1
echo "[ENVIRONMENT]: $ENV"

case $ENV in
	dev)
		K8S_NAMESPACE=$K8S_DEV_NAMESPACE
		;;
	test)
		K8S_NAMESPACE=$K8S_TEST_NAMESPACE
		;;
	*)
		echo "ERROR: Unable to match environment to Kubernetes namespace"
		exit 1
		;;
esac
echo "[K8S_NAMESPACE]: $K8S_NAMESPACE"

GIT_REV=$(git log -n 1 --pretty=format:%h)
VERSION=$(buildkite-agent meta-data get "release-version" --default $GIT_REV)
IMG_TAG_TO_DEPLOY=$IMAGE_REGISTRY/$APP_IMAGE_NAME:$VERSION

echo "$IMG_TAG_TO_DEPLOY will be deployed..."

echo "Getting kubernetes creds..."
gcloud config set project $GCP_PROJECT
gcloud config set compute/zone $GCP_COMPUTE_REGION
gcloud container clusters get-credentials $GCP_K8S_CLUSTER_NAME

echo "Executing kubectl deployment..."
kubectl delete configmap $K8S_CONFIGMAP_NAME --ignore-not-found -n $K8S_NAMESPACE
kubectl create -f $K8S_CONFIGMAP_BASE_DIR/$ENV/$K8S_CONFIGMAP_FILE_NAME -n $K8S_NAMESPACE
# kubectl apply -f <(istioctl kube-inject -f $K8S_DEPLOYMENT_FILE) -n $K8S_NAMESPACE
kubectl apply -f $K8S_DEPLOYMENT_FILE -n $K8S_NAMESPACE

echo "Running kubectl set image deployment/$K8S_DEPLOYMENT_NAME $K8S_CONTAINER_NAME=$IMG_TAG_TO_DEPLOY -n $K8S_NAMESPACE..."
kubectl set image deployment/$K8S_DEPLOYMENT_NAME $K8S_CONTAINER_NAME=$IMG_TAG_TO_DEPLOY -n $K8S_NAMESPACE

echo "Wait for deployment to finish..."
kubectl rollout status deployment/$K8S_DEPLOYMENT_NAME -n $K8S_NAMESPACE