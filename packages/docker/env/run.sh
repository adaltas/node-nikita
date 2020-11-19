#!/bin/bash

PWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $PWD/docker
docker-compose up --abort-on-container-exit
