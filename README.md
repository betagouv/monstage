[![CircleCI](https://circleci.com/gh/betagouv/monstage.svg?style=svg)](https://circleci.com/gh/betagouv/monstage)
# README


This README would normally document whatever steps are necessary to get the
application up and running.

# Infra
Things you may want to cover:

* Ruby version: 2.6.4
* Database
- Install Postgres 11.5
- Initialize with : initdb /usr/local/var/postgres -E utf8
- Create local db : createdb monstage
- Start with : pg_ctl -D /usr/local/var/postgres start
- Stop with : pg_ctl -D /usr/local/var/postgres stop
- Install html5validator : pip install html5validator
- Install postgis :
  - If you are using Postgres.app, Postgis is already here
  - If you installed postgres with Homebrew, run : brew install postgis
- Setup Postgis : rake db:gis:setup

# Build: test, dev

## dev

**start project**

```
heroku local -f Procfile.dev
```

### tooling: linting, etc...

* **ensure we are not commiting a broken circle ci config file** : ``` cp ./infra/dev/pre-commit ./git/hooks/ ```
* **consult emails sent in development environment with mail opener**:
- mail should be opened automatically

## test

### units test

```rails test```

### system / e2e, runs within a browswer __without__ (broken) JS

```rails test:system```

### w3c (using vnu.jar)

```rails test:w3c```

# Run: ci, staging, production

see build status at: [CircleCI](https://circleci.com/gh/betagouv/monstage)

both environments are limit regarding env var dependencies, but can be setuped via tools : ```infra/staging|production/set_env.sh```

## staging

* deployement automated via CI (merge on master, push on staging)
* push on staging can be "forced" manually using ```infra/staging/deploy.sh```
* see other tools in ```infra/staging/*.sh```  (logs, console...)

## production

* prefer heroku promote staging ```infra/production/deploy/promote.sh```
* can be "forced" manually using ```infra/production/deploy/push.sh```
* see other tools in ```infra/production/*.sh``` (logs, console...)


