#!/bin/bash
HOME=`pwd`/`dirname ${BASH_SOURCE}`

cd $HOME/ubuntu
docker-compose up --abort-on-container-exit
