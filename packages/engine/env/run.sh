#!/bin/bash
HOME=`pwd`/`dirname ${BASH_SOURCE}`

cd $HOME/arch_chroot
docker-compose up --abort-on-container-exit

cd $HOME/sudo
docker-compose up --abort-on-container-exit
