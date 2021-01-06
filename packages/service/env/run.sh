#!/bin/bash

CWD=`pwd`/`dirname ${BASH_SOURCE}`

cd $CWD/archlinux
docker-compose up --abort-on-container-exit

# CentOS 6 reach end of life,
# we couldn't find how to get the repo working with yum update
# cd $CWD/centos6
# docker-compose up --abort-on-container-exit

cd $CWD/centos7
docker-compose up --abort-on-container-exit

# cd $CWD/systemctl
# docker-compose up --abort-on-container-exit
npx coffee $CWD/systemctl/start.coffee
lxc exec nikita-service-systemctl bash <<EOF
cd /nikita/packages/service
npx mocha 'test/**/*.coffee'
EOF

cd $CWD/ubuntu
docker-compose up --abort-on-container-exit
