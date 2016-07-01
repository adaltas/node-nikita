
mecano = require '../../src'
fs = require 'fs'
they = require 'ssh2-they'
test = require '../test'

describe 'render', ->

  scratch = test.scratch @

  describe 'error', ->

    it 'when source doesnt exist', (next) ->
      mecano.render
        source: "oups"
        target: "#{scratch}/output"
      , (err, rendered) ->
        err.message.should.eql 'Invalid source, got "oups"'
        next()

  describe 'nunjunks', ->

    it 'should use `content`', (next) ->
      target = "#{scratch}/render.txt"
      mecano.render
        engine: 'nunjunks'
        content: 'Hello {{ who }}'
        target: target
        context: who: 'you'
      , (err, rendered) ->
        return next err if err
        rendered.should.be.true()
        fs.readFile target, 'ascii', (err, content) ->
          content.should.eql 'Hello you'
          next()

    it 'should use `content`', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      fs.writeFile source, 'Hello {{ who }}', (err, content) ->
        return next err if err
        mecano.render
          source: source
          target: target
          context: who: 'you'
        , (err, rendered) ->
          return next err if err
          rendered.should.be.true()
          fs.readFile target, 'ascii', (err, content) ->
            content.should.eql 'Hello you'
            next()

    it 'test mecano type filters', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      fs.writeFile source,"""
      {% if randArray | isArray and randObject | isObject and not randArray | isObject %}
      Hello{% endif %}
      {% if who | isString and not anInt | isString %}{{ who }}{% endif %}
      """
      , (err, content) ->
        return next err if err
        mecano.render
          source: source
          target: target
          context:
            randArray: [1, 2]
            randObject: toto: 0 
            who: 'world'
            anInt: 42
        , (err, rendered) ->
          return next err if err
          rendered.should.be.true()
          fs.readFile target, 'ascii', (err, content) ->
            content.trim().should.eql 'Hello\nworld'
            next()

    it 'test mecano isEmpty filter', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      fs.writeFile source,"""
      {% if fake | isEmpty and emptyArray | isEmpty and not fullArray | isEmpty
      and emptyObject | isEmpty and not fullObject | isEmpty and emptyString | isEmpty and not fullString | isEmpty %}
      {{ fullString }}
      {% endif %}
      """, (err, content) ->
        return next err if err
        mecano.render
          source: source
          target: target
          context:
            emptyArray: []
            fullArray: [0]
            emptyObject: {}
            fullObject: toto: 0 
            emptyString: ''
            fullString: 'succeed'
        , (err, rendered) ->
          return next err if err
          rendered.should.be.true()
          fs.readFile target, 'ascii', (err, content) ->
            content.trim().should.eql 'succeed'
            next()

    it 'test personal filter', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      fs.writeFile source, 'Hello {% if who | isString %}{{ who }} {% endif %}{% if anInt | isNum %}{{ anInt }} {% endif %}{% if arr | contains("toto") %}ok{% endif %}', (err, content) ->
        return next err if err
        mecano.render
          source: source
          target: target
          context:
            who: 'you'
            anInt: 42
            arr: ['titi', 'toto']
          filters: isNum: (obj) -> return typeof obj is 'number'
        , (err, rendered) ->
          return next err if err
          rendered.should.be.true()
          fs.readFile target, 'ascii', (err, content) ->
            content.should.eql 'Hello you 42 ok'
            next()

    it 'check autoescaping (disabled)', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      fs.writeFile source, 'Hello "{{ who }}" \'{{ anInt }}\'', (err, content) ->
        return next err if err
        mecano.render
          source: source
          target: target
          context:
            who: 'you'
            anInt: 42
          filters: isNum: (obj) -> return typeof obj is 'number'
        , (err, rendered) ->
          return next err if err
          rendered.should.be.true()
          fs.readFile target, 'ascii', (err, content) ->
            content.should.eql 'Hello "you" \'42\''
            next()

  describe 'eco', ->

    it 'should use `content`', (next) ->
      target = "#{scratch}/render.eco"
      mecano.render
        engine: 'eco'
        content: 'Hello <%- @who %>'
        target: target
        context: who: 'you'
      , (err, rendered) ->
        return next err if err
        rendered.should.be.true()
        fs.readFile target, 'ascii', (err, content) ->
          content.should.eql 'Hello you'
          next()

    it 'detect `source`', (next) ->
      target = "#{scratch}/render.eco"
      mecano.render
        source: "#{__dirname}/../resources/render.eco"
        target: target
        context: who: 'you'
      , (err, rendered) ->
        return next err if err
        rendered.should.be.true()
        fs.readFile target, 'ascii', (err, content) ->
          content.should.eql 'Hello you'
          next()

    it 'skip empty lines', (next) ->
      mecano.render
        engine: 'eco'
        content: "Hello\n\n\n<%- @who %>"
        target: "#{scratch}/render.eco"
        context: who: 'you'
        skip_empty_lines: true
      , (err, rendered) ->
        return next err if err
        rendered.should.be.true()
        fs.readFile "#{scratch}/render.eco", 'ascii', (err, content) ->
          content.should.eql 'Hello\nyou'
          next()

    they 'doesnt increment if target is same than generated content', (ssh, next) ->
      mecano
        ssh: ssh
      .render
        source: "#{__dirname}/../resources/render.eco"
        target: "#{scratch}/render.eco"
        context: who: 'you'
      , (err, rendered) ->
        rendered.should.be.true()
      .render
        source: "#{__dirname}/../resources/render.eco"
        target: "#{scratch}/render.eco"
        context: who: 'you'
      , (err, rendered) ->
        rendered.should.be.false()
      .then next

    it 'detect extention and accept target as a callback', (next) ->
      content = null
      mecano.render
        source: "#{__dirname}/../resources/render.eco"
        target: (c) -> content = c
        context: who: 'you'
      , (err, rendered) ->
        content.should.eql 'Hello you'
        next()

    it 'when syntax is incorrect', (next) ->
      mecano.render
        content: '<%- @host ->'
        engine: 'eco'
        target: "#{scratch}/render.eco"
        context: toto: 'lulu'
      , (err, rendered) ->
        err.message.should.eql 'Parse error on line 1: unexpected end of template'
        next()
