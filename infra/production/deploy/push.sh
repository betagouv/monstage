#!/bin/bash
set -x

target='production'
git remote -vvv | grep $target

if [ $? -eq 0 ]; then
  command -v sentry-cli >/dev/null 2>&1 || { echo "Deploy must ping sentry-cli to track bug from commits, install it with brew install getsentry/tools/sentry-cli. then login with sentry-cli login [credentials for sentri.io are in monstage.kdbx], also"; exit 1; }
  git push $target master:master
  sentry-cli releases set-commits "$VERSION" --auto
  exit $?
else
  echo "missing git remote $target"
  echo "please add $target repo"
  echo "-> git remote add $target https://git.heroku.com/betagouv-monstage.git"
  exit 1;
fi
