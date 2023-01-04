#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee ./env/apm/index.coffee run
./centos7/run.sh
./cron/run.sh
./dconf/run.sh
npx coffee ./env/iptables/index.coffee run
npx coffee ./env/npm/index.coffee run
npx coffee ./env/rubygems/index.coffee run
