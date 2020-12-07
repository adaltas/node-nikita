#!/bin/bash

CWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $CWD/archlinux
docker-compose up --abort-on-container-exit

cd $CWD/centos6
docker-compose up --abort-on-container-exit

cd $CWD/centos7
docker-compose up --abort-on-container-exit

cd $CWD/systemctl
docker-compose up --abort-on-container-exit

cd $CWD/ubuntu
docker-compose up --abort-on-container-exit
