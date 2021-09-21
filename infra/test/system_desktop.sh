#!/bin/bash
# usage: run e2e suites for desktop
set -x

BROWSER=headless_chrome bundle exec rake test:system TESTOPTS='--exclude /USE_IPHONE_EMULATION|USE_W3C/'

