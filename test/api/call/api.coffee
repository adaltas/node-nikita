
nikita = require '../../../src'

describe 'api call', ->

  it 'accept an array of handlers and a callback', ->
    logs = []
    nikita
    .system.remove target: "/tmp/nikita-test"
    .call [
      -> logs.push 'a'
    ,
      ({}, callback) -> logs.push('b'); callback()
    ], (err, {status}) ->
      logs.push 'c'
      status.should.be.false() unless err
    .call ->
      logs.should.eql ['a', 'c', 'b', 'c']
    .promise()

  it.skip 'accept a string and an handler', ->
    # No longer supported with the current implementation
    # Was working before but it seems really awkward as it
    # would imply having different behavior when a handler is provided
    # as a function or as a value assiated to the handler key
    nikita()
    .call 'gotit',
      handler: ({options}) -> options.argument.should.eql 'gotit'
    .promise()
