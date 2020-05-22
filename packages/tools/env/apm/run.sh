#!/bin/bash

HOME=`pwd`/`dirname ${BASH_SOURCE}`

# Launch linux container described in packages/tools/env/apm/start.coffee
npx coffee $HOME/start.coffee

# Execute apm tests in the just launched linux conainer
lxc exec tools-apm bash <<EOF
cd /nikita/packages/tools
npm build && npx mocha test/apm/*.coffee
EOF
