
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
wrap = require "../#{lib}/misc/wrap"

describe 'wrap', ->

  describe 'args', ->

    it 'accept 2 arguments', ->
      [options, goptions, callback] = wrap.args [
        option_a: 'a', option_b: 'b'
        -> #do sth
      ]
      goptions.should.eql parallel: true
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function

    it 'accept 3 arguments', ->
      [options, goptions, callback] = wrap.args [
        {option_a: 'a', option_b: 'b'}
        {parallel: 1}
        -> #do sth
      ]
      goptions.should.eql parallel: 1
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function

    it 'overwrite default global options', ->
      [options, goptions, callback] = wrap.args [
        option_a: 'a', option_b: 'b'
        -> #do sth
      ], parallel: 1
      goptions.parallel.should.equal 1
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function