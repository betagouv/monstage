#!/bin/bash
set -x
# rails db:structure:dump
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:drop RAILS_ENV=test
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:create RAILS_ENV=test
rails db:structure:load RAILS_ENV=test
