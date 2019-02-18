
http = require 'http'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.download url', ->
  
  server = null

  beforeEach (next) ->
    server = http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'okay'
    server.listen 12345, next

  afterEach (next) ->
    server.close()
    server.on 'close', next

  they 'download without cache and md5', ({ssh}) ->
    @timeout 100000
    # Download a non existing file
    nikita
      ssh: ssh
    .file.download
      source: 'http://localhost:12345'
      target: "#{scratch}/download"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/download"
      content: /okay/
    .file.download # Download on an existing file
      source: 'http://localhost:12345'
      target: "#{scratch}/download"
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'should chmod', ({ssh}) ->
    @timeout 10000
    nikita
      ssh: ssh
    .file.download
      source: 'http://localhost:12345'
      target: "#{scratch}/download_test"
      mode: 0o0770
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/download_test"
      mode: 0o0770
    .promise()

  describe 'cache', ->

    they 'cache file', ({ssh}) ->
      @timeout 100000
      # Download a non existing file
      nikita
        ssh: ssh
      .file.download
        source: 'http://localhost:12345'
        target: "#{scratch}/target"
        cache_file: "#{scratch}/cache_file"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/cache_file"
        content: /okay/
      .file.assert
        target: "#{scratch}/target"
        content: /okay/
      .promise()

    they 'cache file defined globally', ({ssh}) ->
      @timeout 100000
      # Download a non existing file
      source = 'http://localhost:12345'
      target = "#{scratch}/download"
      cache = "#{scratch}/cache_file"
      nikita(cache_file: cache).file.download
        ssh: ssh
        source: source
        target: target
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        ssh: null
        target: cache
        content: 'okay'
      .promise()

    they 'cache dir', ({ssh}) ->
      @timeout 100000
      # Download a non existing file
      source = 'http://localhost:12345'
      target = "#{scratch}/download"
      nikita
      .file.download
        ssh: ssh
        source: source
        target: target
        cache_dir: "#{scratch}/cache_dir"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        ssh: null
        target: "#{scratch}/cache_dir/localhost:12345"
      .promise()

  describe 'md5', ->

    they 'use shortcircuit if target match md5', ({ssh}) ->
      logs = []
      nikita
        ssh: ssh
      .on 'text', (log) -> logs.push "[#{log.level}] #{log.message}"
      .file
        content: 'okay'
        target: "#{scratch}/target"
      .file.download
        source: 'http://localhost:12345'
        target: "#{scratch}/target"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, {status}) ->
        status.should.be.false() unless err
      .call ->
        ("[INFO] Destination with valid signature, download aborted" in logs).should.be.true()
      .promise()

    they 'bypass shortcircuit if target dont match md5', ({ssh}) ->
      logs = []
      nikita
        ssh: ssh
      .on 'text', (log) -> logs.push "[#{log.level}] #{log.message}"
      .file
        content: "not okay"
        target: "#{scratch}/target"
      .file.download
        source: 'http://localhost:12345'
        target: "#{scratch}/target"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/target"
        content: /okay/
      .promise()

    they 'check signature on downloaded file', ({ssh}) ->
      # Download with invalid checksum
      nikita
        ssh: ssh
      .file.download
        source: 'http://localhost:12345'
        target: "#{scratch}/target"
        md5: '2f74dbbee4142b7366c93b115f914fff'
        relax: true
      , (err, {status}) ->
        err.message.should.eql "Invalid downloaded checksum, found 'df8fede7ff71608e24a5576326e41c75' instead of '2f74dbbee4142b7366c93b115f914fff'"
      .promise()

    they 'count 1 if new file has correct checksum', ({ssh}) ->
      # Download with invalid checksum
      nikita
      .file.download
        ssh: ssh
        source: 'http://localhost:12345'
        target: "#{scratch}/check_md5"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()

    they 'count 0 if a file exist with same checksum', ({ssh}) ->
      # Download with invalid checksum
      nikita
        ssh: ssh
      .file.download
        source: 'http://localhost:12345'
        target: "#{scratch}/check_md5"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.download
        source: 'http://localhost:12345'
        target: "#{scratch}/check_md5"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()
      
  describe 'error', ->

    they 'path must be absolute over ssh', ({ssh}) ->
      return unless ssh
      nikita
        ssh: ssh
      .file.download
        source: "http://localhost/sth"
        target: "a_dir/download_test"
        relax: true
      , (err, {status}) ->
        err.message.should.eql 'Non Absolute Path: target is "a_dir/download_test", SSH requires absolute paths, you must provide an absolute path in the target or the cwd option'
      .promise()
