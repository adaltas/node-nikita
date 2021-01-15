
nikita = require '@nikitajs/engine/lib'
{tags, config, ruby} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_rubygems

describe 'tools.rubygems.fetch', ->

  they 'with a version', ({ssh}) ->
    nikita
      ssh: ssh
      ruby: ruby
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {status, filename, filepath} = await @tools.rubygems.fetch
        name: 'execjs'
        version: '2.7.0'
        cwd: "#{tmpdir}"
      status.should.be.true()
      filename.should.eql 'execjs-2.7.0.gem'
      filepath.should.eql "#{tmpdir}/execjs-2.7.0.gem"
      @fs.assert
        target: "#{tmpdir}/execjs-2.7.0.gem"

  they 'without a version', ({ssh}) ->
    nikita
      ssh: ssh
      ruby: ruby
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {status, filename, filepath} = await @tools.rubygems.fetch
        name: 'execjs'
        cwd: "#{tmpdir}"
      status.should.be.true()
      filename.should.eql 'execjs-2.7.0.gem'
      filepath.should.eql "#{tmpdir}/execjs-2.7.0.gem"
      @fs.assert
        target: "#{tmpdir}/execjs-2.7.0.gem"
