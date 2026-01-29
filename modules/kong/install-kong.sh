#!/bin/bash

kubectl create namespace kong

helm upgrade --install kong kong/kong -n kong -f config/values.yaml
