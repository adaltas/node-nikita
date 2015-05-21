
http = require 'http'
mecano = require "../src"
test = require './test'
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
        downloaded.should.be.ok
      .call (next) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          return next err if err
          content.should.equal 'okay'
          next()
      .download # Download on an existing file
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.not.be.ok
        next()

    they 'detect change', (ssh, next) ->
      ssh = null
      @timeout 100000
      count = 0
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
        downloaded.should.be.ok
      .call (next) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          return next err if err
          content.should.equal 'okay'
          next()
      .download # Download on an existing file with same content
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.False
        next()

    they 'with specified cache file', (ssh, next) ->
      @timeout 100000
      count = 0
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
        downloaded.should.be.ok
        fs.readFile null, cache, 'ascii', (err, content) ->
          return next err if err
          content.should.equal 'okay'
          next()

    they 'with specified cache dir', (ssh, next) ->
      @timeout 100000
      count = 0
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
        downloaded.should.be.ok
        fs.exists null, "#{scratch}/cache_dir/localhost:12345", (err, exists) ->
          return next err if err
          exists.should.be.ok
          next()

    they 'with specified cache file but disabled', (ssh, next) ->
      @timeout 100000
      count = 0
      # Download a non existing file
      source = 'http://localhost:12345'
      destination = "#{scratch}/download"
      mecano.download
        ssh: ssh
        source: source
        destination: destination
        cache_file: "#{scratch}/cache_dir/not_exists"
        cache_dir: false
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.ok
        fs.exists null, "#{scratch}/cache_dir/not_exists", (err, exists) ->
          return next err if err
          exists.should.not.be.ok
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
        downloaded.should.be.ok
      .call (next) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          return next err if err
          content.should.equal 'okay'
          next()
      .download # Download on an existing file
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.not.be.ok
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
          downloaded.should.be.ok
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
          downloaded.should.be.true
        .download
          source: source
          destination: destination
          md5: 'df8fede7ff71608e24a5576326e41c75'
        , (err, downloaded) ->
          return next err if err
          downloaded.should.not.be.ok
          next()

      they 'is computed if true', (ssh, next) ->
        return next() unless ssh
        # Download with invalid checksum
        source = "#{__filename}"
        destination = "#{scratch}/check_md5"
        mecano
          ssh: ssh
        .download
          source: source
          destination: destination
          md5: true
        , (err, downloaded) ->
          downloaded.should.be.true unless err
        .download
          source: source
          destination: destination
          md5: true
        , (err, downloaded) ->
          downloaded.should.be.false unless err
        .then next


  # describe 'ftp', ->

  #   it 'should deal with ftp protocol', (next) ->
  #     @timeout 10000
  #     source = 'ftp://ftp.gnu.org/gnu/glibc/README.glibc'
  #     destination = "#{scratch}/download_test"
  #     # Download a non existing file
  #     mecano.download
  #       source: source
  #       destination: destination
  #     , (err, downloaded) ->
  #       return next err if err
  #       downloaded.should.eql 1
  #       fs.readFile destination, 'ascii', (err, content) ->
  #         content.should.equal 'GNU'
  #         # Download on an existing file
  #         mecano.download
  #           source: source
  #           destination: destination
  #         , (err, downloaded) ->
  #           return next err if err
  #           downloaded.should.eql 0
  #           next()

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
        downloaded.should.be.ok
      .call (next) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          return next err if err
          content.should.containEql 'yeah'
          next()
      .download
        source: source
        destination: destination # Download on an existing file
      , (err, downloaded) ->
        return next err if err
        downloaded.should.not.be.ok
        next()

    they 'should default to file without protocol', (ssh, next) ->
      source = "/#{__filename}"
      destination = "#{scratch}/download_test"
      # Download a non existing file
      mecano
        ssh: ssh
      .download
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.be.ok
      .call (next) ->
        fs.readFile @options.ssh, destination, 'ascii', (err, content) ->
          content.should.containEql 'yeah'
          next()
      .download # Download on an existing file
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.not.be.ok
        next()
