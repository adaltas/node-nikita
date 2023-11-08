#!/usr/bin/env bash

cd `pwd`/`dirname ${BASH_SOURCE}`
# Note, krb5 print multiple informaiton and warnings,
# we use `--attach` to restrict attaching to the specified services,
# disabling logging for other services
docker compose up --abort-on-container-exit --attach nodejs
