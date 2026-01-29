#!/bin/bash

set -e

NAMESPACE="observability"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace "${NAMESPACE}" \
  --values ./config/prometheus-values.yaml \
  --wait --timeout "600s"

kubectl apply -f ./certs/grafana-cert.yaml -n "$NAMESPACE"

kubectl apply -f ./ingress/grafana-ingress.yaml -n "$NAMESPACE"
kubectl apply -f ./ingress/prometheus-ingress.yaml -n "$NAMESPACE"
