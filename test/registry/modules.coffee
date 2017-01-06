
mecano = require '../../src'
test = require '../test'
each = require 'each'

describe 'api modules', ->

  scratch = test.scratch @

  describe 'flat', ->

    it 'set property', ->
      mecano.register 'my_function_1', -> 'my_function'
      mecano.register ['my', 'function', '2'], -> 'my_function'
      mecano.register ['my', 'function', '3'], -> 'my_function'
      mecano.register 'my_function_4', -> 'my_function'
