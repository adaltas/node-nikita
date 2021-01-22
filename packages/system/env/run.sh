#!/bin/bash

set -e

CWD=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $CWD/authconfig/start.coffee
lxc exec nikita-system-authconfig bash <<EOF
cd /nikita/packages/system
npx mocha 'test/**/*.coffee'
EOF

cd $CWD/cgroups
docker-compose up --abort-on-container-exit

cd $CWD/info_archlinux
docker-compose up --abort-on-container-exit

cd $CWD/info_centos6
docker-compose up --abort-on-container-exit

cd $CWD/info_centos7
docker-compose up --abort-on-container-exit

cd $CWD/info_ubuntu
docker-compose up --abort-on-container-exit

cd $CWD/limits
docker-compose up --abort-on-container-exit

cd $CWD/tmpfs
docker-compose up --abort-on-container-exit

cd $CWD/user
docker-compose up --abort-on-container-exit
