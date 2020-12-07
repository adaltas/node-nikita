#!/bin/bash

ENV_DIR=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $ENV_DIR/apm/start.coffee
lxc exec tools-apm --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

npx coffee $ENV_DIR/iptables/start.coffee
lxc exec tools-iptables --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

npx coffee $ENV_DIR/npm/start.coffee
lxc exec tools-npm --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

npx coffee $ENV_DIR/rubygems.lxd/start.coffee
lxc exec tools-rubygems --cwd /nikita/packages/tools npx mocha 'test/**/*.coffee'

# cd $ENV_DIR/centos6
# docker-compose up --abort-on-container-exit

cd $ENV_DIR/centos7
docker-compose up --abort-on-container-exit

cd $ENV_DIR/cron
docker-compose up --abort-on-container-exit

# cd $ENV_DIR/dconf
# docker-compose up --abort-on-container-exit

cd $ENV_DIR/rubygems
docker-compose up --abort-on-container-exit
