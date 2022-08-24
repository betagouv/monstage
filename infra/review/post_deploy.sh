#!/bin/bash -xue
# Create extensions in the schema where Heroku requires them to be created
# The plpgsql extension has already been created before this script is run
psql -a $HEROKU_APP_NAME -c 'create extension if not exists pg_trgm schema heroku_ext'
psql -a $HEROKU_APP_NAME -c 'create extension if not exists postgis schema heroku_ext'
psql -a $HEROKU_APP_NAME -c 'create extension if not exists unaccent schema heroku_ext'

# from : https://stackoverflow.com/questions/73214844/error-extension-btree-gist-must-be-installed-in-schema-heroku-ext

# Remove enable_extension statements from schema.rb before loading it, since
# even 'create extension if not exists' fails when the schema is not heroku_ext
mv db/schema.rb{,.orig}
grep -v enable_extension db/schema.rb.orig > db/schema.rb
bundle exec bin/rails db:schema:load db:migrate db:seed infra:notify_deployed