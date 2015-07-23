
conditions = require '../../src/misc/conditions'

describe 'conditions', ->

  describe 'mix', ->

    it 'bypass if not present', (next) ->
      conditions.all {}, {},
        () -> false.should.be.true()
        next

    it 'handle multiple conditions (1st failed)', (next) ->
      conditions.all {},
        if: false
        not_if: false
        next
        () -> false.should.be.true()

    it 'handle multiple conditions (all ok with undefined)', (next) ->
      conditions.all {},
        if: true
        not_if: undefined
        () -> false.should.be.true()
        next

    it 'handle multiple conditions (2nd failed)', (next) ->
      conditions.all {},
        if: true
        not_if: true
        next
        () -> false.should.be.true()

    it 'handle multiple conditions (all ok)', (next) ->
      conditions.all {},
        if: true
        not_if: [false, false]
        () -> false.should.be.true()
        next

    it 'handle multiple conditions (one not fail)', (next) ->
      conditions.all {},
        if: undefined
        if_exists: undefined
        not_if: undefined
        next
        () -> false.should.be.true()

    it 'handle multiple conditions (one not fail)', (next) ->
      conditions.all {},
        if: true
        not_if: [false, true, false]
        next
        () -> false.should.be.true()
