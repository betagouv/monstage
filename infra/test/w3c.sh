#!/bin/bash

# requires: brew install tidy-html5
bundle exec bin/rails html5_validator:flush_cached_responses
bundle exec bin/rails html5_validator:flush_pa11y_error_files

bundle exec bin/rails test test/system/w3c/**/*
`find ./tmp/w3c -type f -name "*.html" | xargs tidy -config tidy_config.txt  --force-output -m`
bundle exec bin/rails html5_validator:run
exit 0
