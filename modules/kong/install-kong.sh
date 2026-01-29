#!/bin/bash

# Install Gateway API CRDs
#kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml

# Create Kong namespace
#kubectl create namespace kong


kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Namespace
metadata:
  name: kong
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: kong
  annotations:
    konghq.com/gatewayclass-unmanaged: "true"
spec:
  controllerName: konghq.com/kic-gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: kong
  namespace: kong
spec:
  gatewayClassName: kong
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
YAML

# Check
kubectl get pods -n kong
kubectl get svc -n kong

#helm upgrade --install kong kong/kong -n kong -f config/values.yaml
