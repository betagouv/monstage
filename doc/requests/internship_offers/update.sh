#!/bin/bash
set -x

if [ ! -f "env.sh" ]; then
  echo "Usage: create.sh, must be run from ./doc/"
  exit 2
fi
source 'env.sh'

curl -H "Authorization: Bearer ${MONSTAGEDETROISIEME_TOKEN}" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X PATCH \
     -d '{"internship_offer": {"title":"Mon offre de stage", "description": "Description..."}}' \
     -vvv \
     ${MONSTAGEDETROISIEME_ENV}/api/internship_offers/test

