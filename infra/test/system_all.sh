#!/bin/bash
# usage: run e2e suites for desktop and mobile
set -x

$(pwd)/infra/test/system_desktop.sh
$(pwd)/infra/test/system_mobile.sh

