
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'tools.git', ->

  beforeEach ->
    nikita
    .tools.extract
      source: "#{__dirname}/resources/repo.git.zip"
      target: "#{tmpdir}"

  they 'clones repo into new dir', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.git
      source: "#{tmpdir}/repo.git"
      target: "#{tmpdir}/my_repo"
    , (err, {status}) ->
      status.should.be.true()
    .tools.git
      source: "#{tmpdir}/repo.git"
      target: "#{tmpdir}/my_repo"
    , (err, {status}) ->
      status.should.be.false()

  they 'honores revision', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.git
      source: "#{tmpdir}/repo.git"
      target: "#{tmpdir}/my_repo"
    .tools.git
      source: "#{tmpdir}/repo.git"
      target: "#{tmpdir}/my_repo"
      revision: 'v0.0.1'
    , (err, {status}) ->
      status.should.be.true()
    .tools.git
      source: "#{tmpdir}/repo.git"
      target: "#{tmpdir}/my_repo"
      revision: 'v0.0.1'
    , (err, {status}) ->
      status.should.be.false()

  they 'preserves existing directory', ({ssh}) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{tmpdir}/my_repo"
    .tools.git
      source: "#{tmpdir}/repo.git"
      target: "#{tmpdir}/my_repo"
      relax: true
    , (err) ->
      err.message.should.eql 'Not a git repository'
