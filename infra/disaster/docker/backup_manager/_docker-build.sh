#!/bin/bash
# info:
set -x
set -o nounset

docker build -t monstage/backup:1.0.0 infra/disaster/docker/backup_manager

