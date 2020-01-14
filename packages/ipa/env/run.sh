#!/bin/bash
HOME=`pwd dirname "${BASH_SOURCE}"`

coffee ipa/start.coffee
lxc exec authconfig bash <<EOF
cd /nikita/packages/core
npm test
EOF
