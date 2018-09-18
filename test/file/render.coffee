
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'file.render', ->

  describe 'error', ->

    they 'when option "source" doesnt exist', (ssh) ->
      nikita
        ssh: ssh
      .file.render
        source: "#{scratch}/oups.j2"
        target: "#{scratch}/output"
        context: {}
        relax: true
      , (err) ->
        err.message.should.eql "ENOENT: no such file or directory, open '#{scratch}/oups.j2'"
      .promise()

    they 'when option "context" is missing', (ssh) ->
      nikita
        ssh: ssh
      .file.render
        content: 'Hello {{ who }}'
        target: "#{scratch}/output"
        relax: true
      , (err) ->
        err.message.should.eql 'Required option: context'
      .promise()

    they 'unsuppoorted source extension', (ssh) ->
      nikita
        ssh: ssh
      .file.render
        source: 'gohome.et'
        target: "#{scratch}/output"
        context: {}
        relax: true
      , (err) ->
        err.message.should.eql "Invalid Option: extension '.et' is not supported"
      .promise()

  describe 'nunjunks', ->

    they 'use `content`', (ssh) ->
      nikita
        ssh: ssh
      .file.render
        content: 'Hello {{ who }}'
        engine: 'nunjunks'
        target: "#{scratch}/render.txt"
        context: who: 'you'
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/render.txt"
        content: 'Hello you'
      .promise()

    they 'detect `source`', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/source.j2"
        content: 'Hello {{ who }}'
      .file.render
        source: "#{scratch}/source.j2"
        target: "#{scratch}/target.txt"
        context: who: 'you'
      , (err, {status}) ->
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
      , (err, {status}) ->
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
      , (err, {status}) ->
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
      , (err, {status}) ->
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
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/target.txt"
        content: 'Hello "you" \'42\''
      .promise()
