
nikita = require '@nikitajs/engine/lib'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita
  .execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

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
        command: "lxc exec c1 -- touch /root/a_file"
      {exists} = await @lxd.file.exists
        container: 'c1'
        target: '/root/a_file'
      exists.should.be.true()
  

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
      {exists} = await @lxd.file.exists
        container: 'c1'
        target: '/root/a_file'
      exists.should.be.false()
  
