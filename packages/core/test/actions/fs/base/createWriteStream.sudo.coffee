
nikita = require '../../../../lib'
utils = require '../../../../lib/utils'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)
exec = require 'ssh2-exec/promise'

return unless tags.sudo

describe 'actions.fs.base.createWriteStream.sudo', ->

    they 'write a file', ({ssh}) ->
      nikita
        $ssh: ssh
        $sudo: true
        $tmpdir: true
      , ({metadata: {tmpdir}, ssh}) ->
        await @fs.base.createWriteStream
          target: "#{tmpdir}/a_file"
          stream: (ws) ->
            ws.write 'hello'
            ws.end()
        exec ssh, "sudo cat #{tmpdir}/a_file"
        .should.be.finally.match stdout: 'hello'

    they 'append a file', ({ssh}) ->
      nikita
        $ssh: ssh
        $sudo: true
        $tmpdir: true
      , ({metadata: {tmpdir}, ssh}) ->
        await @fs.base.createWriteStream
          target: "#{tmpdir}/a_file"
          stream: (ws) ->
            ws.write 'hello'
            ws.end()
        await @fs.base.createWriteStream
          flags: 'a'
          target: "#{tmpdir}/a_file"
          stream: (ws) ->
            ws.write '...nikita'
            ws.end()
        exec ssh, "sudo cat #{tmpdir}/a_file"
        .should.be.finally.match stdout: 'hello...nikita'
        
