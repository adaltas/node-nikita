#!/bin/bash

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee start.coffee
lxc exec \
  --user 1234 \
  --cwd /nikita/packages/core \
  --env HOME=/home/source \
  nikita-core-ssh -- \
  bash -l -c "npx mocha 'test/**/*.coffee'"
