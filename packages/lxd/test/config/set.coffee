
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.config.set', ->

  they 'when created', ({ssh}) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.init
      image: 'ubuntu:18.04'
      name: 'c1'
    .lxd.config.set
      name: 'c1'
      config:
        'environment.MY_KEY': 'my value'
    .lxd.start
      name: 'c1'
    .system.execute
      cmd: "lxc exec c1 -- env | grep MY_KEY"
      trim: true
    , (err, {stdout}) ->
      stdout.should.eql 'MY_KEY=my value'
    .promise()
