#!/bin/bash

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee start.coffee
lxc exec \
  --cwd /nikita/packages/system \
  nikita-system-authconfig -- \
  bash -l -c "npm run test:local"
lxc stop nikita-system-authconfig
