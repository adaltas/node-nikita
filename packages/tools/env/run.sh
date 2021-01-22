#!/bin/bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./apm/run.sh
./centos6/run.sh
./centos7/run.sh
./cron/run.sh
# ./dconf/run.sh
./iptables/run.sh
./npm/run.sh
./rubygems/run.sh
