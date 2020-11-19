#!/bin/bash

PWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $PWD/krb5
docker-compose up --abort-on-container-exit
