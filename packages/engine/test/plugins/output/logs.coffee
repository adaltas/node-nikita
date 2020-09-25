
nikita = require '../../../src'

describe 'plugins.output.logs', ->
  
  it 'return logs', ->
    nikita ->
      {logs} = await @call ({log}) ->
        log key: 'value'
        true
      logs.some (log) ->
        log.type is 'text' and log.key is 'value'
      .should.be.true()
        
  it 'argument is immutable', ->
    arg = key: 'value'
    {logs} = await nikita.call ({log}) ->
      log arg
      true
    arg.should.eql key: 'value'
        
  it 'dont alter file and filename', ->
    nikita ->
      {logs} = await @call ({log}) ->
        log key: 'value'
        true
      logs.some (log) ->
        log.file.should.eql 'logs.coffee'
        log.filename.should.eql __filename
