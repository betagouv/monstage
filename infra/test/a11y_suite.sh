#!/bin/bash
set -x

./node_modules/.bin/pa11y-ci $(find ./tmp/w3c/*.html -name '*.html')
