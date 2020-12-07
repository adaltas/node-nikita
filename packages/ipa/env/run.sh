#!/bin/bash

CWD=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $CWD/ipa/start.coffee
lxc exec freeipa --cwd /nikita/packages/ipa npx mocha 'test/**/*.coffee'
