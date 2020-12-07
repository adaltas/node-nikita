#!/bin/bash

ENV_DIR=`pwd`/`dirname ${BASH_SOURCE}`

cd $ENV_DIR/mariadb
docker-compose up --abort-on-container-exit

cd $ENV_DIR/mysql
docker-compose up --abort-on-container-exit

cd $ENV_DIR/postgresql
docker-compose up --abort-on-container-exit
