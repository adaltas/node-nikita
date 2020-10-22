#!/bin/bash

HOME=`pwd`/`dirname ${BASH_SOURCE}`

npx coffee $HOME/rubygems/start.coffee
lxc exec tools-rubygems --cwd /nikita/packages/tools npm test
lxc exec tools-rubygems --cwd /nikita/packages/tools apm test
