#!/bin/sh

SCHEMA=/app/db/structure-review.sql bundle exec bin/rails db:structure:load
bundle exec db:seed
bundle exec db:migrate
