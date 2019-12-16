
nikita = require '../../src'
{tags, ssh} = require '../test'
# All test are executed with an ssh connection passed as an argument
they = require('ssh2-they').configure ssh.filter( (ssh) -> !!ssh )...

return unless tags.posix

describe 'ssh.close', ->

  they 'check status', ({ssh}) ->
    nikita
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
    .ssh.close (err, {status}) ->
      status.should.be.true() unless err
    .ssh.close (err, {status}) ->
      status.should.be.false() unless err
    .promise()
