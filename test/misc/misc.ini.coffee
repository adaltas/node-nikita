
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'

describe 'ini', ->

  describe 'multi brackets', ->

    it 'parse style', ->
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

    it 'parse style with comment', ->
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

    it 'stringify test eol', ->
      res = misc.ini.stringify_multi_brackets
        user: preference: color: true
        group:
          name: 'us'
      , eol: '|'
      res.should.eql '[user]|  [[preference]]|    color = true|[group]|  name = us|'

    it 'stringify style', ->
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

    it 'stringify simple values before complex values', ->
      res = misc.ini.stringify_multi_brackets
        group1:
          key1: 'value1'
          group1b:
            key1b1: 'value1b1'
          key2: 'value2'
        group2:
          key1: 'value1b'
      res.should.eql """
        [group1]
          key1 = value1
          key2 = value2
          [[group1b]]
            key1b1 = value1b1
        [group2]
          key1 = value1b

        """
  
  describe 'multi brackets multi lines', ->

    it 'parse', ->
      content = """
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
                # comment
                ## double comment
                key1b1 = value1b1
                following value
            [group2]
              key1=value1b
              """
      res = misc.ini.parse_multi_brackets_multi_lines content, { comment : '#'}
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
            '# comment': null
            '## double comment': null
            key1b1: "value1b1following value"
        group2:
          key1: 'value1b'

  describe 'square and curly brackets', ->

    it 'stringify test eol', ->
      res = misc.ini.stringify_square_then_curly
        user: preference: color: true
        group:
          name: 'us'
      , eol: '|'
      res.should.eql '[user]| preference = {|  color = true| }||[group]| name = us||'

    it 'stringify simple values before array values', ->
      res = misc.ini.stringify_square_then_curly
        group1:
          key1: 'value1'
          group1b:
            key1b1: 'value1b1'
            key1b2: ['value1b2a', 'value1b2b']
          key2: 'value2'
        group2:
          key1: 'value1b'
      res.should.eql """
        [group1]
         key1 = value1
         group1b = {
          key1b1 = value1b1
          key1b2 = value1b2a
          key1b2 = value1b2b
         }
         key2 = value2

        [group2]
         key1 = value1b


        """
