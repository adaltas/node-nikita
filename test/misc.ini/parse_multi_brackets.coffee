
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'

describe 'misc.ini parse_multi_brackets', ->

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
