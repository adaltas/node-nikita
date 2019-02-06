
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'ssh.close', ->

  they 'check status', (ssh) ->
    return @skip() unless ssh
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
