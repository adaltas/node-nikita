#!/bin/bash
set -e

CWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $CWD/arch_chroot
docker-compose up --abort-on-container-exit

cd $CWD/centos6
docker-compose up --abort-on-container-exit

cd $CWD/centos7
docker-compose up --abort-on-container-exit

cd $CWD/chown
docker-compose up --abort-on-container-exit

cd $CWD/sudo
docker-compose up --abort-on-container-exit

cd $CWD/ubuntu_trusty
docker-compose up --abort-on-container-exit
