#!/bin/bash

HOME=`pwd dirname "${BASH_SOURCE}"`

cd $HOME/mariadb
docker-compose up --abort-on-container-exit

cd $HOME/mysql5
docker-compose up --abort-on-container-exit

cd $HOME/postgresql
docker-compose up --abort-on-container-exit
