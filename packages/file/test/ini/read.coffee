
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.ini.read', ->
  return unless test.tags.posix

  they 'parse to an object', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      content = user: preference: color: 'rouge'
      await @file.ini
        content: content
        target: "#{tmpdir}/user.ini"
      {data} = await @file.ini.read
        target: "#{tmpdir}/user.ini"
      data.should.eql content
