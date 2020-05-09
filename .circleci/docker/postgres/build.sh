#!/bin/bash
set -x
set -o nounset

docker build -t monstage/postgres-12-alpine-postgis-synonym:$1 .circleci/docker/postgres
docker push monstage/postgres-12-alpine-postgis-synonym:$1
