
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'tools.git', ->

  they 'clones repo into new dir', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.extract
        source: "#{__dirname}/resources/repo.git.zip"
        target: "#{tmpdir}"
      {status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      status.should.be.true()
      {status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      status.should.be.false()

  they 'honores revision', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.extract
        source: "#{__dirname}/resources/repo.git.zip"
        target: "#{tmpdir}"
      @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      {status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
        revision: 'v0.0.1'
      status.should.be.true()
      {status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
        revision: 'v0.0.1'
      status.should.be.false()

  they 'preserves existing directory', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.extract
        source: "#{__dirname}/resources/repo.git.zip"
        target: "#{tmpdir}"
      @fs.mkdir
        target: "#{tmpdir}/my_repo"
      @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      .should.be.rejectedWith
        message: 'Not a git repository'
