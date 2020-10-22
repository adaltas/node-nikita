#!/bin/bash

HOME=`pwd`/`dirname ${BASH_SOURCE}`

cd $HOME/mariadb
docker-compose up --abort-on-container-exit

cd $HOME/mysql
docker-compose up --abort-on-container-exit

cd $HOME/postgresql
docker-compose up --abort-on-container-exit
