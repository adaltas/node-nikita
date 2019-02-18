
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.ini option stringify_square_then_curly', ->

  they 'call stringify udf', ({ssh}) ->
    nikita
      ssh: ssh
    .file.ini
      stringify: misc.ini.stringify_square_then_curly
      target: "#{scratch}/user.ini"
      content: user: preference: color: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user]\n preference = {\n  color = true\n }\n\n'
    .promise()

  they 'convert array to multiple keys', ({ssh}) ->
    nikita
      ssh: ssh
    # Create a new file
    .file.ini
      stringify: misc.ini.stringify_square_then_curly
      target: "#{scratch}/user.ini"
      content: user: preference: language: ['c', 'c++', 'ada']
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user]\n preference = {\n  language = c\n  language = c++\n  language = ada\n }\n\n'
    # Modify an existing file
    # TODO: merge is not supported
    .promise()
