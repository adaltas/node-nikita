
http = require 'http'
# path = require 'path'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

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
        (err is null).should.be.true()
      .cache
        source: 'http://localhost:12345/missing'
        cache_dir: "#{scratch}/cache_dir_2"
        fail: true
        relax: true
      , (err, status) ->
        err.message.should.eql 'Invalid Exit Code: 22'
      .then next
        
