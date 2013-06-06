
fs = require 'fs'
http = require 'http'
should = require 'should'
connect = require 'superexec/lib/connect'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require './they'

describe 'download', ->

  scratch = test.scratch @

  they 'should deal with http protocol', (ssh, next) ->
    @timeout 10000
    # create server
    server = http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'okay'
    server.listen 12345
    # Download a non existing file
    source = 'http://127.0.0.1:12345'
    destination = "#{scratch}/download_#{if ssh then 'remote' else 'local'}"
    mecano.download
      ssh: ssh
      source: source
      destination: destination
    , (err, downloaded) ->
      return next err if err
      downloaded.should.eql 1
      misc.file.readFile ssh, destination, 'ascii', (err, content) ->
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
      chmod: '0770'
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
  
  it.skip 'should deal with ftp protocol', (next) ->
    @timeout 10000
    source = 'ftp://ftp.gnu.org/gnu/glibc/README.glibc'
    destination = "#{scratch}/download_test"
    # Download a non existing file
    mecano.download
      source: source
      destination: destination
    , (err, downloaded) ->
      return next err if err
      downloaded.should.eql 1
      fs.readFile destination, 'ascii', (err, content) ->
        content.should.include 'GNU'
        # Download on an existing file
        mecano.download
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.eql 0
          next()
  
  it 'should deal with ssh protocol', (next) ->
    source = "#{__filename}"
    destination = "#{scratch}/download_test"
    # Download a non existing file
    connect host: 'localhost', (err, ssh) ->
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
  
  it 'should deal with file protocol', (next) ->
    source = "file://#{__filename}"
    destination = "#{scratch}/download_test"
    # Download a non existing file
    mecano.download
      source: source
      destination: destination
    , (err, downloaded) ->
      return next err if err
      downloaded.should.eql 1
      misc.file.readFile null, destination, 'ascii', (err, content) ->
        content.should.include 'yeah'
        # Download on an existing file
        mecano.download
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.eql 0
          next()
  
  it 'should default to file without protocol', (next) ->
    source = "/#{__filename}"
    destination = "#{scratch}/download_test"
    # Download a non existing file
    mecano.download
      source: source
      destination: destination
    , (err, downloaded) ->
      return next err if err
      downloaded.should.eql 1
      fs.readFile destination, 'ascii', (err, content) ->
        content.should.include 'yeah'
        # Download on an existing file
        mecano.download
          source: source
          destination: destination
        , (err, downloaded) ->
          return next err if err
          downloaded.should.eql 0
          next()



