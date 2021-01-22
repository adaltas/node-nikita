#!/bin/bash

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee start.coffee
lxc exec nikita-tools-rubygems bash <<EOF
cd /nikita/packages/tools
npx mocha 'test/**/*.coffee'
EOF
