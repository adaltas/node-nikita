#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee ./authconfig/index.coffee run
npx coffee ./cgroups/index.coffee run
./info_archlinux/run.sh
./info_centos6/run.sh
./info_centos7/run.sh
./info_ubuntu/run.sh
./limits/run.sh
./tmpfs/run.sh
./user/run.sh
