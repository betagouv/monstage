#!/bin/bash
set -x

heroku config:set RACK_ENV=staging RAILS_ENV=staging -a betagouv-monstage-staging
heroku config -a betagouv-monstage-staging | grep RAILS_MASTER_KEY

if [ $? -eq 0 ]; then
  echo "ok"
  exit $?
else
  echo "missing RAILS_MASTER_KEY remote $target"
  echo "please add with heroku config:set RAILS_MASTER_KEY=${VALUE} -a betagouv-monstage-staging"
  exit 1;
fi
