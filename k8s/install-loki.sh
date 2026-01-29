#!/bin/bash

set -e

NAMESPACE="observability"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm install loki grafana/loki-stack \
  --namespace "$NAMESPACE" \
  --set grafana.enabled=false \
  --set promtail.enabled=true \
  --set loki.service.type=ClusterIP \
  --set loki.persistence.enabled=false \
  --set loki.auth_enabled=false
