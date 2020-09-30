
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.lxd
  
before () ->
  nikita
  .system.execute
    cmd: "lxc image copy ubuntu:18.04 `lxc remote get-default`:"
  .system.execute
    cmd: "lxc image copy ubuntu:18.04 `lxc remote get-default`:"
  .promise()

describe 'lxd.init', ->

  they 'Init new container', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'u1'
      force: true
    .lxd.init
      image: 'ubuntu:'
      container: 'u1'
      ephemeral: false
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Container already exist', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'u1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'u1'
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'u1'
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  they 'Init new VM', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'vm1'
      force: true
    .lxd.init
      image: 'ubuntu:'
      container: 'vm1'
      ephemeral: false
      vm: true
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'VM already exist', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'vm1'
      force: true
    .lxd.init
      image: 'ubuntu:'
      container: 'vm1'
      vm: true
    .lxd.init
      image: 'ubuntu:'
      container: 'vm1'
      vm: true
    , (err, {status}) ->
      status.should.be.false()
    .promise()