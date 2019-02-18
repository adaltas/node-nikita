
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ruby} = require '../test'
they = require('ssh2-they').configure ssh...

describe 'tools.ssh.keygen', ->

  they 'a new key', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.ssh.keygen
      target: "#{scratch}/folder/id_rsa"
      bits: 2048
      comment: 'nikita'
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.ssh.keygen
      target: "#{scratch}/folder/id_rsa"
      bits: 2048
      comment: 'nikita'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
    
