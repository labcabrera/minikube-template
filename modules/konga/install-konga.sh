#!/bin/bash

kubectl create namespace konga 2>/dev/null || true

kubectl -n konga create secret generic konga-mongo \
  --from-literal=DB_PASSWORD='changeit'

kubectl apply -f config/konga-deployment.yaml

kubectl apply -f config/konga-service.yaml

# kubectl -n kong port-forward svc/konga 1337:80