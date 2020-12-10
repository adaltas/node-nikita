#!/bin/bash

CWD=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $CWD/ipa/start.coffee
lxc exec freeipa bash <<EOF
cd /nikita/packages/ipa
npx mocha 'test/**/*.coffee'
EOF
