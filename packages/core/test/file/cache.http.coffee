
http = require 'http'
path = require 'path'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.cache http', ->

  server = null

  beforeEach (next) ->
    server = http.createServer (req, res) ->
      if req.url is '/my_file'
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      else
        # res.status(404).send('Not found')
        res.writeHead 404, {'Content-Type': 'text/plain'}
        res.end 'Not found'
    server.listen 12345, next

  afterEach (next) ->
    server.close()
    server.on 'close', next

  they 'handles string argument', ({ssh}) ->
    nikita
      ssh: ssh
    .file.cache 'http://localhost:12345/my_file',
      cache_dir: "#{scratch}/my_cache_dir"
    , (err, {status, target}) ->
      status.should.be.true() unless err
      target.should.eql "#{scratch}/my_cache_dir/my_file" unless err
    .promise()

  they 'into local cache_dir', ({ssh}) ->
    nikita
      ssh: ssh
    .file.cache
      source: 'http://localhost:12345/my_file'
      cache_dir: "#{scratch}/my_cache_dir"
    , (err, {status, target}) ->
      status.should.be.true() unless err
      target.should.eql "#{scratch}/my_cache_dir/my_file" unless err
    .file.cache
      source: 'http://localhost:12345/my_file'
      cache_dir: "#{scratch}/my_cache_dir"
    , (err, {status, target}) ->
      status.should.be.false() unless err
      target.should.eql "#{scratch}/my_cache_dir/my_file"
    .file.assert
      target: "#{scratch}/my_cache_dir/my_file"
    .promise()

  they 'option fail with invalid exit code', ({ssh}) ->
    nikita
      ssh: ssh
    .file.cache
      source: 'http://localhost:12345/missing'
      cache_dir: "#{scratch}/cache_dir_1"
    , (err) ->
      (err is undefined).should.be.true()
    .file.cache
      source: 'http://localhost:12345/missing'
      cache_dir: "#{scratch}/cache_dir_2"
      fail: true
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid Exit Code: 22'
    .promise()

  describe 'hash', ->

    they 'current cache file match provided hash', ({ssh}) ->
      logs = []
      nikita
        ssh: ssh
      .on 'text', (log) ->
        logs.push log.message
      .file
        target: "#{scratch}/my_cache_file"
        content: 'okay'
      .file.cache
        source: 'http://localhost:12345/my_file'
        cache_file: "#{scratch}/my_cache_file"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, {status}) ->
        status.should.be.false() unless err
        ('Hashes match, skipping' in logs).should.be.true() unless err
      .promise()

    they 'current cache file dont match provided hash', ({ssh}) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/my_cache_file"
        content: 'not okay'
      .file.cache
        source: 'http://localhost:12345/my_file'
        cache_file: "#{scratch}/my_cache_file"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()

    they 'target file must match the hash', ({ssh}) ->
      nikita
        ssh: ssh
      .file.cache
        source: 'http://localhost:12345/missing'
        cache_dir: "#{scratch}/cache"
        md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        relax: true
      , (err) ->
        err.message.should.eql "Invalid Target Hash: target \"#{scratch}/cache/missing\" got 9e076f5885f5cc16a4b5aeb8de4adff5 instead of xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      .promise()

    they 'md5', ({ssh}) ->
      logs = []
      nikita
        ssh: ssh
      .on 'text', (log) -> logs.push "[#{log.level}] #{log.message}"
      .file
        target: "#{scratch}/source"
        content: "okay"
      .file
        target: "#{scratch}/target"
        content: "okay"
      # In http mode, md5 value will not be calculated from source
      .file.cache
        source: 'http://localhost:12345/my_file'
        cache_file: "#{scratch}/target"
        md5: true
      , (err, {status}) ->
        status.should.be.false() unless err # because target exists
        ("[WARN] Bypass source hash computation for non-file protocols" in logs).should.be.true() unless err
        logs = []
      .file.cache
        source: 'http://localhost:12345/my_file'
        cache_file: "#{scratch}/target"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, {status}) ->
        status.should.be.false() unless err
        ("[DEBUG] Hashes match, skipping" in logs).should.be.true() unless err
        logs = []
      .file.cache
        source: 'http://localhost:12345/my_file'
        cache_file: "#{scratch}/target"
        md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        relax: true
      , (err, {status}) ->
        err.message.should.eql "Invalid Target Hash: target \"#{scratch}/target\" got df8fede7ff71608e24a5576326e41c75 instead of xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      .promise()
