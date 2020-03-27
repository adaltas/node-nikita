
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.service.exists', ->

  they 'service doesnt exist', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.service.del connection: ipa,
      principal: 'service_exists/freeipa.nikita.local'
    .ipa.service.exists connection: ipa,
      principal: 'service_exists/freeipa.nikita.local'
    , (err, {status, exists}) ->
      status.should.be.false() unless err
      exists.should.be.false() unless err
    .promise()

  they 'service exists', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.service connection: ipa,
      principal: 'service_exists/freeipa.nikita.local'
    .ipa.service.exists connection: ipa,
      principal: 'service_exists/freeipa.nikita.local'
    , (err, {status, exists}) ->
      status.should.be.true() unless err
      exists.should.be.true() unless err
    .ipa.service.del connection: ipa,
      principal: 'service_exists/freeipa.nikita.local'
    .promise()
