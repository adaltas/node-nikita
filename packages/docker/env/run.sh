#!/bin/bash

ENV_DIR=`pwd`/`dirname ${BASH_SOURCE}`

cd $ENV_DIR/docker
docker-compose up --abort-on-container-exit
