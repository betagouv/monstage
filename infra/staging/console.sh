#!/bin/bash
set -x

SSH_PRIV=~/.ssh/clevercloud-monstage
if [ ! -f "$SSH_PRIV" ]; then
  echo "missing private key to push, check kdbx for content"
  exit 1;
fi;

ssh -t ssh@sshgateway-clevercloud-customers.services.clever-cloud.com app_27afdde4-bf1e-4100-aca2-2e587c240ee6
