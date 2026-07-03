#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

node ./arch_chroot/index.js run
./arch_chroot_docker/run.sh
./rocky9/run.sh
node ./chown/index.js run
node ./ssh/index.js run
./sudo/run.sh
./ubuntu-14.04/run.sh
./ubuntu-22.04/run.sh
