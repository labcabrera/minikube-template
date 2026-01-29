#!/bin/bash

set -e

NAMESPACE_HARBOR="harbor"

kubectl create namespace "$NAMESPACE_HARBOR" --dry-run=client -o yaml | kubectl apply -f -

helm install harbor harbor/harbor \
  --namespace "$NAMESPACE_HARBOR" \
  --set expose.type=ingress \
  --set expose.ingress.hosts.core=harbor.local \
  --set externalURL="http://harbor.local" \
  --set harborAdminPassword="changeit" \
  --set persistence.enabled=true \
  --set persistence.persistentVolumeClaim.registry.size=10Gi \
  --set persistence.persistentVolumeClaim.database.size=5Gi \
  --set persistence.persistentVolumeClaim.jobservice.size=5Gi
