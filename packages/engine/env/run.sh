#!/bin/bash
ENV_DIR=`pwd`/`dirname ${BASH_SOURCE}`

cd $ENV_DIR/arch_chroot
docker-compose up --abort-on-container-exit

cd $ENV_DIR/centos7
docker-compose up --abort-on-container-exit

cd $ENV_DIR/chown
docker-compose up --abort-on-container-exit

cd $ENV_DIR/sudo
docker-compose up --abort-on-container-exit

cd $ENV_DIR/ubuntu_trusty
docker-compose up --abort-on-container-exit
