#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./arch_chroot/run.sh
./centos7/run.sh
node ./chown/index.js run
node ./ssh/index.js run
./sudo/run.sh
./ubuntu-14.04/run.sh
./ubuntu-22.04/run.sh
