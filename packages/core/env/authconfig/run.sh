#!/bin/bash

lxc exec authconfig bash <<EOF
cd /nikita/packages/core
npm test
EOF
