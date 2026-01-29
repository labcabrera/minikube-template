#!/bin/bash

kubectl create namespace mongodb

helm upgrade --install mongodb bitnami/mongodb  \
  -n mongodb \
  --set architecture=standalone \
  --set auth.enabled=true \
  --set auth.rootPassword='changeit' \
  --set auth.username='mongodb' \
  --set auth.password='changeit' \
  --set auth.database='mongodb' \
  --set persistence.enabled=true
