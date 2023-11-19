#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

# Require cgroup v1
if command -v multipass; then
  ./cgroups-multipass/run.sh
else
  node ./cgroups/index.js run
fi
./info_archlinux/run.sh
./info_centos6/run.sh
./info_centos7/run.sh
./info_ubuntu/run.sh
./limits/run.sh
./tmpfs/run.sh
./user/run.sh
