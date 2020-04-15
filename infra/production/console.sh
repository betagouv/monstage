#!/bin/bash
set -x

SSH_PRIV=~/.ssh/clevercloud-monstage
if [ ! -f "$SSH_PRIV" ]; then
  echo "missing private key to push, check kdbx for content"
  exit 1;
fi;

ssh -t ssh@sshgateway-clevercloud-customers.services.clever-cloud.com app_cb8fb836-b0c7-43e1-ba2e-130a73626fa6
