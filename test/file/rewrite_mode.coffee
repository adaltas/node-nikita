
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'

describe 'file', ->

  scratch = test.scratch @
  
  describe 'mode and rewrite', ->
    they.skip 'rewrite', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'this is\r\nsome content'
        mode: 0o0755
      .file
        target: "#{scratch}/file"
        content: """
          #!/bin/bash
          echo hello
          """
        backup: true
        mode: 0o0755
      .system.execute
        cmd: "./#{scratch}/file"
      , (err, {status, stdout}) ->
          throw err if err
          stdout.should.eql 'hello'
      .promise()
