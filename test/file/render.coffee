
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'file.render', ->

  scratch = test.scratch @

  describe 'error', ->

    it 'when source doesnt exist', ->
      nikita.file.render
        source: "oups"
        target: "#{scratch}/output"
        relax: true
      , (err) ->
        err.message.should.eql 'Invalid source, got "oups"'
      .promise()

  describe 'nunjunks', ->

    it 'use `content`', ->
      nikita
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
      .promise()

    it 'use `source`', ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      nikita
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
      .promise()

    it 'test nikita type filters', ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      nikita
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
      .promise()

    it 'test nikita isEmpty filter', ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      nikita
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
      .promise()

    it 'test personal filter', ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      nikita
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
      .promise()

    it 'check autoescaping (disabled)', ->
      source = "#{scratch}/render.j2"
      target = "#{scratch}/render.txt"
      nikita
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
      .promise()

  describe 'eco', ->

    it 'should use `content`', ->
      nikita
      .file.render
        engine: 'eco'
        content: 'Hello <%- @who %>'
        target: "#{scratch}/render.eco"
        context: who: 'you'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/render.eco"
        content: 'Hello you'
      .promise()

    it 'detect `source`', ->
      nikita
      .file.render
        source: "#{__dirname}/../resources/render.eco"
        target: "#{scratch}/render.eco"
        context: who: 'you'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/render.eco"
        content: 'Hello you'
      .promise()

    it 'skip empty lines', ->
      nikita
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
      .promise()

    they 'doesnt increment if target is same than generated content', (ssh) ->
      nikita
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
      .promise()

    it 'detect extention and accept target as a callback', ->
      content = null
      nikita
      .file.render
        source: "#{__dirname}/../resources/render.eco"
        target: (c) -> content = c
        context: who: 'you'
      , (err, status) ->
        content.should.eql 'Hello you'
      .promise()

    it 'when syntax is incorrect', ->
      nikita
      .file.render
        content: '<%- @host ->'
        engine: 'eco'
        target: "#{scratch}/render.eco"
        context: toto: 'lulu'
        relax: true
      , (err, status) ->
        err.message.should.eql 'Parse error on line 1: unexpected end of template'
      .promise()
