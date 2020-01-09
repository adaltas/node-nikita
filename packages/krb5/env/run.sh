#!/bin/bash

HOME=`pwd dirname "${BASH_SOURCE}"`

cd $HOME/krb5
docker-compose up --abort-on-container-exit
