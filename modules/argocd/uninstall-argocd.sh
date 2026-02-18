#!/bin/bash

NAMESPACE_CICD="cicd"

helm uninstall argocd -n "$NAMESPACE_CICD"

kubectl delete namespace "$NAMESPACE_CICD"
