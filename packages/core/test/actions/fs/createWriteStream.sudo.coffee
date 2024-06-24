
import exec from 'ssh2-exec/promises'
import nikita from '@nikitajs/core'
import utils from '@nikitajs/core/utils'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.createWriteStream.sudo', ->
  return unless test.tags.sudo

  they 'write a file', ({ssh}) ->
    nikita
      $ssh: ssh
      $sudo: true
      $tmpdir: true
    , ({metadata: {tmpdir}, ssh}) ->
      await @fs.createWriteStream
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
      await @fs.createWriteStream
        target: "#{tmpdir}/a_file"
        stream: (ws) ->
          ws.write 'hello'
          ws.end()
      await @fs.createWriteStream
        flags: 'a'
        target: "#{tmpdir}/a_file"
        stream: (ws) ->
          ws.write '...nikita'
          ws.end()
      exec ssh, "sudo cat #{tmpdir}/a_file"
      .should.be.finally.match stdout: 'hello...nikita'
      
