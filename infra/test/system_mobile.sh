#!/bin/bash
# usage: run e2e suites for mobile
set -x

PARALLEL_WORKERS=1 BROWSER=headless_chrome USE_IPHONE_EMULATION=true bundle exec rake test:system TESTOPTS='--name /USE_IPHONE_EMULATION/'

