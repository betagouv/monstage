[![CircleCI](https://circleci.com/gh/betagouv/monstage.svg?style=svg)](https://circleci.com/gh/betagouv/monstage)


# Setup
Things you may want to cover:

* Ruby version: 2.7.2
* Database postgresql 12
  - On Linux :
    - sudo apt-get install postgresql-12 libpq-dev
 - Initialize with : `initdb /usr/local/var/postgres -E utf8`
 - Create local db : `createdb monstage`
 - Start with : `pg_ctl -D /usr/local/var/postgres start`
 - Stop with : `pg_ctl -D /usr/local/var/postgres stop`
* Install html5validator : `pip install html5validator`
* Install postgis :
  - On Mac :
    - If you are using Postgres.app, Postgis is already here
    - If you installed postgres with Homebrew, run : `brew install postgis`
  - On Linux :
    sudo apt install postgis postgresql-12-postgis-3
* Install Redis
  - On Linux : sudo apt install redis-server
* avoid rebuilding api doc : `./infra/dev/update-doc-output-files.sh`

* setup db:
   * `./infra/dev/db.sh` (require a pg export)
   * `./infra/test/db.sh`

* Restore a dump :
   * Create a dump from existing staging or prod : pg_dump -F c -d *DB_URI* > db.dump
   * Restore the dump locally : pg_restore -d *DB_NAME* db.dump
  * Restore the dump on staging / prod : pg_restore --clean --if-exists --no-owner --no-privileges --no-comments -d *DB_URI* db.dump

* Install yarn & webpack
  - On Linux
    sudo apt install npm
    npm install --global yarn
    npm install webpack-dev-server -g
* create rails master.key : `touch config/master.key` (then copy paste the entrey rails master key from monstage.kdbx)
* Ask for a .env file from another developer

# Architecture

We keep things simple and secure :

* a simple monolith mostly based on rails
* minimals effort for an SPA like feeling while ensuring it works without js (90% based on turbo, some react for advanced user inputs [autocomplete, nearby searches], other wise a good old html form is required)
* we try to avoid stacking technologies over technologies (fewer dependencies makes us happy).
* we try to keep our dependencies up to date (bundle update, yarn update... at least once a month).

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

As a public french service, we try to keep most data hosted by french service provider with servers located in france (in hope to stay compliant with most regulations)

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
* Infra management
* Mail: [tipimail](https://app.tipimail.com)
* Monit [monit](monit.monstagedetroisieme.fr) : website up/down (pingdom like)

# Build: test, dev

## documentation (browse with github, having README.md at root of each folder)

* [controllers](https://github.com/betagouv/monstage/tree/master/app/controllers)
* [models](https://github.com/betagouv/monstage/tree/master/app/models)
* [mailers](https://github.com/betagouv/monstage/tree/master/app/mailers)
* [api](https://github.com/betagouv/monstage/tree/master/doc)



## Dev

**start project**

```
bundle install
yarn install
foreman start -f Procfile.dev
```

### Tooling: linting, etc...

* **ensure we are not commiting a broken circle ci config file** : ``` cp ./infra/dev/pre-commit ./.git/hooks/ ```
* mail should be opened automatically by letter opener

### Previews

* [mailers](http://localhost:3000/rails/mailers)
* [view_components](http://localhost:3000/rails/view_components)

### Etapes de travail jusqu'au merge dans staging

- (staging) $ ```git checkout -b mabranche``` # donc creer sa feature branch
- (mabranche) $ ```git commit``` # coder sa feature et commiter
- (mabranche) $ ```git checkout staging``` # besoin de récupérer le code de staging? on repasse sur staging
- (staging) $ ```git pull origin staging --rebase``` # on rebase la différence par rapport a soi-même
- (staging) $ ```git checkout mabranche``` # on repasse sur sa branche
- (mabranche) $ ```git merge staging``` # on merge staging dans sa propre branche

Pour les mises en production, on utilise le script de déploiement après avoir fait :
- (master) $ ```git merge staging``` # on merge staging dans master

Ainsi, on peut faire des hotfixes à merger directement sur master

Références:
- https://git-scm.com/docs/git-rebase (git-rebase - Reapply commits on top of another base tip)
- https://git-scm.com/docs/git-pull (donc ca combine fetch / git merge. avec le --rebase : fetch+rebase)

#### Hotfixes, les étapes

- Développer son fix sur une branche, merger sur master
- déployer master avec `./infra/production/deploy.sh`
- merger master sur staging une fois le fix constaté
- pousser staging sur github

## test

our test suite contains

* unit tests, we try to everything undercontrol with many tests (maybe>75% test coverage)
* systems, testing feature in e2e mode. those test keeps html version for later processing
  * w3c (using previously created html files)
  * a11y (using previously created html files)

### about/run units test

run with ```rails test``` (JS is not executed, so quick tests)

### about/run system/e2e tests

this app is BUILT FOR TWO PLATFORMs : web/mobile

DEPENDING OF THE TARGETED PLAFORM, FEATURES and TEST DIFFER. but rails test:system include all e2e tests in one big suite. To split this big suite per platform we use an env var : USE_IPHONE_EMULATION=anything AND two of minitest's TEST_OPTS flags :

1. `--name='/pattern_to_run_tests_matching/'`
2. `--exclude='/pattern_to_skip_tests_matching/'`

To make it easier to run a suite for a dedicated platform :

* mobile only shortcut: `./infra/test/system_mobile.sh` [only mobile, capybara with a selenium driver, driving a chrome_headless + emulator]
* desktop only shortcut: `./infra/test/system_desktop.sh` [only desktop, capybara with a selenium driver, driving a chrome_headless]
* w3c only shortcut: `./infra/test/w3c_desktop.sh` [only desktop, capybara with a selenium driver, driving a chrome_headless]
* mobile and desktop + w3c : `./infra/test/system_all.sh` [only w3c run through system]

( thoses scripts are also used for the CI. )

Good to know :

* run in foreground, with visual feedback : `BROWSER=firefox|chrome|safari rails test/system/${YOUR_TEST}`

### about/run w3c tests (using vnu.jar)

those tests depends on the system / e2e (which goes throught a web browser with js execution, then save .html files). run w3c tests via ```./infra/test/w3c_desktop.sh```

### a11y tests (using pa11y-ci)

those tests depends on the ```./infra/test/w3c_desktop.sh``` (which goes throught browser with js execution). run a11y tests via ```./infra/test/a11y_suite.sh```

### CI, full suite (unit, system, w3c, a11y)

Our CI (circleCI) run all 4 kinds of test. We used circleci configuration format : [.circle/config](https://github.com/betagouv/monstage/blob/master/.circleci/config.yml) file.
Results are available using [CircleCI](https://circleci.com/gh/betagouv/monstage) ui.

**Important notes :**

### User testing with review apps

our review apps are hosted by heroku, we also try to maintain a cross functionnal seed.rb (seeding of db) to try each and every key feature easily

review apps are accessible following this pattern ```https://monstage-{pr_name.parameterize}-{commit}.herokuapp.com/```

requirements: install heroku cli `https://devcenter.heroku.com/articles/heroku-cli`

**Important notes :**

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

* git checkout staging
* git pull
* git checkout master
* git pull
* git merge staging
* git push
* push on production can be done manually using ```./infra/production/deploy.sh```


* see other tools in ```infra/production/*.sh``` (logs, console...)

### hotfix

* git checkout master
* git pull
* git cherry-pick <commit_nr Hotfix-PR-branch> (* : as many commits as necessary)
* git push
* push on production can be done manually using ```./infra/production/deploy.sh```
* git checkout staging
* git pull
* git merge master
* git push
* archive <Hotfix-PR-branch> in Github

# disaster recovery plan

in case of a disaster we do have a plan starting with : [monstage-backup-manager](https://github.com/betagouv/monstage-backup-manager/)
