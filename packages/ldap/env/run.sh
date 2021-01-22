#!/bin/bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./openldap/run.sh
