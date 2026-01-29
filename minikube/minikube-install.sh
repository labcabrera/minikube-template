#!/bin/bash

set -e

PROFILE="minikube-template"

#MEMORY=8192
MEMORY=12288
#MEMORY=16384

CPUS=4
DISK=20g

K8S_VERSION=v1.35.0

NAMESPACE_APPS="applications"

minikube start \
  --profile "$PROFILE" \
  --driver=docker \
  --memory=$MEMORY \
  --cpus=$CPUS \
  --disk-size=$DISK \
  --kubernetes-version=$K8S_VERSION \
  --addons=default-storageclass \
  --addons=storage-provisioner \
  --addons=metrics-server \
  --addons=ingress \
  --addons=dashboard \

kubectl create namespace "$NAMESPACE_APPS"
