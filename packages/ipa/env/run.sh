#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

node ./ipa/index.js run
