
http = require 'http'
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'download url', ->

  scratch = test.scratch @
  
  server = null

  beforeEach (next) ->
    server = http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'okay'
    server.listen 12345, next

  afterEach (next) ->
    server.close()
    server.on 'close', next

  they 'download without cache and md5', (ssh, next) ->
    @timeout 100000
    # Download a non existing file
    mecano
      ssh: ssh
    .download
      source: 'http://localhost:12345'
      target: "#{scratch}/download"
    , (err, status) ->
      status.should.be.true() unless err
    .call (_, callback) ->
      fs.readFile @options.ssh, "#{scratch}/download", 'ascii', (err, content) ->
        content.should.equal 'okay' unless err
        callback()
    .download # Download on an existing file
      source: 'http://localhost:12345'
      target: "#{scratch}/download"
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'should chmod', (ssh, next) ->
    @timeout 10000
    mecano
      ssh: ssh
    .download
      source: 'http://localhost:12345'
      target: "#{scratch}/download_test"
      mode: 0o0770
    , (err, status) ->
      status.should.be.true() unless err
    .call (_, callback) ->
      fs.stat @options.ssh, "#{scratch}/download_test", (err, stat) ->
        misc.mode.compare(stat.mode, 0o0770).should.be.true() unless err
        callback()
    .then next

  describe 'cache', ->

    they 'cache file', (ssh, next) ->
      @timeout 100000
      # Download a non existing file
      mecano
        ssh: ssh
      .download
        source: 'http://localhost:12345'
        target: "#{scratch}/target"
        cache_file: "#{scratch}/cache_file"
      , (err, status) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        fs.readFile @options.ssh, "#{scratch}/cache_file", 'ascii', (err, content) ->
          content.should.equal 'okay' unless err
          callback()
      .call (_, callback) ->
        fs.readFile @options.ssh, "#{scratch}/target", 'ascii', (err, content) ->
          content.should.equal 'okay' unless err
          callback()
      .then next

    they 'cache file defined globally', (ssh, next) ->
      @timeout 100000
      # Download a non existing file
      source = 'http://localhost:12345'
      target = "#{scratch}/download"
      cache = "#{scratch}/cache_file"
      mecano(cache_file: cache).download
        ssh: ssh
        source: source
        target: target
      , (err, status) ->
        return next err if err
        status.should.be.true()
        fs.readFile null, cache, 'ascii', (err, content) ->
          return next err if err
          content.should.equal 'okay'
          next()

    they 'cache dir', (ssh, next) ->
      @timeout 100000
      # Download a non existing file
      source = 'http://localhost:12345'
      target = "#{scratch}/download"
      mecano.download
        ssh: ssh
        source: source
        target: target
        cache_dir: "#{scratch}/cache_dir"
      , (err, status) ->
        return next err if err
        status.should.be.true()
        fs.exists null, "#{scratch}/cache_dir/localhost:12345", (err, exists) ->
          return next err if err
          exists.should.be.true()
          next()

  describe 'md5', ->

    they 'use shortcircuit if target match md5', (ssh, next) ->
      logs = []
      mecano
        ssh: ssh
      .on 'text', (log) -> logs.push "[#{log.level}] #{log.message}"
      .write
        content: "okay"
        target: "#{scratch}/target"
      .download
        source: 'http://localhost:12345'
        target: "#{scratch}/target"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, status) ->
        status.should.be.false() unless err
      .call ->
        ("[INFO] Destination with valid signature, download aborted" in logs).should.be.true()
      .then next

    they 'bypass shortcircuit if target dont match md5', (ssh, next) ->
      logs = []
      mecano
        ssh: ssh
      .on 'text', (log) -> logs.push "[#{log.level}] #{log.message}"
      .write
        content: "not okay"
        target: "#{scratch}/target"
      .download
        source: 'http://localhost:12345'
        target: "#{scratch}/target"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, status) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        fs.readFile ssh, "#{scratch}/target", 'ascii', (err, content) ->
          content.should.equal 'okay' unless err
          callback err
      .then next

    they 'check signature on downloaded file', (ssh, next) ->
      # Download with invalid checksum
      mecano
        ssh: ssh
      .download
        source: 'http://localhost:12345'
        target: "#{scratch}/target"
        md5: '2f74dbbee4142b7366c93b115f914fff'
        # relax: true
      , (err, status) ->
        err.message.should.eql "Invalid downloaded checksum, found 'df8fede7ff71608e24a5576326e41c75' instead of '2f74dbbee4142b7366c93b115f914fff'"
        next()
      # .then next

    they 'count 1 if new file has correct checksum', (ssh, next) ->
      # Download with invalid checksum
      source = 'http://localhost:12345'
      target = "#{scratch}/check_md5"
      mecano.download
        ssh: ssh
        source: source
        target: target
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, status) ->
        return next err if err
        status.should.be.true()
        next()

    they 'count 0 if a file exist with same checksum', (ssh, next) ->
      # Download with invalid checksum
      source = 'http://localhost:12345'
      target = "#{scratch}/check_md5"
      mecano
        ssh: ssh
      .download
        source: source
        target: target
      , (err, status) ->
        return next err if err
        status.should.be.true()
      .download
        source: source
        target: target
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, status) ->
        return next err if err
        status.should.be.false()
        next()
