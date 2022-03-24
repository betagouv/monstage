#!/bin/bash
set -x

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

git checkout master
if [ ! $? -eq 0 ]; then
  echo 'Wrong branch; you should be on master branch'
  exit 1;
fi;

git pull origin master
git push $target master:master
exit $?
