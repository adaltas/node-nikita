
http = require 'http'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
path = require 'path'

describe 'file.cache', ->

  scratch = test.scratch @

  describe 'http', ->

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

    they 'handles string argument', (ssh) ->
      nikita
        ssh: ssh
      .file.cache 'http://localhost:12345/my_file',
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status, file) ->
        status.should.be.true() unless err
        file.should.eql "#{scratch}/my_cache_dir/my_file" unless err
      .promise()

    they 'into local cache_dir', (ssh) ->
      nikita
        ssh: ssh
      .file.cache
        source: 'http://localhost:12345/my_file'
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status, file) ->
        status.should.be.true() unless err
        file.should.eql "#{scratch}/my_cache_dir/my_file" unless err
      .file.cache
        source: 'http://localhost:12345/my_file'
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status, file) ->
        status.should.be.false() unless err
        file.should.eql "#{scratch}/my_cache_dir/my_file"
      .file.assert
        target: "#{scratch}/my_cache_dir/my_file"
      .promise()

    they 'option fail with invalid exit code', (ssh) ->
      nikita
        ssh: ssh
      .file.cache
        source: 'http://localhost:12345/missing'
        cache_dir: "#{scratch}/cache_dir_1"
      , (err, status) ->
        (err is undefined).should.be.true()
      .file.cache
        source: 'http://localhost:12345/missing'
        cache_dir: "#{scratch}/cache_dir_2"
        fail: true
        relax: true
      , (err, status) ->
        err.message.should.eql 'Invalid Exit Code: 22'
      .promise()

    describe 'md5', ->

      they 'bypass cache if string match', (ssh) ->
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
        , (err, status, file) ->
          status.should.be.false() unless err # because target exists
          ("[WARN] Bypass source hash computation for non-file protocols" in logs).should.be.true() unless err
          logs = []
        .file.cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{scratch}/target"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        , (err, status, file) ->
          status.should.be.false() unless err
          ("[DEBUG] Hashes match, skipping" in logs).should.be.true() unless err
          logs = []
        .file.cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{scratch}/target"
          md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        , (err, status, file) ->
          status.should.be.true() unless err
          ("[WARN] Hashes don\'t match, delete then re-download" in logs).should.be.true() unless err
        .promise()

  describe 'file', ->

    they 'into local cache_dir', (ssh) ->
      nikita
        ssh: ssh
      .file.cache
        source: "#{__filename}"
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status, file) ->
        status.should.be.true() unless err
        file.should.eql "#{scratch}/my_cache_dir/#{path.basename __filename}"
      .file.cache
        source: "#{__filename}"
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status, file) ->
        status.should.be.false() unless err
        file.should.eql "#{scratch}/my_cache_dir/#{path.basename __filename}"
      .file.assert
        target: "#{scratch}/my_cache_dir/#{path.basename __filename}"
      .promise()

    describe 'md5', ->

      they 'bypass cache if string match', (ssh) ->
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
        # In file mode, md5 value will be calculated from source
        .file.cache
          source: "#{scratch}/source"
          cache_file: "#{scratch}/target"
          md5: true
        , (err, status, file) ->
          status.should.be.false() unless err
          ('[DEBUG] Hashes match, skipping' in logs).should.be.true() unless err
          logs = []
        .file.cache
          source: "#{scratch}/source"
          cache_file: "#{scratch}/target"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        , (err, status, file) ->
          status.should.be.false() unless err
          ('[DEBUG] Hashes match, skipping' in logs).should.be.true() unless err
          logs = []
        .file.cache
          source: "#{scratch}/source"
          cache_file: "#{scratch}/target"
          md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        , (err, status, file) ->
          status.should.be.true() unless err
          ("[WARN] Hashes don't match, delete then re-download" in logs).should.be.true() unless err
        .promise()
