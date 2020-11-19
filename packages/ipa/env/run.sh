#!/bin/bash

PWD=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $PWD/ipa/start.coffee
lxc exec freeipa bash <<EOF
cd /nikita/packages/ipa
npm test
EOF
