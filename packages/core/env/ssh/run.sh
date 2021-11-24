#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee start.coffee
lxc exec \
  --user 1234 \
  --cwd /nikita/packages/core \
  --env HOME=/home/source \
  nikita-core-ssh -- \
  bash -l -c "npm run test:local"
lxc stop nikita-core-ssh
