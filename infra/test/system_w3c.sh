#!/bin/bash

# requires: brew install tidy-html5
#!/bin/bash
# usage: run e2e suites for mobile
set -x

bundle exec rake html5_validator:flush_cached_responses
BROWSER=headless_chrome USE_IPHONE_EMULATION=true bundle exec rake test:system TESTOPTS='--name /W3C/'
#`find ./tmp/w3c -type f -name "*.html" | xargs tidy -config tidy_config.txt  --force-output -m`
bundle exec rake html5_validator:run
