#!/bin/bash
set -x
command -v sentry-cli >/dev/null 2>&1 || { echo "Deploy must ping sentry-cli to track bug from commits, install it with brew install getsentry/tools/sentry-cli. then login by creating a ~/.sentryclirc [credentials for sentri.io are in monstage.kdbx, file format can be seen: https://docs.sentry.io/cli/configuration/ and $repo/ .sentryclirc.sample]."; exit 1; }

# Deploy heroku
heroku pipelines:promote -a betagouv-monstage-staging
heroku run rails db:migrate -a betagouv-monstage-prod
heroku restart -a betagouv-monstage-prod

# Create sentry release
VERSION=$(sentry-cli releases propose-version)
sentry-cli releases new $VERSION
sentry-cli releases set-commits --auto $VERSION
