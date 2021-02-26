
{tags} = require '../test'
nikita = require '../../src'
registry = require '../../src/registry'

describe 'actions.assert', ->
  return unless tags.api
  
  describe 'returned value', ->

    it 'succeed only with true', ->
      nikita.assert ->
        true
      .should.be.fulfilled()
      nikita.assert ->
        false
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'cast', ->
      # String
      nikita.assert ->
        'valid'
      .should.be.fulfilled()
      nikita.assert ->
        ''
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      # Buffer
      nikita.assert ->
        Buffer.from 'valid'
      .should.be.fulfilled()
      nikita.assert ->
        Buffer.from ''
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      # Integer
      nikita.assert ->
        1
      .should.be.fulfilled()
      nikita.assert ->
        0
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      # Object literal
      nikita.assert ->
        key: 'value'
      .should.be.fulfilled()
      nikita.assert ->
        {}
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      # Null and undefined
      nikita.assert ->
        null
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      nikita.assert ->
        undefined
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'handle array', ->
      nikita.assert ->
        [true, true]
      .should.be.fulfilled()
      nikita.assert ->
        [false, true]
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'succeed when promise true is returned', ->
      nikita.assert ->
        new Promise (resolve) ->
          resolve true

    it 'fail when promise false is returned', ->
      nikita.assert ->
        new Promise (resolve) ->
          resolve false
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'multiple actions', ->
      nikita.assert [
          -> true
        ,
          -> new Promise (resolve) -> resolve true
        ]
      .should.be.fulfilled()
      nikita.assert [
          -> true
        ,
          -> new Promise (resolve) -> resolve false
        ,
          -> true
        ]
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'children must return true', ->
      nikita.assert ->
        @call [
          metadata: raw_output: true
          handler: -> true
        ,
          metadata: raw_output: true
          handler: -> new Promise (resolve) -> resolve true
        ]
      .should.be.fulfilled()
      nikita.assert ->
        @call [
          metadata: raw_output: true
          handler: -> true
        ,
          metadata: raw_output: true
          handler: -> new Promise (resolve) -> resolve false
        ]
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
    
    describe 'option `not`', ->

      it 'succeed only with false', ->
        nikita.assert not: true, ->
          false
        .should.be.fulfilled()
        nikita.assert not: true, ->
          true
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'

      it 'cast', ->
        # String
        nikita.assert not: true, ->
          'false'
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        nikita.assert not: true, ->
          ''
        .should.be.fulfilled()
        # Buffer
        nikita.assert not: true, ->
          Buffer.from 'valid'
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        nikita.assert not: true, ->
          Buffer.from ''
        .should.be.fulfilled()
        # Integer
        nikita.assert not: true, ->
          1
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        nikita.assert not: true, ->
          0
        .should.be.fulfilled()
        # Object literal
        nikita.assert not: true, ->
          key: 'value'
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        nikita.assert not: true, ->
          {}
        .should.be.fulfilled()
        # Null and undefined
        nikita.assert not: true, ->
          null
        .should.be.fulfilled()
        nikita.assert not: true, ->
          undefined
        .should.be.fulfilled()

      it 'handle array', ->
        nikita.assert not: true, ->
          [false, false]
        .should.be.fulfilled()
        nikita.assert not: true, ->
          [false, true]
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        nikita.assert not: true, ->
          [true, true]
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
    
  describe 'option `strict`', ->

    it 'succeed only with false', ->
      nikita.assert strict: true, ->
        'very strict'
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      nikita.assert strict: true, not: true, ->
        'very strict'
      .should.be.fulfilled()
      
