#!/bin/bash
set -x

SSH_PRIV=~/.ssh/clevercloud-monstage
if [ ! -f "$SSH_PRIV" ]; then
  echo "missing private key to push, check kdbx for content"
  exit 1;
fi;

ssh -t ssh@sshgateway-clevercloud-customers.services.clever-cloud.com app_e5f58005-0aad-48cd-a4ea-03d6f6867d2c
