#!/bin/bash

PWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $PWD/openldap
docker-compose up --abort-on-container-exit
