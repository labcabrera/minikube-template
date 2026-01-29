#!/bin/bash

export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace mongodb mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 -d)

export MONGODB_PASSWORD=$(kubectl get secret --namespace mongodb mongodb -o jsonpath="{.data.mongodb-passwords}" | base64 -d | awk -F',' '{print $1}')

echo "MONGODB_ROOT_PASSWORD: $MONGODB_ROOT_PASSWORD"
echo "MONGODB_PASSWORD: $MONGODB_PASSWORD"

kubectl run --namespace mongodb \
  mongodb-client \
  --rm --tty -i --restart='Never' \
  --env="MONGODB_ROOT_PASSWORD=$MONGODB_ROOT_PASSWORD" \
  --image registry-1.docker.io/bitnami/mongodb:latest \
  --command -- bash

# mongosh admin --host "mongodb" --authenticationDatabase admin -u $MONGODB_ROOT_USER -p $MONGODB_ROOT_PASSWORD

# kubectl port-forward --namespace mongodb svc/mongodb 27017:27017

# mongosh --host 127.0.0.1 --authenticationDatabase admin -p $MONGODB_ROOT_PASSWORD