
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
fs = require 'fs'
test = require './test'

describe 'render', ->

  scratch = test.scratch @
  
  describe 'eco', ->

    it 'should use `content`', (next) ->
      destination = "#{scratch}/render.eco"
      mecano.render
        content: 'Hello <%- @who %>'
        destination: destination
        context: who: 'you'
      , (err, rendered) ->
        return next err if err
        rendered.should.be.ok
        fs.readFile destination, 'ascii', (err, content) ->
          content.should.eql 'Hello you'
          next()
    
    it 'should use `source`', (next) ->
      destination = "#{scratch}/render.eco"
      mecano.render
        source: "#{__dirname}/../resources/render.eco"
        destination: destination
        context: who: 'you'
      , (err, rendered) ->
        return next err if err
        rendered.should.be.ok
        fs.readFile destination, 'ascii', (err, content) ->
          content.should.eql 'Hello you'
          next()
    
    it 'skip empty lines', (next) ->
      destination = "#{scratch}/render.eco"
      mecano.render
        content: "Hello\n\n\n<%- @who %>"
        destination: destination
        context: who: 'you'
        skip_empty_lines: true
      , (err, rendered) ->
        return next err if err
        rendered.should.be.ok
        fs.readFile destination, 'ascii', (err, content) ->
          content.should.eql 'Hello\nyou'
          next()
    
    it 'doesnt increment if destination is same than generated content', (next) ->
      destination = "#{scratch}/render.eco"
      mecano.render
        source: "#{__dirname}/../resources/render.eco"
        destination: destination
        context: who: 'you'
      , (err, rendered) ->
        return next err if err
        rendered.should.be.ok
        mecano.render
          source: "#{__dirname}/../resources/render.eco"
          destination: destination
          context: who: 'you'
        , (err, rendered) ->
          return next err if err
          rendered.should.not.be.ok
          next()
    
    it 'accept destination as a callback', (next) ->
      content = null
      mecano.render
        source: "#{__dirname}/../resources/render.eco"
        destination: (c) ->
          content = c
        context: who: 'you'
      , (err, rendered) ->
        content.should.eql 'Hello you'
        next()

    describe 'error', ->
    
      it 'when source doesnt exist', (next) -> 
        mecano.render
          source: "oups"
          destination: "#{scratch}/render.eco"
        , (err, rendered) ->
          err.message.should.eql 'Invalid source, got "oups"'
          next()
    
      it 'when syntax is incorrect', (next) -> 
        mecano.render
          content: '<%- @host ->'
          destination: "#{scratch}/render.eco"
          context: toto: 'lulu'
        , (err, rendered) ->
          err.message.should.eql 'Parse error on line 1: unexpected end of template'
          next()
  
  describe 'nunjunks', ->

    it 'should use `content`', (next) ->
      destination = "#{scratch}/render.txt"
      mecano.render
        content: 'Hello {{ who }}'
        destination: destination
        context: who: 'you'
        engine: 'nunjunks'
      , (err, rendered) ->
        return next err if err
        rendered.should.be.ok
        fs.readFile destination, 'ascii', (err, content) ->
          content.should.eql 'Hello you'
          next()

    it 'should use `content`', (next) ->
      source = "#{scratch}/render.j2"
      destination = "#{scratch}/render.txt"
      fs.writeFile source, 'Hello {{ who }}', (err, content) ->
        return next err if err
        mecano.render
          source: source 
          destination: destination
          context: who: 'you'
        , (err, rendered) ->
          return next err if err
          rendered.should.be.ok
          fs.readFile destination, 'ascii', (err, content) ->
            content.should.eql 'Hello you'
            next()



