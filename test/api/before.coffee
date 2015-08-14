
mecano = require '../../src'
test = require '../test'

describe 'api before', ->

  scratch = test.scratch @

  it 'a sync function with sync handler', (next) ->
    history = []
    mecano()
    .register 'afunction', (options) ->
      return true
    .before 'afunction', (options) ->
      history.push 'before'
      return false
    .call ->
      history.push 'call 1'
    .afunction ->
      history.push 'touch 1'
    .call ->
      history.push 'call 2'
    .afunction ->
      history.push 'touch 2'
    .call ->
      history.push 'call 3'
    .then (err, status) ->
      history.should.eql [
        'call 1', 'before', 'touch 1'
        'call 2', 'before', 'touch 2'
        'call 3'
      ]
      next()

  it 'a sync function with async handler', (next) ->
    history = []
    mecano()
    .register 'afunction', (options) ->
      return true
    .before 'afunction', (options, callback) ->
      setImmediate ->
        history.push 'before'
        callback null, false
    .call ->
      history.push 'call 1'
    .afunction ->
      history.push 'touch 1'
    .call ->
      history.push 'call 2'
    .afunction ->
      history.push 'touch 2'
    .call ->
      history.push 'call 3'
    .then (err, status) ->
      history.should.eql [
        'call 1', 'before', 'touch 1'
        'call 2', 'before', 'touch 2'
        'call 3'
      ]
      next()

  it 'an async function with sync handler', (next) ->
    history = []
    mecano
    .before 'touch', (options) ->
      history.push 'before'
      return false
    .call ->
      history.push 'call 1'
    .touch
      destination: "#{scratch}/a_file"
    , ->
      history.push 'touch 1'
    .call ->
      history.push 'call 2'
    .touch
      destination: "#{scratch}/a_file"
    , ->
      history.push 'touch 2'
    .call ->
      history.push 'call 3'
    .then (err, status) ->
      history.should.eql [
        'call 1', 'before', 'touch 1'
        'call 2', 'before', 'touch 2'
        'call 3'
      ]
      next()

  it 'an async function with async handler', (next) ->
    history = []
    mecano
    .before 'touch', (options, callback) ->
      setImmediate ->
        history.push 'before'
        callback null, false
    .call ->
      history.push 'call 1'
    .touch
      destination: "#{scratch}/a_file"
    , ->
      history.push 'touch 1'
    .call ->
      history.push 'call 2'
    .touch
      destination: "#{scratch}/a_file"
    , ->
      history.push 'touch 2'
    .call ->
      history.push 'call 3'
    .then (err, status) ->
      history.should.eql [
        'call 1', 'before', 'touch 1'
        'call 2', 'before', 'touch 2'
        'call 3'
      ]
      next()