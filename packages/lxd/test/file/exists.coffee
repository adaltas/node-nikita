
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before () ->
  await nikita
  .execute
    cmd: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.file.exists', ->

  they 'when present', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      @lxd.start
        container: 'c1'
      @execute
        cmd: "lxc exec c1 -- touch /root/a_file"
      {status} = await @lxd.file.exists
        container: 'c1'
        target: '/root/a_file'
      status.should.be.true()
  

  they 'when missing', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      @lxd.start
        container: 'c1'
      {status} = await @lxd.file.exists
        container: 'c1'
        target: '/root/a_file'
      status.should.be.false()
  
