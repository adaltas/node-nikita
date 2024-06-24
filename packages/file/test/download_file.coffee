
import path from 'node:path'
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.download file', ->
  return unless test.tags.posix
  
  describe 'source', ->

    they 'with file protocol', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file
          content: 'Where is my precious?'
          target: "#{tmpdir}/a_file"
        await @file.download
          source: "file://#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test" # Download a non existing file
        .should.be.finally.containEql $status: true
        await @fs.assert
          target: "#{tmpdir}/download_test"
          content: /precious/
        await @file.download
          source: "file://#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test" # Download on an existing file
        .should.be.finally.containEql $status: false

    they 'without protocol', ({ssh}) ->
      # Download a non existing file
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file
          content: 'Where is my precious?'
          target: "#{tmpdir}/a_file"
        await @file.download
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
        .should.be.finally.containEql $status: true
        await @fs.assert
          target: "#{tmpdir}/download_test"
          content: /precious/
        await @file.download # Download on an existing file
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
        .should.be.finally.containEql $status: false

    they 'doesnt exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file.download
          source: "#{tmpdir}/doesnotexists"
          target: "#{tmpdir}/download_test"
        .should.be.rejectedWith message: "NIKITA_FS_STAT_TARGET_ENOENT: failed to stat the target, no file exists for target, got \"#{tmpdir}/doesnotexists\""

    they 'into an existing directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file.touch
          target: "#{tmpdir}/a_file"
        await @fs.mkdir
          target: "#{tmpdir}/download_test"
        await @file.download
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
        await @fs.assert
          target: "#{tmpdir}/download_test/a_file"

  describe 'cache', ->

    they 'cache dir', ({ssh}) ->
      # Download a non existing file
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file
          content: 'Where is my precious?'
          target: "#{tmpdir}/a_file"
        await @file.download
          $ssh: ssh
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
        .should.be.finally.containEql $status: true
        await @fs.assert "#{tmpdir}/cache_dir/a_file"

    they 'detect file already present', ({ssh}) ->
      ssh = null
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file
          content: 'Where is my precious?'
          target: "#{tmpdir}/a_file"
        await @file.download
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
        await @file.download
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
        .should.be.finally.containEql $status: false
        await @file
          content: 'abc'
          target: "#{tmpdir}/download_test"
        await @file.download
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
        .should.be.finally.containEql $status: true
  
  describe 'md5', ->

    they 'cache dir with valid md5', ({ssh}) ->
      # Download a non existing file
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file
          target: "#{tmpdir}/a_file"
          content: 'Where is my precious?'
        await @file.download
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
          md5: '2317728a5e7fbd40c1acbe01378f0230'
        .should.be.finally.containEql $status: true
        await @fs.assert
          target: "#{tmpdir}/cache_dir/a_file"
          content: /precious/
        await @fs.assert
          target: "#{tmpdir}/download_test"
          content: /precious/

    they 'cache dir with invalid md5', ({ssh}) ->
      # Download a non existing file
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file
          target: "#{tmpdir}/a_file"
          content: 'Where is my precious?'
        await @file.download
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
          md5: 'XXXXX'
        .should.be.rejectedWith [
          'NIKITA_FILE_INVALID_TARGET_HASH:'
          "target \"#{tmpdir}/cache_dir/a_file\""
          'got "2317728a5e7fbd40c1acbe01378f0230" instead of "XXXXX".'
        ].join ' '

    they 'is computed if true', ({ssh}) ->
      # Download with invalid checksum
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @log.fs
          basedir: tmpdir
          serializer: text: (log) -> "[#{log.level}] #{log.message}\n"
        await @file
          target: "#{tmpdir}/source"
          content: "okay"
        await @file.download
          source: "#{tmpdir}/source"
          target: "#{tmpdir}/check_md5"
          md5: true
        .should.be.finally.containEql $status: true
        await @file.download
          source: "#{tmpdir}/source"
          target: "#{tmpdir}/check_md5"
          md5: true
        .should.be.finally.containEql $status: false
        {data} = await @fs.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'utf8'
        data.should.containEql "[WARN] Hash dont match, source is \"df8fede7ff71608e24a5576326e41c75\" and target is \"undefined\"."
        data.should.containEql "[INFO] Hash matches as \"df8fede7ff71608e24a5576326e41c75\"."

  describe 'error', ->

    they 'path must be absolute over ssh', ({ssh}) ->
      return unless ssh
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file.touch
          target: "#{tmpdir}/a_file"
        await @file.download
          source: "#{tmpdir}/a_file"
          target: "a_dir/download_test"
        .should.be.rejectedWith message: 'Non Absolute Path: target is "a_dir/download_test", SSH requires absolute paths, you must provide an absolute path in the target or the cwd option'
