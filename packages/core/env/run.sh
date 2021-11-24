#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./arch_chroot/run.sh
./centos6/run.sh
./centos7/run.sh
./chown/run.sh
./sudo/run.sh
./ubuntu_trusty/run.sh
