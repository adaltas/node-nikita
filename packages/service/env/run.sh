#!/bin/bash

HOME=`pwd`/`dirname ${BASH_SOURCE}`

cd $HOME/archlinux
docker-compose up --abort-on-container-exit

cd $HOME/centos6
docker-compose up --abort-on-container-exit

cd $HOME/centos7
docker-compose up --abort-on-container-exit

cd $HOME/systemctl
docker-compose up --abort-on-container-exit

cd $HOME/ubuntu
docker-compose up --abort-on-container-exit
