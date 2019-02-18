
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.types.my_cnf', ->

  they 'generate from content', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.my_cnf
      target: "#{scratch}/my.cnf"
      content:
        'client':
          'socket': '/var/lib/mysql/mysql.sock'
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/my.cnf"
      content: """
      [client]
      socket = /var/lib/mysql/mysql.sock
      """
      trim: true
    .promise()
