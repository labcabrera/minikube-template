#!/bin/bash

kubectl apply -n applications -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: sample-users-api
spec:
  parentRefs:
  - name: kong
    namespace: kong
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /users
    backendRefs:
    - name: sample-users-api
      port: 80
YAML


# export PROXY_IP=$(kubectl get svc -n kong kong-gateway-proxy -o jsonpath='{range .status.loadBalancer.ingress[0]}{@.ip}{@.hostname}{end}')
# curl -i "http://$PROXY_IP/users"