
fs = require 'fs'
http = require 'http'
should = require 'should'
mecano = require '../'

describe 'download', ->

    # beforeEach (next) ->
    #     next()

    it 'should deal with http scheme', (next) ->
        source = 'http://127.0.0.1:12345'
        destination = "#{__dirname}/download_test"
        server = http.createServer (req, res) ->
            res.writeHead 200, {'Content-Type': 'text/plain'}
            res.end 'okay'
        server.listen 12345
        # Download a non existing file
        mecano.download
            source: source
            destination: destination
        , (err, downloaded) ->
            should.not.exist err
            downloaded.should.eql 1
            fs.readFile destination, 'ascii', (err, content) ->
                content.should.eql 'okay'
                # Download on an existing file
                mecano.download
                    source: source
                    destination: destination
                , (err, downloaded) ->
                    should.not.exist err
                    downloaded.should.eql 0
                    server.close()
                    fs.unlink destination, next
    
    it 'should deal with ftp scheme', (next) ->
        @timeout 10000
        source = 'ftp://ftp.gnu.org/gnu/glibc/README.glibc'
        destination = "#{__dirname}/download_test"
        # Download a non existing file
        mecano.download
            source: source
            destination: destination
        , (err, downloaded) ->
            should.not.exist err
            downloaded.should.eql 1
            fs.readFile destination, 'ascii', (err, content) ->
                content.should.include 'GNU'
                # Download on an existing file
                mecano.download
                    source: source
                    destination: destination
                , (err, downloaded) ->
                    should.not.exist err
                    downloaded.should.eql 0
                    fs.unlink destination, next
    
    it 'should deal with file scheme', (next) ->
        source = "file://#{__filename}"
        destination = "#{__dirname}/download_test"
        # Download a non existing file
        mecano.download
            source: source
            destination: destination
        , (err, downloaded) ->
            should.not.exist err
            downloaded.should.eql 1
            fs.readFile destination, 'ascii', (err, content) ->
                content.should.include 'yeah'
                # Download on an existing file
                mecano.download
                    source: source
                    destination: destination
                , (err, downloaded) ->
                    should.not.exist err
                    downloaded.should.eql 0
                    fs.unlink destination, next



