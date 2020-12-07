#!/bin/bash

CWD=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $CWD/apm/start.coffee
lxc exec tools-apm --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

npx coffee $CWD/iptables/start.coffee
lxc exec tools-iptables --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

npx coffee $CWD/npm/start.coffee
lxc exec tools-npm --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

npx coffee $CWD/rubygems.lxd/start.coffee
lxc exec tools-rubygems --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

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
