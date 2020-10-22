#!/bin/bash

HOME=`pwd`/`dirname ${BASH_SOURCE}`

cd $HOME/docker
docker-compose up --abort-on-container-exit
