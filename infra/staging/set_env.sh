#!/bin/bash
set -x

heroku config:set RACK_ENV=staging RAILS_ENV=staging -a betagouv-monstage
heroku config -a betagouv-monstage | grep RAILS_MASTER_KEY

if [ $? -eq 0 ]; then
  echo "ok"
  exit $?
else
  echo "missing RAILS_MASTER_KEY remote $target"
  echo "please add $target repo"
  echo "-> git remote add $target https://git.heroku.com/wello-front-react.git"
  exit 1;
fi
