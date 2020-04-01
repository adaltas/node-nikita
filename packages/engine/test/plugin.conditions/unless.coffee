
nikita = require '../../src'

describe 'plugin.condition unless', ->

  it 'skip if `true`', ->
    nikita.call
      unless: true
      handler: -> throw Error 'You are not welcome here'

  it 'skip if all true', ->
    nikita .call
      unless: [true, true, true]
      handler: -> throw Error 'You are not welcome here'

  it 'skip if at least one is true', ->
    nikita.call
      unless: [false, true, false]
      handler: -> throw Error 'You are not welcome here'

  it 'run if all false', ->
    nikita.call
      unless: [false, false, false]
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'skip if `1`', ->
    nikita.call
      unless: 1
      handler: -> throw Error 'You are not welcome here'

  it 'run if `0`', ->
    nikita.call
      unless: 0
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'succeed if buffer and length > 1', ->
    nikita.call
      unless: Buffer.from 'abc'
      handler: -> throw Error 'You are not welcome here'

  it 'run if buffer and length is 0', ->
    nikita.call
      unless: Buffer.from ''
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'run if `false`', ->
    nikita.call
      unless: false
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'run if `null`', ->
    nikita.call
      unless: null
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'skip if string not empty', ->
    nikita.call
      unless: 'abc'
      handler: -> throw Error 'You are not welcome here'
  
  describe 'object', ->

    it 'skip if `{k:v}`', ->
      nikita.call
        unless: {k:"v"}
        handler: -> throw Error 'You are not welcome here'

    it 'run if `{}`', ->
      nikita.call
        unless: {}
        handler: -> 'called'
      .should.be.finally.eql 'called'
  
  describe 'function', ->

    it 'run if string empty', ->
      nikita.call
        unless: ''
        handler: -> 'called'
      .should.be.finally.eql 'called'

    it 'skip on `positive` callback', ->
      nikita.call
        unless: ->
          new Promise (accept, reject) -> accept true
        handler: -> throw Error 'You are not welcome here'

    it 'run on `negative` callback', ->
      nikita.call
        unless: ->
          new Promise (accept, reject) -> accept false
        handler: -> 'called'
      .should.finally.eql 'called'

    it 'function pass error object on `failed` callback', ->
      nikita.call
        unless: ->
          new Promise (accept, reject) ->
            reject Error 'Cool'
        handler: -> throw Error 'You are not welcome here'
      .should.rejectedWith 'Cool'
