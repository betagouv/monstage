#!/bin/bash

bundle exec bin/rails html5_validator:flush_cached_responses
bundle exec bin/rails test test/w3c
bundle exec bin/rails html5_validator:run
