[![CircleCI](https://circleci.com/gh/betagouv/monstage.svg?style=svg)](https://circleci.com/gh/betagouv/monstage)
# README


This README would normally document whatever steps are necessary to get the
application up and running.

# Infra
Things you may want to cover:

* Ruby version: 2.5.1
* Database
- Install Postgres 10.6
- Initialize with : initdb /usr/local/var/postgres -E utf8
- Create local db : createdb monstage
- Start with : pg_ctl -D /usr/local/var/postgres start
- Stop with : pg_ctl -D /usr/local/var/postgres stop
- Install html5validator : pip install html5validator
- Install postgis :
  - If you are using Postgres.app, Postgis is already here
  - If you installed postgres with Homebrew, run : brew install postgis
- Setup Postgis : rake db:gis:setup

## run dev env

```
foreman start -f Procfile.dev
```

Launch Mailcatcher to see emails :
- `gem install mailcatcher`
- `mailcatcher`

## tooling: linting, etc...

**ensure we are not commiting a broken circle ci config file** : ``` cp ./infra/dev/pre-commit ./git/hooks/ ```

## run test

```rake test```

# ci

use CircleCI : https://circleci.com/gh/betagouv/monstage

# staging

deployement automated via CI, can be done manually with ```infra/staging/deploy.sh```

## run
* ```infra/staging/console.sh``` : run rails console on heroku
* ```infra/staging/set_env.sh``` : setup heroku env vars
* ```infra/staging/logs.sh``` : tail logs
