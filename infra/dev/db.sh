#!/bin/bash
set -x

DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:drop RAILS_ENV=development
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:create RAILS_ENV=development
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d monstage postgresql_df107c9b-97de-4734-9c46-895975f05a20-20200430012537
rails db:migrate RAILS_ENV=development
