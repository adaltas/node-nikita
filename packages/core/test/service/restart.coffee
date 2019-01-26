
nikita = require '../../src'
{tags, ssh, service} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.service_systemctl

describe 'service.restart', ->
  
  @timeout 20000

  they 'should restart', (ssh) ->
    nikita
      ssh: ssh
    .service
      name: service.name
    .service.start
      name: service.srv_name
    .service.restart
      name: service.srv_name
    , (err, {status}) ->
      status.should.be.true()
    .promise()
