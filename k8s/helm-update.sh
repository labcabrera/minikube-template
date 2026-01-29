#!/bin/bash

set -e

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add harbor https://helm.goharbor.io
helm repo add jetstack https://charts.jetstack.io
helm repo add kong https://charts.konghq.com

helm repo update
