
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'tools.git', ->

  beforeEach ->
    nikita
    .tools.extract
      source: "#{__dirname}/../resources/repo.git.zip"
      target: "#{scratch}"
    .promise()

  they 'clones repo into new dir', (ssh) ->
    nikita
      ssh: ssh
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
    , (err, {status}) ->
      status.should.be.true()
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  they 'honores revision', (ssh) ->
    nikita
      ssh: ssh
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
      revision: 'v0.0.1'
    , (err, {status}) ->
      status.should.be.true()
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
      revision: 'v0.0.1'
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  they 'preserves existing directory', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/my_repo"
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
      relax: true
    , (err) ->
      err.message.should.eql 'Not a git repository'
    .promise()
