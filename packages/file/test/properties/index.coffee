
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.properties', ->
  return unless test.tags.posix

  they 'overwrite by default', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content: a_key: 'a value'
      .should.be.finally.containEql $status: true
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
      .should.be.finally.containEql $status: true
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
      .should.be.finally.containEql $status: false
      await @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "another_key=another value\n"

  they 'option merge', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content: a_key: 'a value'
      .should.be.finally.containEql $status: true
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
        merge: true
      .should.be.finally.containEql $status: true
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
        merge: true
      .should.be.finally.containEql $status: false
      await @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key=a value\nanother_key=another value\n"

  they 'honor separator', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content: a_key: 'a value'
        separator: ' '
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
        separator: ' '
        merge: true
      await @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key a value\nanother_key another value\n"

  they 'honor sort', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content:
          b_key: 'value'
          a_key: 'value'
        sort: false
      await @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "b_key=value\na_key=value\n"
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content:
          b_key: 'value'
          a_key: 'value'
        sort: true
      await @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key=value\nb_key=value\n"

  they 'option comments', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/file.properties"
        content: """
        a_key=value
        # comment
        b_key=value
        """
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content:
          b_key: 'new value'
          a_key: 'new value'
        merge: true
        comment: true
      await @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key=new value\n# comment\nb_key=new value\n"

  they 'option trim + merge', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/file.properties"
        content: """
        a_key = a value
        """
      await @file.properties
        target: "#{tmpdir}/file.properties"
        content:
          'b_key ': ' b value'
        merge: true
        trim: true
      await @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key=a value\nb_key=b value\n"
