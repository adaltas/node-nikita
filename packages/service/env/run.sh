#!/bin/bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./archlinux/run.sh
./centos6/run.sh
./centos7/run.sh
./systemctl/run.sh
./ubuntu/run.sh
