#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./arch_chroot/run.sh
./centos7/run.sh
npx coffee ./chown/index.coffee run
npx coffee ./ssh/index.coffee run
./sudo/run.sh
./ubuntu_trusty/run.sh
