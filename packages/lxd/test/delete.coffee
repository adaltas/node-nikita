
nikita = require '@nikitajs/core'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.delete', ->

  they 'Delete a container', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.init
      image: 'ubuntu:'
      name: 'container1'
    .lxd.delete
      name: 'container1'
    , (err, {status}) ->
      status.should.be.true()
    .promise()


  they 'Force deletion of a running container', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.init
      image: 'ubuntu:'
      name: 'container1'
    .lxd.start
      name: 'container1'
    .lxd.delete
      name: 'container1'
      force: true
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Not found', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete  # repeated to be sure the container is absent
      name: 'container1'
    .lxd.delete
      name: 'container1'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
