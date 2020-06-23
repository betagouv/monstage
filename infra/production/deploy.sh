#!/bin/bash
set -x

command -v sentry-cli >/dev/null 2>&1 || { echo "Deploy must ping sentry-cli to track bug from commits, install it with brew install getsentry/tools/sentry-cli. then login with sentry-cli login [credentials for sentri.io are in monstage.kdbx], also"; exit 1; }

target='production'
git remote -vvv | grep $target | grep 'clever'

if [ ! $? -eq 0 ]; then
  echo "missing git remote $target"
  echo "please add $target repo"
  echo "-> git remote add $target git+ssh://git@push-par-clevercloud-customers.services.clever-cloud.com/app_cb8fb836-b0c7-43e1-ba2e-130a73626fa6.git"
  exit 1;
fi

SSH_PRIV=~/.ssh/clevercloud-monstage
if [ ! -f "$SSH_PRIV" ]; then
  echo "missing private key to push, check kdbx for content"
  exit 1;
fi;

git pull origin master
git push $target master:master
VERSION=$(sentry-cli releases propose-version)
sentry-cli releases new $VERSION
exit $?
