#!/bin/bash

npx coffee `dirname ${BASH_SOURCE}`/rubygems/start.coffee
lxc exec tools-rubygems --cwd /nikita/packages/tools npm test
