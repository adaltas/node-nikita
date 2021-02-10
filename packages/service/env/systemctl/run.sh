#!/bin/bash

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee start.coffee
lxc exec nikita-service-systemctl bash <<EOF
cd /nikita/packages/service
npx mocha 'test/**/*.coffee'
EOF
