#!/bin/bash

PWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $PWD/mariadb
docker-compose up --abort-on-container-exit

cd $PWD/mysql
docker-compose up --abort-on-container-exit

cd $PWD/postgresql
docker-compose up --abort-on-container-exit
