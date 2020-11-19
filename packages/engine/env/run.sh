#!/bin/bash
PWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $PWD/arch_chroot
docker-compose up --abort-on-container-exit

cd $HOME/sudo
docker-compose up --abort-on-container-exit
