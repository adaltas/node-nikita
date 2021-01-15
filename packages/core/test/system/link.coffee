
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('mocha-they')(config)...

return unless tags.posix

describe 'system.link', ->

  they 'should link file', ({ssh}) ->
    # Create a non existing link
    nikita
      ssh: ssh
    .system.link # Link does not exist
      source: __filename
      target: "#{scratch}/link_test"
    , (err, {status}) ->
      status.should.be.true() unless err
    .system.link # Link already exists
      source: __filename
      target: "#{scratch}/link_test"
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/link_test"
      filetype: 'symlink'
    .promise()
  
  they 'should link dir', ({ssh}) ->
    # Create a non existing link
    nikita
      ssh: ssh
    .system.link # Link does not exist
      source: __dirname
      target: "#{scratch}/link_test"
    , (err, {status}) ->
      status.should.be.true() unless err
    .system.link # Link already exists
      ssh: ssh
      source: __dirname
      target: "#{scratch}/link_test"
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/link_test"
      filetype: 'symlink'
    .promise()
  
  they 'should create parent directories', ({ssh}) ->
    # Create a non existing link
    nikita
      ssh: ssh
    .system.link
      source: __dirname
      target: "#{scratch}/test/dir/link_test"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test/dir/link_test"
      type: 'symlink'
    .system.link [
      ssh: ssh
      source: "#{__dirname}/merge.coffee"
      target: "#{scratch}/test/dir2/merge.coffee"
    ,
      ssh: ssh
      source: "#{__dirname}/mkdir.coffee"
      target: "#{scratch}/test/dir2/mkdir.coffee"
    ], (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'should override invalid link', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/test/invalid_file"
      content: 'error'
    .file
      target: "#{scratch}/test/valid_file"
      content: 'ok'
    .system.link
      source: "#{scratch}/test/invalid_file"
      target: "#{scratch}/test/file_link"
    , (err, {status}) ->
      status.should.be.true() unless err
    .system.remove
      target: "#{scratch}/test/invalid_file"
    .system.link
      source: "#{scratch}/test/valid_file"
      target: "#{scratch}/test/file_link"
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  describe 'error', ->

    they 'for invalid arguments', ({ssh}) ->
      # Test missing source
      nikita
        ssh: ssh
      .system.link
        target: __filename
      .next (err) ->
        err.message.should.eql "Missing source, got undefined"
      .system.link # Test missing target
        source: __filename
      .next (err) ->
        err.message.should.eql "Missing target, got undefined"
      .promise()
