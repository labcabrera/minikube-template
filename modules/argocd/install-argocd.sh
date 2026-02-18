#!/bin/bash

NAMESPACE_CICD="cicd"

kubectl create namespace "$NAMESPACE_CICD"

helm install argocd argo/argo-cd -n "$NAMESPACE_CICD" -f ./config/values.yaml

# helm install argocd argo/argo-cd \
#   --namespace "$NAMESPACE_CICD" \
#   --create-namespace \
#   --set server.service.type=ClusterIP \
#   --set configs.secret.argocdServerAdminPassword='$2y$10$vAKJfNlItZH/h500v0DObOd5IFBAUJifgSLTiVpKzqJ2AKGhqozVy'

# kubectl apply -f ./config/argocd-ingress.yaml