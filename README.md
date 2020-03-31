[![CircleCI](https://circleci.com/gh/betagouv/monstage.svg?style=svg)](https://circleci.com/gh/betagouv/monstage)


# Setup
Things you may want to cover:

* Ruby version: 2.6.4
* Database
- Install Postgres 12
- Initialize with : initdb /usr/local/var/postgres -E utf8
- Create local db : createdb monstage
- Start with : pg_ctl -D /usr/local/var/postgres start
- Stop with : pg_ctl -D /usr/local/var/postgres stop
- Install html5validator : pip install html5validator
- Install postgis :
  - If you are using Postgres.app, Postgis is already here
  - If you installed postgres with Homebrew, run : brew install postgis
- Setup Postgis : rake db:gis:setup

# Architecture

**backend**

* Rails defaults
* Postgres as RDBMS
* Postgres with Postgis for geoqueries
* Postgres FTS for autocomplete
* Postgres with Delayed job for Async jobs
* Postgres(notify) with ActionCable for wss://

**frontend**

* Turbolink based "SPA"
* Using stimulus to improve some simple components ex: a11y datetime inputs, flash messages [auto hide on mobile], multi select inputs [just (un/)select a list of inputs]
* Using react where stimulus because spagetthi code (lot of states/xhr) ex : student search for his school by city.name school.name, then choose school, then choose classroom. ex : someone search for internship offer by city.name and and {location}.radius)

**hosting & services**

* Hosting : Heroku with some plugins, see heroku manifest [app.json](https://github.com/betagouv/monstage/blob/master/app.json) for more details (app.json)
* Support : Zammad for support
* Analytics : [stats.data.gouv.fr](https://stats.data.gouv.fr)

# Build: test, dev

## documentation (browse with github, having README.md at root of each folder)

* [controllers](https://github.com/betagouv/monstage/tree/master/app/controllers)
* [models](https://github.com/betagouv/monstage/tree/master/app/models)
* [mailers](https://github.com/betagouv/monstage/tree/master/app/mailers)
* [api](https://github.com/betagouv/monstage/tree/master/doc)



## dev

**start project**

```
heroku local -f Procfile.dev
```

### tooling: linting, etc...

* **ensure we are not commiting a broken circle ci config file** : ``` cp ./infra/dev/pre-commit ./git/hooks/ ```
- mail should be opened automatically

## test

### units test

```rails test```

### system / e2e, runs within a browswer __without__ (broken) JS

```rails test:system```

### w3c (using vnu.jar)

```rails test:w3c```

# Run: ci, review, staging, production

see build status at: [CircleCI](https://circleci.com/gh/betagouv/monstage)
regarding env var dependencies, but can be setuped via tools : ```infra/staging|production/set_env.sh```

## review app : https://monstage-{pr_name.parameterize}-{commit}.herokuapp.com/

* deployed automatically via github/heroku for each pull requests.
* see your PR on github for the review app link
* seed: important heroku review app seeding is only done at opening of PR. if you change seed, close/open PR


## staging app : [v2-test.monstagedetroisieme.fr](https://v2-test.monstagedetroisieme.fr)

* deployement automated via CI (merge on master, push on staging)
* push on staging can be "forced" manually using ```infra/staging/deploy.sh```
* see other tools in ```infra/staging/*.sh```  (logs, console...)

## production app : [www.monstagedetroisieme.fr](https://www.monstagedetroisieme.fr)

* prefer heroku promote staging ```infra/production/deploy/promote.sh```
* can be "forced" manually using ```infra/production/deploy/push.sh```
* see other tools in ```infra/production/*.sh``` (logs, console...)


