#!/bin/bash

CWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $CWD/mariadb
docker-compose up --abort-on-container-exit

cd $CWD/mysql
docker-compose up --abort-on-container-exit

cd $CWD/postgresql
docker-compose up --abort-on-container-exit
