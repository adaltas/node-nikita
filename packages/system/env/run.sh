#!/bin/bash

set -e

CWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $CWD/tmpfs
docker-compose up --abort-on-container-exit

