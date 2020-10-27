[![CircleCI](https://circleci.com/gh/betagouv/monstage.svg?style=svg)](https://circleci.com/gh/betagouv/monstage)


# Setup
Things you may want to cover:

* Ruby version: 2.7.1
* Database postgresql 12
 - Initialize with : `initdb /usr/local/var/postgres -E utf8`
 - Create local db : `createdb monstage`
 - Start with : `pg_ctl -D /usr/local/var/postgres start`
 - Stop with : `pg_ctl -D /usr/local/var/postgres stop`
* Install html5validator : `pip install html5validator`
* Install postgis :
  - If you are using Postgres.app, Postgis is already here
  - If you installed postgres with Homebrew, run : `brew install postgis`
  - Setup Postgis : `rake db:gis:setup`
* copy synonym dictionnary for pg search : `./infra/dev/setup_pg_synonym.sh`
* avoid rebuilding api doc : `./infra/dev/update-doc-output-files.sh`

* setup db:
   * `./infra/dev/db.sh` (require a pg export)
   * `./infra/test/db.sh`
* create rails master.key : `touch config/master.key` (then copy paste the entrey rails master key from monstage.kdbx)

# Architecture

## backend

* Rails defaults
* Postgres as RDBMS
* Postgres with Postgis for geoqueries
* Postgres for FTS
* Postgres(notify) with ActionCable for wss://
* Redis & Sidekiq for Async jobs

## frontend

* Turbolink based "SPA"
* Use [bootstrap](https://getbootstrap.com/docs/4.5/getting-started/introduction/)
* Use [stimulus](https://stimulusjs.org/) to improve simple components ex: a11y datetime inputs, flash messages [auto hide on mobile], multi select inputs [just (un/)select a list of inputs]
* Use [react](https://reactjs.org/) when complexity grows ex :
 * student searches for school by [city.name, school.name], then chooses school, then chooses classroom.
 * someone searches for internship offers by keyword, city.name, {location}.radius, keyword

## 3rd party services

### Hosting
* Registrar: [Gandi](https://www.gandi.net/fr)
* Backend/Frontend provider : [CleverCloud](console.clever-cloud.com/), see [ruby](https://github.com/betagouv/monstage/tree/master/clevercloud/ruby.json), [cron](https://github.com/betagouv/monstage/tree/master/clevercloud/cron.json)
* DB provider : [CleverCloud](console.clever-cloud.com/), first contacted provider to support custom dictionnary
* CDN : [AWS Cloudfront](https://console.aws.amazon.com/console/home)

### Solution

* Support Solution : [Zammad for support](monstage.zammad.com/)
* Analytic Solution : [stats.data.gouv.fr](https://stats.data.gouv.fr)

### Api

* API: Town search: [geo.api.gouv.fr](https://geo.api.gouv.fr/decoupage-administratif/communes)
* API: Address autocomplete: [geo.api.gouv.fr/adresse](https://geo.api.gouv.fr/adresse)

### Tooling

* Infrastructure monitoring solution: [newrelic](https://rpm.newrelic.com/)
* Bug monitoring solution: [sentry](https://sentry.io/)
* Mail: [mailjet](https://mailjet.com)
* uptime/downtime:

# Build: test, dev

## documentation (browse with github, having README.md at root of each folder)

* [controllers](https://github.com/betagouv/monstage/tree/master/app/controllers)
* [models](https://github.com/betagouv/monstage/tree/master/app/models)
* [mailers](https://github.com/betagouv/monstage/tree/master/app/mailers)
* [api](https://github.com/betagouv/monstage/tree/master/doc)



## dev

**start project**

```
bundle
yarn
foreman start -f Procfile.dev
```

### tooling: linting, etc...

* **ensure we are not commiting a broken circle ci config file** : ``` cp ./infra/dev/pre-commit ./git/hooks/ ```
* mail should be opened automatically

## test

### units test

```rails test```

### system / e2e, runs within a browswer

* run in background: `rails test:system`
* run with browser `BROWSER=firefox|chrome rails test:system`


### w3c (using vnu.jar)

```./infra/test/w3c.sh```

# Run: ci, review, staging, production

CI: [CircleCI](https://circleci.com/gh/betagouv/monstage)

## review app : https://monstage-{pr_name.parameterize}-{commit}.herokuapp.com/

requirements: install heroku cli `https://devcenter.heroku.com/articles/heroku-cli`

* deployed automatically via github/heroku for each pull requests.
* see your PR on github for the review app link
* seed: important heroku review app seeding is only done at opening of PR. if you change seed, close/open PR

## staging/prod

**requirements**
clever cloud cli : https://www.clever-cloud.com/doc/clever-tools/getting_started/

**Setup SSH public key**

```bash
# add the pub key in your env
touch ~/.ssh/clevercloud-monstage.pub
# you'll find the public key content in our kdbx file (search for clever cloud public key)
# assigns appropriate rights
chmod 644 ~/.ssh/clevercloud-monstage.pub
```

**Setup SSH private key**

```bash
# create the priv key in your env
touch ~/.ssh/clevercloud-monstage
# you'll find the pkey content in our kdbx file (search for clever-cloud private key)
# assigns appropriate rights
chmod 600 ~/.ssh/clevercloud-monstage
```

**Use ssh key**

```bash
# ensure to use this key when connecting to clever hostnames
cat infra/dev/ssh/config >> ~/.ssh/config
```

## staging app : [v2-test.monstagedetroisieme.fr](https://v2-test.monstagedetroisieme.fr)

* deployement automated via CI (merge on master, push on staging)
* push on staging can be "forced" manually using ```infra/staging/deploy.sh```
* see other tools in ```infra/staging/*.sh```  (logs, console...)

## production app : [www.monstagedetroisieme.fr](https://www.monstagedetroisieme.fr)

* push on production can be done manually using ```infra/production/deploy.sh```
* see other tools in ```infra/production/*.sh``` (logs, console...)


