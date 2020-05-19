#!/bin/sh

bundle exec bin/rails db:structure:load db:seed db:migrate SCHEMA=/app/infra/review/structure-review.sql
