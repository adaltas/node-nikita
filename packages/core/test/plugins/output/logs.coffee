
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.output.logs', ->
  return tags.api
  
  it 'return logs', ->
    nikita ->
      {logs} = await @call ({tools: {log}}) ->
        log key: 'value'
        true
      logs.some (log) ->
        log.type is 'text' and log.key is 'value'
      .should.be.true()
        
  it 'argument is immutable', ->
    arg = key: 'value'
    {logs} = await nikita.call ({tools: {log}}) ->
      log arg
      true
    arg.should.eql key: 'value'
        
  it 'dont alter file and filename', ->
    nikita ->
      {logs} = await @call ({tools: {log}}) ->
        log key: 'value'
        true
      logs.some (log) ->
        log.file.should.eql 'logs.coffee'
        log.filename.should.eql __filename
