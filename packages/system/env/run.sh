#!/bin/bash

set -e

CWD=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $CWD/authconfig/start.coffee
lxc exec nikita-system-authconfig bash <<EOF
cd /nikita/packages/system
npx mocha 'test/**/*.coffee'
EOF

cd $CWD/tmpfs
docker-compose up --abort-on-container-exit

