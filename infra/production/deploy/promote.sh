#!/bin/bash
set -x

heroku pipelines:promote -a betagouv-monstage-staging
heroku run rails db:migrate -a betagouv-monstage-prod
heroku restart -a betagouv-monstage-prod
