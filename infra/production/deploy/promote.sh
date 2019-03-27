#!/bin/bash
set -x

heroku pipelines:promote  -a betagouv-monstage-staging
