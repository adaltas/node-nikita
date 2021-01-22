#!/bin/bash
set -e

CWD=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $CWD/ipa/start.coffee
lxc exec nikita-ipa bash <<EOF
cd /nikita/packages/ipa
npx mocha 'test/**/*.coffee'
EOF
