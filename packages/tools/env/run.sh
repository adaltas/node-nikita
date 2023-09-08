#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./cron/run.sh
./dconf/run.sh
# ./repo-centos/run.sh
npx coffee ./env/iptables/index.coffee run
npx coffee ./env/npm/index.coffee run
npx coffee ./env/rubygems/index.coffee run
