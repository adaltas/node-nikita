
{tags} = require '../../test'
nikita = require '../../../lib'

describe 'plugins.metadata.sleep (plugin.retry)', ->
  return unless tags.api
  
  describe 'validation', ->
    
    it 'ensure sleep equals or is greater than 0', ->
      nikita
      .call $sleep: 0, (->)
      .call $sleep: 1, (->)
      .call $sleep: -1, (->)
      .should.be.rejectedWith [
        'METADATA_SLEEP_INVALID_RANGE:'
        'configuration `sleep` expect a number above or equal to 0,'
        'got -1.'
      ].join ' '
  
    # TODO once the sleep metadata is implemented with schema
    it.skip 'ensure sleep is a number', ->
      nikita
      .call sleep: 'a string', (->)
      .next (err) ->
        err.message.should.eql 'Invalid config sleep, got "a string"'
      .promise()
  
  describe 'handler', ->

    it 'is a metadata', ->
      nikita.call $sleep: 1000, ({metadata}) ->
        metadata.sleep.should.eql 1000
    
    it 'enforce default to 3s', ->
      now = Date.now()
      nikita
      .call $retry: 2, ->
        throw Error 'Catchme'
      .catch (err) ->
        (Date.now() - now).should.be.above 3000
        (Date.now() - now).should.be.below 3500

    it 'is set by user', ->
      times = []
      nikita
      .call $sleep: 100, $retry: 2, ->
        times.push Date.now()
        throw Error 'Catchme'
      .catch (err) ->
        times.length.should.eql 2
        (times[1] - times[0]).should.be.above 95
        (times[1] - times[0]).should.be.below 180
    
