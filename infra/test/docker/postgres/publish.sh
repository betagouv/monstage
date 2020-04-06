#!/bin/bash
set -x
set -o nounset

docker push mfourcade/postgres-12-alpine-postgis-synonym:$1
