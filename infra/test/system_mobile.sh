#!/bin/bash
# usage: run e2e suites for mobile
set -x

BROWSER=headless_chrome USE_IPHONE_EMULATION=true bundle exec rake test:system TESTOPTS='--name /USE_IPHONE_EMULATION/'

