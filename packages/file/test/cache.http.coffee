
http = require 'http'
path = require 'path'
nikita = require '@nikitajs/engine/src'
{tags, ssh, tmpdir} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.cache http', ->

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

  they 'handles string argument', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.cache 'http://localhost:12345/my_file',
        cache_dir: "#{tmpdir}/my_cache_dir"
      .should.be.finally.containEql status: true
      @fs.assert
        target: "#{tmpdir}/my_cache_dir/my_file"

  they 'into local cache_dir', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.cache
        source: 'http://localhost:12345/my_file'
        cache_dir: "#{tmpdir}/my_cache_dir"
      .should.be.finally.containEql status: true
      @file.cache
        source: 'http://localhost:12345/my_file'
        cache_dir: "#{tmpdir}/my_cache_dir"
      .should.be.finally.containEql status: false
      @fs.assert
        target: "#{tmpdir}/my_cache_dir/my_file"

  they 'option fail with invalid exit code', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.cache
        source: 'http://localhost:12345/missing'
        cache_dir: "#{tmpdir}/cache_dir_1"
      .should.be.finally.containEql status: true
      @file.cache
        source: 'http://localhost:12345/missing'
        cache_dir: "#{tmpdir}/cache_dir_2"
        fail: true
      .should.be.rejectedWith exit_code: 22

  describe 'hash', ->

    they 'current cache file matches provided hash', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @log.fs
          basedir: tmpdir
          serializer: text: (log) -> "#{log.message}\n"
        @file
          target: "#{tmpdir}/my_cache_file"
          content: 'okay'
        @file.cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{tmpdir}/my_cache_file"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        .should.be.finally.containEql status: false
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
          encoding: 'utf8'
        (data.includes 'Hashes match, skipping').should.be.true()

    they 'current cache file doesnt match provided hash', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/my_cache_file"
          content: 'not okay'
        @file.cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{tmpdir}/my_cache_file"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        .should.be.finally.containEql status: true

    they 'target file must match the hash', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.cache
          source: 'http://localhost:12345/missing'
          cache_dir: "#{tmpdir}/cache"
          md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        .should.be.rejectedWith message: "NIKITA_FILE_INVALID_TARGET_HASH: target \"#{tmpdir}/cache/missing\" got 9e076f5885f5cc16a4b5aeb8de4adff5 instead of xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    they 'md5', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @log.fs
          basedir: tmpdir
          serializer: text: (log) -> "[#{log.level}] #{log.message}\n"
        @file
          target: "#{tmpdir}/source"
          content: "okay"
        @file
          target: "#{tmpdir}/target"
          content: "okay"
        # In http mode, md5 value will not be calculated from source
        @file.cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{tmpdir}/target"
          md5: true
        .should.be.finally.containEql status: false
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
          encoding: 'utf8'
        (data.includes "[WARN] Bypass source hash computation for non-file protocols").should.be.true()
        @file.cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{tmpdir}/target"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        .should.be.finally.containEql status: false
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
          encoding: 'utf8'
        (data.includes "[DEBUG] Hashes match, skipping").should.be.true()
        @file.cache
          source: 'http://localhost:12345/my_file'
          cache_file: "#{tmpdir}/target"
          md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        .should.be.rejectedWith message: "NIKITA_FILE_INVALID_TARGET_HASH: target \"#{tmpdir}/target\" got df8fede7ff71608e24a5576326e41c75 instead of xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
