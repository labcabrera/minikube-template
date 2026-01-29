#!/bin/bash

set -e

CERT_MANAGER_VERSION="v1.14.4"
NAMESPACE_CERT_MANAGER="cert-manager"
ROOT_CA_KEY="../certs/root-ca.key"
ROOT_CA_CERT="../certs/root-ca.crt"
ISSUER_CERT="./certificates/clusterissuer-template-root-ca.yaml"

kubectl create namespace "$NAMESPACE_CERT_MANAGER" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml

helm install cert-manager jetstack/cert-manager \
  --namespace "$NAMESPACE_CERT_MANAGER" \
  --version "$CERT_MANAGER_VERSION"

kubectl create secret tls template-root-ca \
  --cert="$ROOT_CA_CERT" \
  --key="$ROOT_CA_KEY" \
  -n "$NAMESPACE_CERT_MANAGER"

kubectl apply -f "$ISSUER_CERT"