#!/bin/bash

HOME=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $HOME/ipa/start.coffee
lxc exec freeipa bash <<EOF
cd /nikita/packages/ipa
npm test
EOF
