
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.service_install

describe 'service.discover', ->
  
  they 'output loader', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {loader} = await @service.discover()
      loader.should.be.oneOf('systemctl', 'service')
