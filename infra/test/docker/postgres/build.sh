#!/bin/bash
set -x
set -o nounset

docker build -t mfourcade/postgres-12-alpine-postgis-synonym:$1 .circleci/docker/postgres
