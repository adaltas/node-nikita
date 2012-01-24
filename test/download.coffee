
assert = require 'assert'
fs = require 'fs'
http = require 'http'
mecano = require '../'

module.exports =
    'simple # http': (next) ->
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
            assert.ifError err
            assert.eql downloaded, 1
            fs.readFile destination, 'ascii', (err, content) ->
                assert.eql content, 'okay'
                # Download on an existing file
                mecano.download
                    source: source
                    destination: destination
                , (err, downloaded) ->
                    assert.ifError err
                    assert.eql downloaded, 0
                    server.close()
                    fs.unlink destination, next
    'simple # ftp': (next) ->
        source = 'ftp://ftp.gnu.org/gnu/glibc/README.glibc'
        destination = "#{__dirname}/download_test"
        # Download a non existing file
        mecano.download
            source: 
            destination: destination
        , (err, downloaded) ->
            assert.ifError err
            assert.eql downloaded, 1
            fs.readFile destination, 'ascii', (err, content) ->
                assert.ok content.indexOf('GNU') isnt -1
                # Download on an existing file
                mecano.download
                    source: 
                    destination: destination
                , (err, downloaded) ->
                    assert.ifError err
                    assert.eql downloaded, 0
                    fs.unlink destination, next
    'simple # file': (next) ->
        source = "file://#{__filename}"
        destination = "#{__dirname}/download_test"
        # Download a non existing file
        mecano.download
            source: source
            destination: destination
        , (err, downloaded) ->
            assert.ifError err
            assert.eql downloaded, 1
            fs.readFile destination, 'ascii', (err, content) ->
                assert.ok content.indexOf('yeah') isnt -1
                # Download on an existing file
                mecano.download
                    source: source
                    destination: destination
                , (err, downloaded) ->
                    assert.ifError err
                    assert.eql downloaded, 0
                    fs.unlink destination, next



