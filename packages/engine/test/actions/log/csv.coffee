
fs = require 'fs'
nikita = require '../../../src'
{tags, ssh, scratch} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.log.csv', ->
  
  they 'write message', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @log.csv basedir: tmpdir
      @call ({log}) -> log 'ok'
      # .file.assert
      #   source: "#{scratch}/localhost.log"
      #   content: /^text,INFO,"ok"\n/
      #   trim: true
      #   log: false
      # .assert status: false
      @fs.base.readFile
        target: "#{tmpdir}/localhost.log"
        content: 'text,INFO,"ok"\n'

  they 'write header', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @log.csv basedir: tmpdir
      @call header: 'h1', ({log}) -> true
      @fs.base.readFile
        target: "#{tmpdir}/localhost.log"
        content: 'header,,"h1"\n'
    
