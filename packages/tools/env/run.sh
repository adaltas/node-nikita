#!/bin/bash

PWD=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $PWD/apm/start.coffee
lxc exec tools-apm --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

npx coffee $PWD/iptables/start.coffee
lxc exec tools-iptables --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

npx coffee $PWD/npm/start.coffee
lxc exec tools-npm --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

npx coffee $PWD/rubygems.lxd/start.coffee
lxc exec tools-rubygems --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

cd $PWD/centos6
docker-compose up --abort-on-container-exit

cd $PWD/centos7
docker-compose up --abort-on-container-exit

cd $PWD/cron
docker-compose up --abort-on-container-exit

cd $PWD/dconf
docker-compose up --abort-on-container-exit

cd $PWD/rubygems
docker-compose up --abort-on-container-exit
