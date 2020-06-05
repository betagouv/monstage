#!/bin/bash
set -x

DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:drop RAILS_ENV=development
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:create RAILS_ENV=development
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d monstage monstage_backup
rails db:migrate RAILS_ENV=development
