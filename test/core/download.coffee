
http = require 'http'
path = require 'path'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'download', ->

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
  
    they 'http', (ssh, next) ->
      @timeout 100000
      # Download a non existing file
      source = 'http://localhost:12345'
      destination = "#{scratch}/download"
      mecano
        ssh: ssh
      .download
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.true()
      .call (_, next) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          return next err if err
          content.should.equal 'okay'
          next()
      .download # Download on an existing file
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.false()
        next()
  
    they 'detect change', (ssh, next) ->
      ssh = null
      @timeout 100000
      # Download a non existing file
      source = 'http://localhost:12345'
      destination = "#{scratch}/download"
      mecano
        ssh: ssh
      .download
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.true()
      .call (_, next) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          return next err if err
          content.should.equal 'okay'
          next()
      .download # Download on an existing file with same content
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.false()
        next()
  
    they 'should chmod', (ssh, next) ->
      @timeout 10000
      # Download a non existing file
      source = 'http://localhost:12345'
      destination = "#{scratch}/download_test"
      mecano
        ssh: ssh
      .download
        source: source
        destination: destination
        mode: 0o770
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.true()
      .call (_, next) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          return next err if err
          content.should.equal 'okay'
          next()
      .download # Download on an existing file
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.false()
        next()
  
    describe 'cache', ->
  
      they 'cache file', (ssh, next) ->
        @timeout 100000
        # Download a non existing file
        source = 'http://localhost:12345'
        destination = "#{scratch}/download"
        cache = "#{scratch}/cache_file"
        mecano.download
          ssh: ssh
          source: source
          destination: destination
          cache_file: cache
        , (err, downloaded) ->
          return next err if err
          downloaded.should.be.true()
          fs.readFile null, cache, 'ascii', (err, content) ->
            return next err if err
            content.should.equal 'okay'
            next()
  
      they 'cache file defined globally', (ssh, next) ->
        @timeout 100000
        # Download a non existing file
        source = 'http://localhost:12345'
        destination = "#{scratch}/download"
        cache = "#{scratch}/cache_file"
        mecano(cache_file: cache).download
          ssh: ssh
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.be.true()
          fs.readFile null, cache, 'ascii', (err, content) ->
            return next err if err
            content.should.equal 'okay'
            next()
  
      they 'cache dir', (ssh, next) ->
        @timeout 100000
        # Download a non existing file
        source = 'http://localhost:12345'
        destination = "#{scratch}/download"
        mecano.download
          ssh: ssh
          source: source
          destination: destination
          cache_dir: "#{scratch}/cache_dir"
        , (err, downloaded) ->
          return next err if err
          downloaded.should.be.true()
          fs.exists null, "#{scratch}/cache_dir/localhost:12345", (err, exists) ->
            return next err if err
            exists.should.be.true()
            next()

    describe 'md5', ->

      they 'throw error if checksum doesnt match', (ssh, next) ->
        # Download with invalid checksum
        source = 'http://localhost:12345'
        destination = "#{scratch}/check_md5"
        mecano.download
          ssh: ssh
          source: source
          destination: destination
          md5: '2f74dbbee4142b7366c93b115f914fff'
        , (err, downloaded) ->
          err.message.should.eql 'Invalid checksum, found "df8fede7ff71608e24a5576326e41c75" instead of "2f74dbbee4142b7366c93b115f914fff"'
          next()

      they 'count 1 if new file has correct checksum', (ssh, next) ->
        # Download with invalid checksum
        source = 'http://localhost:12345'
        destination = "#{scratch}/check_md5"
        mecano.download
          ssh: ssh
          source: source
          destination: destination
          md5: 'df8fede7ff71608e24a5576326e41c75'
        , (err, downloaded) ->
          return next err if err
          downloaded.should.be.true()
          next()

      they 'count 0 if a file exist with same checksum', (ssh, next) ->
        # Download with invalid checksum
        source = 'http://localhost:12345'
        destination = "#{scratch}/check_md5"
        mecano
          ssh: ssh
        .download
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.be.true()
        .download
          source: source
          destination: destination
          md5: 'df8fede7ff71608e24a5576326e41c75'
        , (err, downloaded) ->
          return next err if err
          downloaded.should.be.false()
          next()

  describe 'file', ->

    they 'should deal with file protocol', (ssh, next) ->
      source = "file://#{__filename}"
      destination = "#{scratch}/download_test"
      mecano
        ssh: ssh
      .download
        source: source
        destination: destination # Download a non existing file
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.true()
      .call ({}, callback) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          content.should.containEql 'yeah' unless err
          callback err
      .download
        source: source
        destination: destination # Download on an existing file
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.false()
        next()

    they 'should default to file without protocol', (ssh, next) ->
      source = "#{__filename}"
      destination = "#{scratch}/download_test"
      # Download a non existing file
      mecano
        ssh: ssh
      .download
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.true()
      .call ({}, callback) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          content.should.containEql 'yeah' unless err
          callback err
      .download # Download on an existing file
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.false()
        next()

    describe 'cache', ->

      they 'cache,md5 with binary file', (ssh, next) ->
        source = "#{__dirname}/download.zip"
        destination = "#{scratch}/download"
        mecano.download
          ssh: ssh
          source: source
          destination: "#{scratch}/download_test"
          cache_dir: "#{scratch}/cache_dir"
          md5: '3f104676a5f72de08b811dbb725244ff'
        , (err, downloaded) ->
          return next err if err
          downloaded.should.be.true()
          fs.exists null, "#{scratch}/cache_dir/#{path.basename source}", (err, exists) ->
            return next err if err
            exists.should.be.true()
            next()

      they 'cache dir', (ssh, next) ->
        # Download a non existing file
        destination = "#{scratch}/download"
        mecano.download
          ssh: ssh
          source: "#{__filename}"
          destination: "#{scratch}/download_test"
          cache_dir: "#{scratch}/cache_dir"
        , (err, downloaded) ->
          return next err if err
          downloaded.should.be.true()
          fs.exists ssh, "#{scratch}/cache_dir/#{path.basename __filename}", (err, exists) ->
            return next err if err
            exists.should.be.true()
            next()
    
    describe 'md5', ->

      they 'cache dir with md5 string', (ssh, next) ->
        # Download a non existing file
        destination = "#{scratch}/download"
        mecano
          ssh: ssh
        .write
          destination: "#{scratch}/a_file"
          content: 'okay'
        .download
          source: "#{scratch}/a_file"
          destination: "#{scratch}/download_test"
          cache_dir: "#{scratch}/cache_dir"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        , (err, downloaded) ->
          return next err if err
          downloaded.should.be.true()
          fs.readFile ssh, "#{scratch}/cache_dir/a_file", 'ascii', (err, data) ->
            return next err if err
            data.should.eql 'okay'
            fs.readFile ssh, "#{scratch}/download_test", 'ascii', (err, data) ->
              return next err if err
              data.should.eql 'okay'
              next()

      they 'is computed if true', (ssh, next) ->
        return next() unless ssh
        logs = []
        # Download with invalid checksum
        destination = "#{scratch}/check_md5"
        mecano
          ssh: ssh
          log_serializer: (log) -> "[#{log.level}] #{log.message}"
        .write
          destination: "#{scratch}/source"
          content: "okay"
        .download
          source: "#{scratch}/source"
          destination: destination
          md5: true
        , (err, downloaded) ->
          downloaded.should.be.true() unless err
        .download
          source: "#{scratch}/source"
          destination: destination
          md5: true
          debug: true
          log: (msg) -> logs.push msg
        , (err, downloaded) ->
          downloaded.should.be.false() unless err
          ("[INFO] Computed hash value is 'df8fede7ff71608e24a5576326e41c75'" in logs).should.be.true()
          ("[DEBUG] Hashes match, skipping" in logs).should.be.true()
        .then next
