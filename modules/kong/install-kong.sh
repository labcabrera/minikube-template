#!/bin/bash

kubectl create namespace kong

helm install kong kong/kong -n kong \
  --set ingressController.installCRDs=false