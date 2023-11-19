
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.output.logs', ->
  return unless test.tags.api
  
  it 'return logs', ->
    nikita ->
      {$logs} = await @call ({tools: {log}}) ->
        log key: 'value'
        true
      $logs.some (log) ->
        log.type is 'text' and log.key is 'value'
      .should.be.true()
        
  it 'dont alter file and filename', ->
    nikita ->
      {$logs} = await @call ({tools: {log}}) ->
        log key: 'value'
        true
      $logs.some (log) ->
        log.file.should.eql 'logs.coffee'
        log.filename.should.match /output\/logs\.coffee$/
        
  it 'return logs in error', ->
    nikita ->
      try
        await @call ({tools: {log}}) ->
          log key: 'value'
          throw Error 'catchme'
      catch err
        err.message.should.eql 'catchme'
        err.$logs.some (log) ->
          log.type is 'text' and log.key is 'value'
        .should.be.true()
