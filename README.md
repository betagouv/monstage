# README

This README would normally document whatever steps are necessary to get the
application up and running.

# Infra
Things you may want to cover:

* Ruby version
2.5.1

* Configuration

* Database
- Install Postgres 10.6
- Initialize with : initdb /usr/local/var/postgres -E utf8
- Create local db : createdb monstage
- Start with : pg_ctl -D /usr/local/var/postgres start
- Stop with : pg_ctl -D /usr/local/var/postgres stop
- For test user [tighly coupled with CI which creates or gives it's own connection string], see ./infra/test/postgres-config.md

