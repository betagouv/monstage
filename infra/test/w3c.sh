#!/bin/bash

# requires: brew install tidy-html5
bundle exec bin/rails html5_validator:flush_cached_responses
bundle exec bin/rails test test/system/w3c/*
`find ./tmp/w3c -type f -name "*.html" | xargs tidy -config tidy_config.txt  --force-output -m`
node_modules/.bin/pa11y-ci $(find ~/project/tmp/w3c/*.html -name '*.html')
bundle exec bin/rails html5_validator:run
