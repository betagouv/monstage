#!/bin/bash
set -x

rails test test/system/product

./node_modules/.bin/pa11y-ci -c ./.pa11yci $(find ./tmp/w3c/*.html -name '*.html')
