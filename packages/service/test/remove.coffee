
nikita = require '@nikitajs/engine/lib'
{tags, ssh, service} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.service_install

describe 'service.remove', ->
  
  @timeout 20000

  they 'new package', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @service.install
        name: service.name
      {status} = await @service.remove
        name: service.name
      status.should.be.true()
      {status} = await @service.remove
        name: service.name
      status.should.be.false()
