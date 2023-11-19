#!/usr/bin/env bash

cd `pwd`/`dirname ${BASH_SOURCE}`
# Use `--attach` to restrict attaching to the specified services,
# disabling logging for other services
docker compose up --abort-on-container-exit --attach nodejs
