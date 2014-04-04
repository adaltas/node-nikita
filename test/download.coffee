
fs = require 'fs'
http = require 'http'
should = require 'should'
connect = require 'ssh2-exec/lib/connect'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'ssh2-exec/lib/they'

describe 'download', ->

  scratch = test.scratch @

  they 'http', (ssh, next) ->
    @timeout 100000
    # create server
    server = http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'okay'
    server.listen 12345
    # Download a non existing file
    source = 'http://127.0.0.1:12345'
    destination = "#{scratch}/download"
    mecano.download
      ssh: ssh
      source: source
      destination: destination
    , (err, downloaded) ->
      return next err if err
      downloaded.should.eql 1
      misc.file.readFile ssh, destination, 'ascii', (err, content) ->
        return next err if err
        content.toString().should.include 'okay'
        # Download on an existing file
        mecano.download
          ssh: ssh
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.eql 0
          server.close()
          server.on 'close', next

  they 'http detect change', (ssh, next) ->
    ssh = null
    @timeout 100000
    # create server
    count = 0
    server = http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end "okay #{count++}"
    server.listen 12345
    # Download a non existing file
    source = 'http://127.0.0.1:12345'
    destination = "#{scratch}/download"
    mecano.download
      ssh: ssh
      source: source
      destination: destination
    , (err, downloaded) ->
      return next err if err
      downloaded.should.eql 1
      misc.file.readFile ssh, destination, 'ascii', (err, content) ->
        return next err if err
        content.toString().should.include 'okay 0'
        # Download on an existing file
        mecano.download
          ssh: ssh
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.eql 1
          server.close()
          server.on 'close', next

  they 'should chmod', (ssh, next) ->
    @timeout 10000
    # create server
    server = http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'okay'
    server.listen 12345
    # Download a non existing file
    source = 'http://127.0.0.1:12345'
    destination = "#{scratch}/download_test"
    mecano.download
      ssh: ssh
      source: source
      destination: destination
      mode: '0770'
    , (err, downloaded) ->
      return next err if err
      downloaded.should.eql 1
      misc.file.readFile ssh, destination, 'ascii', (err, content) ->
        content.should.include 'okay'
        # Download on an existing file
        mecano.download
          ssh: ssh
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.eql 0
          server.close()
          server.on 'close', next
  
  # it 'should deal with ftp protocol', (next) ->
  #   @timeout 10000
  #   source = 'ftp://ftp.gnu.org/gnu/glibc/README.glibc'
  #   destination = "#{scratch}/download_test"
  #   # Download a non existing file
  #   mecano.download
  #     source: source
  #     destination: destination
  #   , (err, downloaded) ->
  #     return next err if err
  #     downloaded.should.eql 1
  #     fs.readFile destination, 'ascii', (err, content) ->
  #       content.should.include 'GNU'
  #       # Download on an existing file
  #       mecano.download
  #         source: source
  #         destination: destination
  #       , (err, downloaded) ->
  #         return next err if err
  #         downloaded.should.eql 0
  #         next()
  
  they 'should deal with file protocol', (ssh, next) ->
    source = "file://#{__filename}"
    destination = "#{scratch}/download_test"
    # Download a non existing file
    mecano.download
      ssh: ssh
      source: source
      destination: destination
    , (err, downloaded) ->
      return next err if err
      downloaded.should.eql 1
      misc.file.readFile ssh, destination, 'ascii', (err, content) ->
        content.should.include 'yeah'
        # Download on an existing file
        mecano.download
          ssh: ssh
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.eql 0
          next()
  
  they 'should default to file without protocol', (ssh, next) ->
    source = "/#{__filename}"
    destination = "#{scratch}/download_test"
    # Download a non existing file
    mecano.download
      ssh: ssh
      source: source
      destination: destination
    , (err, downloaded) ->
      return next err if err
      downloaded.should.eql 1
      misc.file.readFile ssh, destination, 'ascii', (err, content) ->
        content.should.include 'yeah'
        # Download on an existing file
        mecano.download
          ssh: ssh
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.eql 0
          next()

  describe 'md5', ->

    they 'throw error if checksum doesnt match', (ssh, next) ->
      # create server
      server = http.createServer (req, res) ->
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      server.listen 12345
      # Download with invalid checksum
      source = 'http://127.0.0.1:12345'
      destination = "#{scratch}/check_md5"
      mecano.download
        ssh: ssh
        source: source
        destination: destination
        md5sum: '2f74dbbee4142b7366c93b115f914fff'
      , (err, downloaded) ->
        err.message.should.eql 'Invalid checksum, found "df8fede7ff71608e24a5576326e41c75" instead of "2f74dbbee4142b7366c93b115f914fff"'
        server.close()
        server.on 'close', next

    they 'count 1 if new file has correct checksum', (ssh, next) ->
      # create server
      server = http.createServer (req, res) ->
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      server.listen 12345
      # Download with invalid checksum
      source = 'http://127.0.0.1:12345'
      destination = "#{scratch}/check_md5"
      mecano.download
        ssh: ssh
        source: source
        destination: destination
        md5sum: 'df8fede7ff71608e24a5576326e41c75'
      , (err, downloaded) ->
        return next err if err
        downloaded.should.eql 1
        server.close()
        server.on 'close', next

    they 'count 0 if a file exist with same checksum', (ssh, next) ->
      # create server
      server = http.createServer (req, res) ->
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      server.listen 12345
      # Download with invalid checksum
      source = 'http://127.0.0.1:12345'
      destination = "#{scratch}/check_md5"
      mecano.download
        ssh: ssh
        source: source
        destination: destination
      , (err, downloaded) ->
        return next err if err
        downloaded.should.eql 1
        mecano.download
          ssh: ssh
          source: source
          destination: destination
          md5sum: 'df8fede7ff71608e24a5576326e41c75'
        , (err, downloaded) ->
          return next err if err
          downloaded.should.eql 0
          server.close()
          server.on 'close', next

