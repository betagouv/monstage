#!/bin/bash
set -x

# run unit tests
bundle exec rails test

# run system test in major browsers, ie not yet rdy
$(pwd)/test/system_all.sh

# ensure w3c validity
java -jar ~/project/node_modules/vnu-jar/build/dist/vnu.jar --errors-only ~/project/tmp/w3c/*.html

# ensure basic a11y validity
./node_modules/.bin/pa11y-ci $(find ./tmp/w3c/*.html -name '*.html')

# test other browsers
SELENIUM_DRIVER=firefox PARALLEL_WORKERS=1 bundle exec bin/rails test:system
SELENIUM_DRIVER=safari  PARALLEL_WORKERS=1 bundle exec bin/rails test:system

