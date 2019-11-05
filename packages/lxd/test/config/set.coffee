
nikita = require '@nikitajs/core'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.config.set', ->

  they 'multiple keys', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'c1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'c1'
    .lxd.config.set
      container: 'c1'
      config:
        'environment.MY_KEY_1': 'my value 1'
        'environment.MY_KEY_2': 'my value 2'
    .lxd.start
      container: 'c1'
    .system.execute
      cmd: "lxc exec c1 -- env | grep MY_KEY_1"
      trim: true
    , (err, {stdout}) ->
      stdout.should.eql 'MY_KEY_1=my value 1'
    .system.execute
      cmd: "lxc exec c1 -- env | grep MY_KEY_2"
      trim: true
    , (err, {stdout}) ->
      stdout.should.eql 'MY_KEY_2=my value 2'
    .promise()
