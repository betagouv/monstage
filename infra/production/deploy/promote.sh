#!/bin/bash
set -x

heroku pipelines:promote  -a betagouv-monstage-staging
heroku run db:migrate -a betagouv-monstage-prod
