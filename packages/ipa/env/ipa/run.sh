#!/bin/bash

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee start.coffee
lxc exec \
  --cwd /nikita/packages/ipa \
  nikita-ipa -- \
  bash -l -c "npm run test:local"
# lxc stop nikita-ipa
