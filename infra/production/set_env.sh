#!/bin/bash
set -x

heroku config:set RACK_ENV=production RAILS_ENV=production JEKYLL_ENV=production DEPLOY_TASKS=static_pages:build -a betagouv-monstage-prod
heroku config -a betagouv-monstage-prod | grep RAILS_MASTER_KEY

if [ $? -eq 0 ]; then
  echo "ok"
  exit $?
else
  echo "missing RAILS_MASTER_KEY remote $target"
  echo "please add with heroku config:set RAILS_MASTER_KEY=${VALUE} -a betagouv-monstage-prod"
  exit 1;
fi
