
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.rubygems.fetch', ->
  return unless test.tags.tools_rubygems

  they 'with a version', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status, filename, filepath} = await @tools.rubygems.fetch
        name: 'execjs'
        version: '2.7.0'
        cwd: "#{tmpdir}"
      $status.should.be.true()
      filename.should.eql 'execjs-2.7.0.gem'
      filepath.should.eql "#{tmpdir}/execjs-2.7.0.gem"
      await @fs.assert
        target: "#{tmpdir}/execjs-2.7.0.gem"

  they 'without a version', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status, filename, filepath} = await @tools.rubygems.fetch
        name: 'execjs'
        cwd: "#{tmpdir}"
      $status.should.be.true()
      filename.should.eql 'execjs-2.9.1.gem'
      filepath.should.eql "#{tmpdir}/execjs-2.9.1.gem"
      await @fs.assert
        target: "#{tmpdir}/execjs-2.9.1.gem"
