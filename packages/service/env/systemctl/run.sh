#!/bin/bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee start.coffee
lxc exec \
  --cwd /nikita/packages/service \
  nikita-service-systemctl -- \
  bash -l -c "npm run test:local"
lxc stop nikita-service-systemctl
