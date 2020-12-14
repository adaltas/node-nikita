
fs = require 'fs'
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.log.csv', ->
  
  they 'write message', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @log.csv basedir: tmpdir
      @call ({tools: {log}}) -> log 'ok'
      {data} = await @fs.base.readFile "#{tmpdir}/localhost.log", encoding: 'ascii'
      data.should.eql 'text,INFO,"ok"\n'

  they 'write header', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @log.csv basedir: tmpdir
      @call header: 'h1', ({tools: {log}}) -> true
      {data} = await @fs.base.readFile "#{tmpdir}/localhost.log", encoding: 'ascii'
      data.should.eql 'header,,"h1"\n'
    
