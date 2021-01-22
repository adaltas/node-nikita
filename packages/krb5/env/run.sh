#!/bin/bash
set -e

CWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $CWD/krb5
docker-compose up --abort-on-container-exit
