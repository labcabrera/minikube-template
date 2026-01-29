#!/bin/bash

kubectl port-forward --namespace mongodb svc/mongodb 27017:27017