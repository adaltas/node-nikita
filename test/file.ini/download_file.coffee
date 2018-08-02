
path = require 'path'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.download file', ->

  scratch = test.scratch @
  
  describe 'source', ->

    they 'with file protocol', (ssh) ->
      nikita
        ssh: ssh
      .file.download
        source: "file://#{__filename}"
        target: "#{scratch}/download_test" # Download a non existing file
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/download_test"
        content: /yeah/
      .file.download
        source: "file://#{__filename}"
        target: "#{scratch}/download_test" # Download on an existing file
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

    they 'without protocol', (ssh) ->
      source = 
      # Download a non existing file
      nikita
        ssh: ssh
      .file.download
        source: "#{__filename}"
        target: "#{scratch}/download_test"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/download_test"
        content: /yeah/
      .file.download # Download on an existing file
        source: "#{__filename}"
        target: "#{scratch}/download_test"
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

    they 'doesnt exists', (ssh) ->
      nikita
        ssh: ssh
      .file.download
        source: "#{__dirname}/doesnotexists"
        target: "#{scratch}/download_test"
        relax: true
      , (err, {status}) ->
        err.message.should.eql "Does not exist: #{__dirname}/doesnotexists"
        err.code.should.eql 'ENOENT'
      .promise()

    they 'into an existing directory', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/download_test"
      .file.download
        source: "#{__filename}"
        target: "#{scratch}/download_test"
      .file.assert
        target: "#{scratch}/download_test/#{path.basename __filename}"
      .promise()

  describe 'cache', ->

    they 'validate md5', (ssh) ->
      source = "#{__dirname}/download.zip"
      target = "#{scratch}/download"
      nikita
      .file.download
        ssh: ssh
        source: source
        target: "#{scratch}/download_test"
        cache: true
        cache_dir: "#{scratch}/cache_dir"
        md5: '3f104676a5f72de08b811dbb725244ff'
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert "#{scratch}/cache_dir/#{path.basename source}"
      .promise()

    they 'cache dir', (ssh) ->
      # Download a non existing file
      target = "#{scratch}/download"
      nikita
      .file.download
        ssh: ssh
        source: "#{__filename}"
        target: "#{scratch}/download_test"
        cache: true
        cache_dir: "#{scratch}/cache_dir"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert "#{scratch}/cache_dir/#{path.basename __filename}"
      .promise()

    they 'detect file already present', (ssh) ->
      ssh = null
      nikita
        ssh: ssh
      .file.download
        source: "#{__filename}"
        target: "#{scratch}/download_test"
        cache: true
        cache_dir: "#{scratch}/cache_dir"
      .file.download
        source: "#{__filename}"
        target: "#{scratch}/download_test"
        cache: true
        cache_dir: "#{scratch}/cache_dir"
      , (err, {status}) ->
        status.should.be.false() unless err
      .file
        content: 'abc'
        target: "#{scratch}/download_test"
      .file.download
        source: "#{__filename}"
        target: "#{scratch}/download_test"
        cache: true
        cache_dir: "#{scratch}/cache_dir"
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()
  
  describe 'md5', ->

    they 'cache dir with md5 string', (ssh) ->
      # Download a non existing file
      target = "#{scratch}/download"
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'okay'
      .file.download
        source: "#{scratch}/a_file"
        target: "#{scratch}/download_test"
        cache: true
        cache_dir: "#{scratch}/cache_dir"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/cache_dir/a_file"
        content: 'okay'
      .file.assert
        target: "#{scratch}/download_test"
        content: 'okay'
      .promise()

    they 'is computed if true', (ssh) ->
      # return @skip() unless ssh
      logs = []
      # Download with invalid checksum
      nikita
        ssh: ssh
      .on 'text', (log) -> logs.push "[#{log.level}] #{log.message}"
      .file
        target: "#{scratch}/source"
        content: "okay"
      .file.download
        source: "#{scratch}/source"
        target: "#{scratch}/check_md5"
        md5: true
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.download
        source: "#{scratch}/source"
        target: "#{scratch}/check_md5"
        md5: true
      , (err, {status}) ->
        status.should.be.false() unless err
      .call ->
        ("[WARN] Hash dont match, source is 'df8fede7ff71608e24a5576326e41c75' and target is 'undefined'" in logs).should.be.true()
        ("[INFO] Hash matches as 'df8fede7ff71608e24a5576326e41c75'" in logs).should.be.true()
      .promise()
      
  describe 'error', ->

    they 'path must be absolute over ssh', (ssh) ->
      return unless ssh
      nikita
        ssh: ssh
      .file.touch
        target: "#{scratch}/a_file"
      .file.download
        source: "#{scratch}/a_file"
        target: "a_dir/download_test"
        relax: true
      , (err, {status}) ->
        err.message.should.eql 'Non Absolute Path: target is "a_dir/download_test", SSH requires absolute paths, you must provide an absolute path in the target or the cwd option'
      .promise()
