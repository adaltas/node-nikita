
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.rubygems.install', ->
  return unless test.tags.tools_rubygems

  they 'install a non existing package', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
    , ->
      await @tools.rubygems.remove
        name: 'execjs'
      {$status} = await @tools.rubygems.install
        name: 'execjs'
      $status.should.be.true()
      await @tools.rubygems.remove
        name: 'execjs'

  they 'bypass existing package', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
    , ->
      await @tools.rubygems.remove
        name: 'execjs'
      await @tools.rubygems.install
        name: 'execjs'
      {$status} = await @tools.rubygems.install
        name: 'execjs'
      $status.should.be.false()
      await @tools.rubygems.remove
        name: 'execjs'

  they 'install multiple versions', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
    , ->
      await @tools.rubygems.remove
        name: 'execjs'
      await @tools.rubygems.install
        name: 'execjs'
        version: '2.6.0'
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.7.0'
      $status.should.be.true()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.6.0'
      $status.should.be.false()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.7.0'
      $status.should.be.false()
      await @tools.rubygems.remove
        name: 'execjs'

  they 'local gem from file', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @tools.rubygems.remove
        name: 'execjs'
      await @tools.rubygems.fetch
        name: 'execjs'
        version: '2.8.1'
        cwd: "#{tmpdir}"
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        source: "#{tmpdir}/execjs-2.8.1.gem"
      $status.should.be.true()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.8.1'
      $status.should.be.false()
      await @tools.rubygems.remove
        name: 'execjs'

  they 'local gem from glob', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @tools.rubygems.remove
        name: 'execjs'
      await @tools.rubygems.fetch
        name: 'execjs'
        version: '2.7.0'
        cwd: "#{tmpdir}"
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        source: "#{tmpdir}/*.gem"
      $status.should.be.true()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        source: "#{tmpdir}/*.gem"
      $status.should.be.false()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.7.0'
      $status.should.be.false()
      await @tools.rubygems.remove
        name: 'execjs'
