
http = require 'http'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
path = require 'path'

describe 'cache', ->

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

    they 'into local cache_dir', (ssh, next) ->
      mecano
        ssh: ssh
      .cache
        source: 'http://localhost:12345/my_file'
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status, file) ->
        status.should.be.true() unless err
        file.should.eql "#{scratch}/my_cache_dir/my_file"
      .cache
        source: 'http://localhost:12345/my_file'
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status, file) ->
        status.should.be.false() unless err
        file.should.eql "#{scratch}/my_cache_dir/my_file"
      .call (_, callback) ->
        fs.exists null, "#{scratch}/my_cache_dir/my_file", (err, exists) ->
          exists.should.be.true()
          callback err
      .then next

    they 'option fail with invalid exit code', (ssh, next) ->
      mecano
        ssh: ssh
      .cache
        source: 'http://localhost:12345/missing'
        cache_dir: "#{scratch}/cache_dir_1"
      , (err, status) ->
        (err is undefined).should.be.true()
      .cache
        source: 'http://localhost:12345/missing'
        cache_dir: "#{scratch}/cache_dir_2"
        fail: true
        relax: true
      , (err, status) ->
        err.message.should.eql 'Invalid Exit Code: 22'
      .then next

    describe 'md5', ->
      
      they 'bypass cache if string match', (ssh, next) ->
        logs = []
        mecano
          ssh: ssh
        .on 'text', (log) -> logs.push "[#{log.level}] #{log.message}"
        .write
          destination: "#{scratch}/source"
          content: "okay"
        .write
          destination: "#{scratch}/destination"
          content: "okay"
        # In http mode, md5 value will not be calculated from source
        .cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{scratch}/destination"
          md5: true
          debug: true
        , (err, status, file) ->
          status.should.be.false() unless err # because destination exists
          ("[WARN] Bypass source hash computation for non-file protocols" in logs).should.be.true() unless err
          logs = []
        .cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{scratch}/destination"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        , (err, status, file) ->
          status.should.be.false() unless err
          ("[DEBUG] Hashes match, skipping" in logs).should.be.true() unless err
          logs = []
        .cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{scratch}/destination"
          md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        , (err, status, file) ->
          status.should.be.true() unless err
          ("[WARN] Hashes don\'t match, delete then re-download" in logs).should.be.true() unless err
        .then next

  describe 'file', ->

    they 'into local cache_dir', (ssh, next) ->
      mecano
        ssh: ssh
      .cache
        source: "#{__filename}"
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status, file) ->
        status.should.be.true() unless err
        file.should.eql "#{scratch}/my_cache_dir/#{path.basename __filename}"
      .cache
        source: "#{__filename}"
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status, file) ->
        status.should.be.false() unless err
        file.should.eql "#{scratch}/my_cache_dir/#{path.basename __filename}"
      .call (_, callback) ->
        fs.exists null, "#{scratch}/my_cache_dir/#{path.basename __filename}", (err, exists) ->
          exists.should.be.true()
          callback err
      .then next

    describe 'md5', ->
      
      they 'bypass cache if string match', (ssh, next) ->
        logs = []
        mecano
          ssh: ssh
        .on 'text', (log) -> logs.push "[#{log.level}] #{log.message}"
        .write
          destination: "#{scratch}/source"
          content: "okay"
        .write
          destination: "#{scratch}/destination"
          content: "okay"
        # In file mode, md5 value will be calculated from source
        .cache
          source: "#{scratch}/source"
          cache_file: "#{scratch}/destination"
          md5: true
        , (err, status, file) ->
          status.should.be.false() unless err
          ('[DEBUG] Hashes match, skipping' in logs).should.be.true() unless err
          logs = []
        .cache
          source: "#{scratch}/source"
          cache_file: "#{scratch}/destination"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        , (err, status, file) ->
          status.should.be.false() unless err
          ('[DEBUG] Hashes match, skipping' in logs).should.be.true() unless err
          logs = []
        .cache
          source: "#{scratch}/source"
          cache_file: "#{scratch}/destination"
          md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        , (err, status, file) ->
          status.should.be.true() unless err
          ("[WARN] Hashes don't match, delete then re-download" in logs).should.be.true() unless err
        .then next
          
