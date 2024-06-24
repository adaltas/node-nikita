
import http from 'node:http'
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.download url', ->
  return unless test.tags.posix
  
  server = null

  beforeEach (next) ->
    server = http.createServer (req, res) ->
      # res.writeHead 200, {'Content-Type': 'text/plain'}
      # res.end 'okay'
      switch req.url
        when '/http_headers'
          # res.setHeader 'Content-Type', 'application/json'
          # res.writeHead 200, {'Content-Type': 'text/plain'}
          # res.end 'okay'
          res.writeHead 200, {'Content-Type': 'application/json'}
          res.end JSON.stringify req.headers
        else
          res.writeHead 200, {'Content-Type': 'text/plain'}
          res.end 'okay'
    server.listen 12345, next

  afterEach (next) ->
    server.close()
    server.on 'close', next

  they 'download without cache and md5', ({ssh}) ->
    # @timeout 100000
    # Download a non existing file
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.download
        source: 'http://localhost:12345'
        target: "#{tmpdir}/download"
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/download"
        content: /okay/
      await @file.download # Download on an existing file
        source: 'http://localhost:12345'
        target: "#{tmpdir}/download"
      .should.be.finally.containEql $status: false

  they 'option `mode`', ({ssh}) ->
    # @timeout 10000
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.download
        source: 'http://localhost:12345'
        target: "#{tmpdir}/download_test"
        mode: 0o0770
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/download_test"
        mode: 0o0770

  they 'option `header`', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.download
        http_headers: [
          'Authorization: Bearer MY_SECRET'
        ]
        source: 'http://localhost:12345/http_headers'
        target: "#{tmpdir}/download_test"
        mode: 0o0770
      {data} = await @fs.readFile "#{tmpdir}/download_test"
      data = JSON.parse(data)
      data.should.match authorization: 'Bearer MY_SECRET'

  describe 'cache', ->

    they 'cache file', ({ssh}) ->
      @timeout 100000
      # Download a non existing file
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file.download
          source: 'http://localhost:12345'
          target: "#{tmpdir}/target"
          cache: true
          cache_file: "#{tmpdir}/cache_file"
        .should.be.finally.containEql $status: true
        await @fs.assert
          target: "#{tmpdir}/cache_file"
          content: /okay/
        await @fs.assert
          target: "#{tmpdir}/target"
          content: /okay/

    they 'cache file defined globally', ({ssh}) ->
      @timeout 100000
      # Download a non existing file
      nikita
        $ssh: ssh
        $templated: true
        $tmpdir: true
        cache_file: "{{metadata.tmpdir}}/cache_file"
      , ({metadata: {tmpdir}}) ->
        await @file.download
          $ssh: ssh
          source: 'http://localhost:12345'
          target: "#{tmpdir}/download"
        .should.be.finally.containEql $status: true
        await @fs.assert
          $ssh: null
          target: "#{tmpdir}/cache_file"
          content: 'okay'

    they 'cache dir', ({ssh}) ->
      @timeout 100000
      # Download a non existing file
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file.download
          $ssh: ssh
          source: 'http://localhost:12345'
          target: "#{tmpdir}/download"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
        .should.be.finally.containEql $status: true
        await @fs.assert
          $ssh: null
          target: "#{tmpdir}/cache_dir/localhost:12345"

  describe 'md5', ->

    they 'use shortcircuit if target match md5', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @log.fs
          basedir: tmpdir
          serializer: text: (log) -> "[#{log.level}] #{log.message}\n"
        await @file
          content: 'okay'
          target: "#{tmpdir}/target"
        await @file.download
          source: 'http://localhost:12345'
          target: "#{tmpdir}/target"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        .should.be.finally.containEql $status: false
        {data} = await @fs.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'utf8'
        (data.includes "[INFO] Destination with valid signature, download aborted").should.be.true()

    they 'bypass shortcircuit if target dont match md5', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file
          content: "not okay"
          target: "#{tmpdir}/target"
        await @file.download
          source: 'http://localhost:12345'
          target: "#{tmpdir}/target"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        .should.be.finally.containEql $status: true
        await @fs.assert
          target: "#{tmpdir}/target"
          content: /okay/

    they 'check signature on downloaded file', ({ssh}) ->
      # Download with invalid checksum
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file.download
          md5: '2f74dbbee4142b7366c93b115f914fff'
          source: 'http://localhost:12345'
          target: "#{tmpdir}/target"
        .should.be.rejectedWith message: "Invalid downloaded checksum, found 'df8fede7ff71608e24a5576326e41c75' instead of '2f74dbbee4142b7366c93b115f914fff'"

    they 'count 1 if new file has correct checksum', ({ssh}) ->
      # Download with invalid checksum
      nikita
        $tmpdir: true
        $ssh: ssh
      , ({metadata: {tmpdir}}) ->
        await @file.download
          md5: 'df8fede7ff71608e24a5576326e41c75'
          source: 'http://localhost:12345'
          target: "#{tmpdir}/check_md5"
        .should.be.finally.containEql $status: true

    they 'count 0 if a file exist with same checksum', ({ssh}) ->
      # Download with invalid checksum
      nikita
        $tmpdir: true
        $ssh: ssh
      , ({metadata: {tmpdir}}) ->
        await @file.download
          source: 'http://localhost:12345'
          target: "#{tmpdir}/check_md5"
        await @file.download
          md5: 'df8fede7ff71608e24a5576326e41c75'
          source: 'http://localhost:12345'
          target: "#{tmpdir}/check_md5"
        .should.be.finally.containEql $status: false
      
  describe 'error', ->

    they 'path must be absolute over ssh', ({ssh}) ->
      return unless ssh
      nikita
        $tmpdir: true
        $ssh: ssh
      , ({metadata: {tmpdir}}) ->
        await @file.download
          source: "http://localhost/sth"
          target: "a_dir/download_test"
        .should.be.rejectedWith message: 'Non Absolute Path: target is "a_dir/download_test", SSH requires absolute paths, you must provide an absolute path in the target or the cwd option'
