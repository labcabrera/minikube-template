#!/bin/bash

NAMESPACE_CICD="cicd"

find ./sample-projects -name "*.yaml" -o -name "*.yml" | while read -r file; do
  kubectl apply -f "$file" -n "$NAMESPACE_CICD"
done
