#!/bin/bash
set -e

CWD=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $CWD/apm/start.coffee
lxc exec nikita-tools-apm bash <<EOF
cd /nikita/packages/tools
npx mocha 'test/**/*.coffee'
EOF

npx coffee $CWD/iptables/start.coffee
lxc exec nikita-tools-iptables bash <<EOF
cd /nikita/packages/tools
npx mocha 'test/**/*.coffee'
EOF

npx coffee $CWD/npm/start.coffee
lxc exec nikita-tools-npm bash <<EOF
cd /nikita/packages/tools
npx mocha 'test/**/*.coffee'
EOF

npx coffee $CWD/rubygems.lxd/start.coffee
lxc exec nikita-tools-rubygems bash <<EOF
cd /nikita/packages/tools
npx mocha 'test/**/*.coffee'
EOF

# cd $CWD/centos6
# docker-compose up --abort-on-container-exit

cd $CWD/centos7
docker-compose up --abort-on-container-exit

cd $CWD/cron
docker-compose up --abort-on-container-exit

# cd $CWD/dconf
# docker-compose up --abort-on-container-exit

cd $CWD/rubygems
docker-compose up --abort-on-container-exit
