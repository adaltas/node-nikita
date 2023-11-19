#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

# 2021/02/09: glibc 2.33 is broken
# https://bbs.archlinux.org/viewtopic.php?id=263379
# we shall use an older image and not update the package, eg `pacman -Syu`
# which happens in the Dockerfile as well as in the tests
# "install # specific # add pacman options"
./archlinux/run.sh
./centos7/run.sh
node ./systemctl/index.js run
./ubuntu-1404/run.sh
./ubuntu-1404-outdated/run.sh
