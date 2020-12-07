#!/bin/bash

ENV_DIR=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $ENV_DIR/ipa/start.coffee
lxc exec freeipa --cwd /nikita/packages/ipa npx mocha 'test/**/*.coffee'
