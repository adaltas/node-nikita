
conditions = require '../../src/misc/conditions'

describe 'conditions', ->

  describe 'mix', ->

    it 'bypass if not present', (next) ->
      conditions.all {}, {},
        next
        () -> false.should.be.true()

    it 'handle multiple conditions (1st failed)', (next) ->
      conditions.all {},
        if: false
        unless: false
        () -> false.should.be.true()
        next

    it 'handle multiple conditions (all ok with undefined)', (next) ->
      conditions.all {},
        if: true
        unless: undefined
        next
        () -> false.should.be.true()

    it 'handle multiple conditions (2nd failed)', (next) ->
      conditions.all {},
        if: true
        unless: true
        () -> false.should.be.true()
        next

    it 'handle multiple conditions (all ok)', (next) ->
      conditions.all {},
        if: true
        unless: [false, false]
        next
        () -> false.should.be.true()

    it 'handle multiple conditions (one not fail)', (next) ->
      conditions.all {},
        if: undefined
        if_exists: undefined
        unless: undefined
        () -> false.should.be.true()
        next

    it 'handle multiple conditions (one not fail)', (next) ->
      conditions.all {},
        if: true
        unless: [false, true, false]
        () -> false.should.be.true()
        next

    it 'ensure an option all doesnt conflict', (next) ->
      conditions.all {},
        all: 'this is messy'
        next
        () -> false.should.be.true()
