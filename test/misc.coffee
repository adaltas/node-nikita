
should = require 'should'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'superexec/lib/they'

describe 'misc', ->

  scratch = test.scratch @

  describe 'string', ->

    describe 'hash', ->

      it 'returns the string md5', ->
        md5 = misc.string.hash "hello"
        md5.should.eql '5d41402abc4b2a76b9719d911017c592'

  describe 'ini', ->

    it 'parse multi brackets style', ->
      res = misc.ini.parse_multi_brackets """
      ###########################################################################
      # Some comments

      [group1]
        
        key1a="value1a"

        # comment
        key1b=1

        # Administrators
        # ----------------
        [[group1a1]]
          ## [[[admin1aX]]]
          key1a1 = value1a1
        [[group1b]]
          # comment = value
          ## double comment = value
          key1b1 = value1b1
      [group2]
        key1=value1b
      """
      res.should.eql
        '###########################################################################': null
        '# Some comments': null
        group1:
          key1a: '"value1a"'
          '# comment': null
          key1b: '1'
          '# Administrators': null
          '# ----------------': null
          group1a1:
            '## [[[admin1aX]]]': null
            key1a1: 'value1a1'
          group1b:
            '# comment': 'value'
            '## double comment': 'value'
            key1b1: 'value1b1'
        group2:
          key1: 'value1b'

    it 'parse multi brackets style with comment', ->
      res = misc.ini.parse_multi_brackets """
      # Some = comments
      [group1]
        [[group1b]]
          # comment = value
          ## double comment = value
          key1b1 = value1b1
      [group2]
        key1=value1b
      """, comment: '#'
      res.should.eql
        '# Some = comments': null
        group1:
          group1b:
            '# comment = value': null
            '## double comment = value': null
            key1b1: 'value1b1'
        group2:
          key1: 'value1b'

    it 'stringify multi brackets style', ->
      res = misc.ini.stringify_multi_brackets 
        '###########################################################################': null
        '# Some comments': null
        group1:
          key1a: '"value1a"'
          '# comment': null
          key1b: '1'
          '# Administrators': null
          '# ----------------': null
          group1a1:
            '## [[[admin1aX]]]': null
            key1a1: 'value1a1'
          group1b:
            '# comment': 'value'
            '## double comment': 'value'
            key1b1: 'value1b1'
        group2:
          key1: 'value1b'
      res.should.eql """
      ###########################################################################
      # Some comments
      [group1]
        key1a = "value1a"
        # comment
        key1b = 1
        # Administrators
        # ----------------
        [[group1a1]]
          ## [[[admin1aX]]]
          key1a1 = value1a1
        [[group1b]]
          # comment = value
          ## double comment = value
          key1b1 = value1b1
      [group2]
        key1 = value1b

      """

    it 'stringify in square brackets and curly brackets', ->
      res = misc.ini.stringify_square_then_curly 
        user: preference: color: true
        group:
          name: 'us'
      res.should.eql '[user]\n preference = {\n  color = true\n }\n\n[group]\n name = us\n\n'

  describe 'pidfileStatus', ->

    they 'give 0 if pidfile math a running process', (ssh, next) ->
      misc.file.writeFile ssh, "#{scratch}/pid", "#{process.pid}", (err) ->
        misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
          status.should.eql 0
          next()

    they 'give 1 if pidfile does not exists', (ssh, next) ->
      misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
        status.should.eql 1
        next()

    they 'give 2 if pidfile exists but match no process', (ssh, next) ->
      misc.file.writeFile ssh, "#{scratch}/pid", "666666666", (err) ->
        misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
          status.should.eql 2
          next()

  describe 'options', ->

    they 'default not_if_exists to destination if false', (ssh, next) ->
      misc.options
        ssh: ssh
        not_if_exists: true
        destination: __dirname
      , (err, options) ->
        return next err if err
        options[0].not_if_exists[0].should.eql __dirname
        next()






