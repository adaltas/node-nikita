
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.cson', ->
  return unless test.tags.posix

  they 'stringify content to target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/target.cson"
        content: 'doent have to be valid cson'
      await @file.cson
        target: "#{tmpdir}/target.cson"
        content: user: 'torval'
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target.cson"
        content: 'user: \'torval\''

  they 'merge target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/target.cson"
        content: '"user": "linus"\n"merge": true'
      await @file.cson
        target: "#{tmpdir}/target.cson"
        content: 'user': 'torval'
        merge: true
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target.cson"
        content: 'user: \'torval\'\nmerge: true'

  they 'merge target which does not exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.cson
        target: "#{tmpdir}/target.cson"
        content: 'user': 'torval'
        merge: true
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target.cson"
        content: 'user: \'torval\''
