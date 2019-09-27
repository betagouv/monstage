#!/bin/bash
set -x
command -v sentry-cli >/dev/null 2>&1 || { echo "Deploy must ping sentry-cli to track bug from commits, install it with brew install getsentry/tools/sentry-cli. then login with sentry-cli login [credentials for sentri.io are in monstage.kdbx], also"; exit 1; }

# Deploy heroku
heroku pipelines:promote -a betagouv-monstage-staging
heroku run rails db:migrate -a betagouv-monstage-prod
heroku restart -a betagouv-monstage-prod

# Create sentry release
sentry-cli releases set-commits "$VERSION" --auto
