#!/bin/bash

HOME=`pwd`/`dirname ${BASH_SOURCE}`

cd $HOME/openldap
docker-compose up --abort-on-container-exit
