#!/bin/bash
set -x
set -o nounset

docker push monstage/postgres-12-alpine-postgis-synonym:$1
