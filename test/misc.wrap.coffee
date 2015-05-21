
wrap = require "../src/misc/wrap"

describe 'wrap', ->

  describe 'args', ->

    it 'accept 2 arguments', ->
      [options, goptions, callback] = wrap.args [
        option_a: 'a', option_b: 'b'
        -> #do sth
      ]
      goptions.should.eql parallel: 1
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function

    it 'accept 3 arguments', ->
      [options, goptions, callback] = wrap.args [
        {option_a: 'a', option_b: 'b'}
        {parallel: 2}
        -> #do sth
      ]
      goptions.should.eql parallel: 2
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function

    # it 'overwrite default global options', ->
    #   [options, goptions, callback] = wrap.args [
    #     option_a: 'a', option_b: 'b'
    #     -> #do sth
    #   ], parallel: 2
    #   goptions.parallel.should.equal 2
    #   options.should.eql option_a: 'a', option_b: 'b'
    #   callback.should.be.a.Function

  describe 'callback context', ->
    