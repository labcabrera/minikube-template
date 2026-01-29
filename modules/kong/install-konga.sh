#!/bin/bash

kubectl create namespace kong

helm install konga \
  https://raw.githubusercontent.com/pantsel/konga/master/charts/konga/konga-1.0.0.tgz \
  -n kong \
  --set config.node_env=production \
  --set config.db_adapter=mongo \
  --set config.db_host='mongodb.mongodb.svc.cluster.local' \
  --set config.db_port=27017 \
  --set config.db_user='mongodb' \
  --set config.db_database='mongodb' \
  --set config.db_passwordExistingSecret='konga-mongo' \
  --set config.db_passwordExistingSecretKey='changeit' \
  --set runMigrations=false