#!/bin/bash
set -x

target='staging'
git remote -vvv | grep $target

if [ $? -eq 0 ]; then
  exit $?
else
  echo "missing git remote $target"
  echo "please add $target repo"
  echo "-> git remote add $target https://git.heroku.com/betagouv-monstage-staging.git"
  exit 1;
fi
