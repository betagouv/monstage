#!/bin/bash
set -x

if [ ! -f "env.sh" ]; then
  echo "Usage: create.sh, must be run from ./doc/"
  exit 2
fi
source 'env.sh'

INPUT_FILE="input/internship_offers/create.json"

curl -H "Authorization: Bearer ${MONSTAGEDETROISIEME_TOKEN}" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X POST \
     -d @$INPUT_FILE \
     -vvv \
     ${MONSTAGEDETROISIEME_ENV}/api/internship_offers

