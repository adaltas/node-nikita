
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
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
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
      , (err, status) ->
        status.should.be.true() unless err
      .cache
        source: 'http://localhost:12345/my_file'
        cache_dir: "#{scratch}/my_cache_dir"
      , (err, status) ->
        status.should.be.false() unless err
      .call (_, callback) ->
        fs.exists null, "#{scratch}/my_cache_dir/my_file", (err, exists) ->
          exists.should.be.true()
          callback err
      .then next
        
