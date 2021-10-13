#!/bin/bash

# requires: brew install tidy-html5
bundle exec bin/rails html5_validator:flush_cached_responses
bundle exec bin/rails test test/system/product/**/*
`find ./tmp/w3c -type f -name "*.html" | xargs tidy -config tidy_config.txt  --force-output -m`
bundle exec bin/rails html5_validator:run