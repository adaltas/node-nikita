
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'system.execute.assert', ->

  they 'assert stdout match content', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute.assert
      cmd: 'text=hello; echo $text'
      content: 'hello\n'
    .system.execute.assert
      cmd: 'text=hello; echo $text'
      content: 'hello'
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid content: expect "hello" and got "hello\\n"'
    .promise()

  they 'assert stdout match regexp', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute.assert
      cmd: "echo \"toto\nest\r\nau\rbistrot\""
      content: /^bistrot$/m
    .system.execute.assert
      cmd: "echo \"toto\nest\r\nau\rbistrot\""
      content: /^ohno$/m
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid content match'
    .promise()

  they 'option trim on cmd', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute.assert
      cmd: "echo '' && echo 'yo'"
      content: 'yo'
      trim: true
    .promise()

  they 'option trim on content', ({ssh}) ->
    nikita
      ssh: ssh
      bash: true
    .system.execute.assert
      cmd: "echo -n 'yo'"
      content: '\nyo\n'
      trim: true
    .promise()
