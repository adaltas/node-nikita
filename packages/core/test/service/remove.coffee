
nikita = require '../../src'
{tags, ssh, service} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.service_install

describe 'service.remove', ->
  
  @timeout 20000

  they 'new package', ({ssh}) ->
    nikita
      ssh: ssh
    .service.install
      name: service.name
    .service.remove
      name: service.name
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.remove
      name: service.name
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
