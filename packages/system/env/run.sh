#!/bin/bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./authconfig/run.sh
./cgroups/run.sh
./info_archlinux/run.sh
./info_centos6/run.sh
./info_centos7/run.sh
./info_ubuntu/run.sh
./limits/run.sh
./tmpfs/run.sh
./user/run.sh
