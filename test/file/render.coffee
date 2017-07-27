
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'file.render', ->

  scratch = test.scratch @

  describe 'error', ->

    they 'when source doesnt exist', (ssh) ->
      nikita
        ssh: ssh
      .file.render
        source: "oups"
        target: "#{scratch}/output"
        relax: true
      , (err) ->
        err.message.should.eql 'Invalid source, got "oups"'
      .promise()

  describe 'nunjunks', ->

    they 'use `content`', (ssh) ->
      nikita
        ssh: ssh
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

    they 'use `source`', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/source.j2"
        content: 'Hello {{ who }}'
      .file.render
        source: "#{scratch}/source.j2"
        target: "#{scratch}/target.txt"
        context: who: 'you'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/target.txt"
        content: 'Hello you'
      .promise()

    they 'test nikita type filters', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/source.j2"
        content: """
        {% if randArray | isArray and randObject | isObject and not randArray | isObject %}
        Hello{% endif %}
        {% if who | isString and not anInt | isString %}{{ who }}{% endif %}
        """
      .file.render
        source: "#{scratch}/source.j2"
        target: "#{scratch}/target.txt"
        context:
          randArray: [1, 2]
          randObject: toto: 0
          who: 'world'
          anInt: 42
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/target.txt"
        content: '\nHello\nworld'
      .promise()

    they 'test nikita isEmpty filter', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/source.j2"
        content: """
        {% if fake | isEmpty and emptyArray | isEmpty and not fullArray | isEmpty
        and emptyObject | isEmpty and not fullObject | isEmpty and emptyString | isEmpty and not fullString | isEmpty %}
        {{ fullString }}
        {% endif %}
        """
      .file.render
        source: "#{scratch}/source.j2"
        target: "#{scratch}/target.txt"
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
        target: "#{scratch}/target.txt"
        content: '\nsucceed\n'
      .promise()

    they 'test personal filter', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/source.j2"
        content: 'Hello {% if who | isString %}{{ who }} {% endif %}{% if anInt | isNum %}{{ anInt }} {% endif %}{% if arr | contains("toto") %}ok{% endif %}'
      .file.render
        source: "#{scratch}/source.j2"
        target: "#{scratch}/target.txt"
        context:
          who: 'you'
          anInt: 42
          arr: ['titi', 'toto']
        filters: isNum: (obj) -> return typeof obj is 'number'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/target.txt"
        content: 'Hello you 42 ok'
      .promise()

    they 'check autoescaping (disabled)', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/source.j2"
        content: 'Hello "{{ who }}" \'{{ anInt }}\''
      .file.render
        source: "#{scratch}/source.j2"
        target: "#{scratch}/target.txt"
        context:
          who: 'you'
          anInt: 42
        filters: isNum: (obj) -> return typeof obj is 'number'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/target.txt"
        content: 'Hello "you" \'42\''
      .promise()

  describe 'eco', ->

    they 'should use `content`', (ssh) ->
      nikita
        ssh: ssh
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

    they 'detect `source`', (ssh) ->
      nikita
        ssh: ssh
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

    they 'skip empty lines', (ssh) ->
      nikita
        ssh: ssh
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

    they 'detect extention and accept target as a callback', (ssh) ->
      content = null
      nikita
        ssh: ssh
      .file.render
        source: "#{__dirname}/../resources/render.eco"
        target: (c) -> content = c
        context: who: 'you'
      , (err, status) ->
        content.should.eql 'Hello you'
      .promise()

    they 'when syntax is incorrect', (ssh) ->
      nikita
        ssh: ssh
      .file.render
        content: '<%- @host ->'
        engine: 'eco'
        target: "#{scratch}/render.eco"
        context: toto: 'lulu'
        relax: true
      , (err, status) ->
        err.message.should.eql 'Parse error on line 1: unexpected end of template'
      .promise()
