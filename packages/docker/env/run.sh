#!/bin/bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./docker/run.sh
