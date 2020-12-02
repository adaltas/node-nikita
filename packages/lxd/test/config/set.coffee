
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before () ->
  await nikita
  .execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.config.set', ->

  they 'Set multiple keys', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      {status} = await @lxd.config.set
        config:
          container: 'c1'
          config:
            'environment.MY_KEY_1': 'my value 1'
            'environment.MY_KEY_2': 'my value 2'
      status.should.be.true()
      await @lxd.start
        container: 'c1'
      {stdout} = await @execute
        command: "lxc exec c1 -- env | grep MY_KEY_1"
        trim: true
      stdout.should.eql 'MY_KEY_1=my value 1'
      {stdout} = await @execute
        command: "lxc exec c1 -- env | grep MY_KEY_2"
        trim: true
      stdout.should.eql 'MY_KEY_2=my value 2'

  they 'Does not set the same configuration', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      {status} = await @lxd.config.set
        config:
          container: 'c1'
          config:
            'environment.MY_KEY_1': 'my value 1'
      status.should.be.true()
      {status} = await @lxd.config.set
        config:
          container: 'c1'
          config:
            'environment.MY_KEY_1': 'my value 1'
      status.should.be.false()
