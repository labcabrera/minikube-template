#!/bin/bash

set -e

CA_KEY="../certs/root-ca.key"
CA_CERT="../certs/root-ca.crt"

if [ ! -d "../certs" ]; then
  mkdir -p "../certs"
fi

openssl genrsa -out "$CA_KEY" 2048

openssl req -x509 -new -nodes \
  -sha256 \
  -days 3650 \
  -key "$CA_KEY" \
  -out "$CA_CERT" \
  -subj "/CN=*.local"
