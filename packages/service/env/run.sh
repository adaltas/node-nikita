#!/bin/bash

ENV_DIR=`pwd`/`dirname ${BASH_SOURCE}`

cd $ENV_DIR/archlinux
docker-compose up --abort-on-container-exit

cd $ENV_DIR/centos6
docker-compose up --abort-on-container-exit

cd $ENV_DIR/centos7
docker-compose up --abort-on-container-exit

cd $ENV_DIR/systemctl
docker-compose up --abort-on-container-exit

cd $ENV_DIR/ubuntu
docker-compose up --abort-on-container-exit
