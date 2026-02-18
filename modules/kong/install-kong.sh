#!/bin/bash

helm repo add kong https://charts.konghq.com

helm repo update

kubectl create namespace kong

helm install kong kong/ingress -n kong

# Para local sin LB:

cat > values.yaml <<'YAML'
gateway:
  proxy:
    type: NodePort
YAML

helm upgrade --install kong kong/ingress -n kong -f values.yaml

# Check
kubectl get pods -n kong
kubectl get svc -n kong