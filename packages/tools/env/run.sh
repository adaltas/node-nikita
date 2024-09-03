#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./cron/run.sh
./dconf/run.sh
./repo-alma8/run.sh
./repo-rocky9/run.sh
node ./iptables/index.js run
node ./npm/index.js run
node ./rubygems/index.js run
