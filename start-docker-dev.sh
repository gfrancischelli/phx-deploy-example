#!/bin/sh

# $0 - the path you executed the script from
# $@ - the parameters you executed this script with

BASE_DIR=$(cd "$(dirname "$0")"; pwd)/dev_docker

cd $BASE_DIR

docker-compose \
  -f "./example_app.yml" \
  -f "./prometheus.yml" \
  -f "./grafana.yml" \
  "$@"
