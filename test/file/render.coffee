
mecano = require '../../src'
fs = require 'fs'
they = require 'ssh2-they'
test = require '../test'

describe 'render', ->

  scratch = test.scratch @

  describe 'error', ->

    it 'when source doesnt exist', (next) ->
      mecano.file.render
        source: "oups"
        target: "#{scratch}/output"
      , (err) ->
        err.message.should.eql 'Invalid source, got "oups"'
        next()

  describe 'nunjunks', ->

    it 'use `content`', (next) ->
      mecano
      .file.render
        engine: 'nunjunks'
        content: 'Hello {{ who }}'
        target: "#{scratch}/render.txt"
        context: who: 'you'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/render.txt"
        content: 'Hello you'
      .then next

    it 'use `source`', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      mecano
      .file
        target: source
        content: 'Hello {{ who }}'
      .file.render
        source: source
        target: target
        context: who: 'you'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: target
        content: 'Hello you'
      .then next

    it 'test mecano type filters', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      mecano
      .file
        target: source
        content: """
        {% if randArray | isArray and randObject | isObject and not randArray | isObject %}
        Hello{% endif %}
        {% if who | isString and not anInt | isString %}{{ who }}{% endif %}
        """
      .file.render
        source: source
        target: target
        context:
          randArray: [1, 2]
          randObject: toto: 0 
          who: 'world'
          anInt: 42
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: target
        content: '\nHello\nworld'
      .then next

    it 'test mecano isEmpty filter', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      mecano
      .file
        target: source
        content: """
        {% if fake | isEmpty and emptyArray | isEmpty and not fullArray | isEmpty
        and emptyObject | isEmpty and not fullObject | isEmpty and emptyString | isEmpty and not fullString | isEmpty %}
        {{ fullString }}
        {% endif %}
        """
      .file.render
        source: source
        target: target
        context:
          emptyArray: []
          fullArray: [0]
          emptyObject: {}
          fullObject: toto: 0 
          emptyString: ''
          fullString: 'succeed'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: target
        content: '\nsucceed\n'
      .then next

    it 'test personal filter', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      mecano
      .file
        target: source
        content: 'Hello {% if who | isString %}{{ who }} {% endif %}{% if anInt | isNum %}{{ anInt }} {% endif %}{% if arr | contains("toto") %}ok{% endif %}'
      .file.render
        source: source
        target: target
        context:
          who: 'you'
          anInt: 42
          arr: ['titi', 'toto']
        filters: isNum: (obj) -> return typeof obj is 'number'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: target
        content: 'Hello you 42 ok'
      .then next

    it 'check autoescaping (disabled)', (next) ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      mecano
      .file
        target: source
        content: 'Hello "{{ who }}" \'{{ anInt }}\''
      .file.render
        source: source
        target: target
        context:
          who: 'you'
          anInt: 42
        filters: isNum: (obj) -> return typeof obj is 'number'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: target
        content: 'Hello "you" \'42\''
      .then next

  describe 'eco', ->

    it 'should use `content`', (next) ->
      mecano
      .render
        engine: 'eco'
        content: 'Hello <%- @who %>'
        target: "#{scratch}/render.eco"
        context: who: 'you'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/render.eco"
        content: 'Hello you'
      .then next

    it 'detect `source`', (next) ->
      mecano
      .file.render
        source: "#{__dirname}/../resources/render.eco"
        target: "#{scratch}/render.eco"
        context: who: 'you'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/render.eco"
        content: 'Hello you'
      .then next

    it 'skip empty lines', (next) ->
      mecano
      .file.render
        engine: 'eco'
        content: "Hello\n\n\n<%- @who %>"
        target: "#{scratch}/render.eco"
        context: who: 'you'
        skip_empty_lines: true
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/render.eco"
        content: 'Hello\nyou'
      .then next

    they 'doesnt increment if target is same than generated content', (ssh, next) ->
      mecano
        ssh: ssh
      .file.render
        source: "#{__dirname}/../resources/render.eco"
        target: "#{scratch}/render.eco"
        context: who: 'you'
      , (err, status) ->
        status.should.be.true()
      .file.render
        source: "#{__dirname}/../resources/render.eco"
        target: "#{scratch}/render.eco"
        context: who: 'you'
      , (err, status) ->
        status.should.be.false()
      .then next

    it 'detect extention and accept target as a callback', (next) ->
      content = null
      mecano
      .file.render
        source: "#{__dirname}/../resources/render.eco"
        target: (c) -> content = c
        context: who: 'you'
      , (err, status) ->
        content.should.eql 'Hello you'
        next()

    it 'when syntax is incorrect', (next) ->
      mecano
      .file.render
        content: '<%- @host ->'
        engine: 'eco'
        target: "#{scratch}/render.eco"
        context: toto: 'lulu'
      , (err, status) ->
        err.message.should.eql 'Parse error on line 1: unexpected end of template'
        next()
