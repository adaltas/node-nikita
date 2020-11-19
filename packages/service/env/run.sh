#!/bin/bash

PWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $PWD/archlinux
docker-compose up --abort-on-container-exit

cd $PWD/centos6
docker-compose up --abort-on-container-exit

cd $PWD/centos7
docker-compose up --abort-on-container-exit

cd $PWD/systemctl
docker-compose up --abort-on-container-exit

cd $PWD/ubuntu
docker-compose up --abort-on-container-exit
