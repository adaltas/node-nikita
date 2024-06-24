
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'log.csv', ->
  return unless test.tags.posix
  
  they 'write message', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @log.csv basedir: tmpdir
      await @call ({tools: {log}}) -> log 'ok'
      {data} = await @fs.readFile "#{tmpdir}/#{ssh?.host or 'local'}.log", encoding: 'ascii'
      data.should.eql 'text,INFO,"ok"\n'

  they 'write header', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @log.csv basedir: tmpdir
      await @call $header: 'h1', ({tools: {log}}) -> true
      {data} = await @fs.readFile "#{tmpdir}/#{ssh?.host or 'local'}.log", encoding: 'ascii'
      data.should.eql 'header,,"h1"\n'
    
