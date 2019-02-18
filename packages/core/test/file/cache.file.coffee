
http = require 'http'
path = require 'path'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.cache file', ->

  they 'current cache file match provided hash', ({ssh}) ->
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) ->
      logs.push log.message
    .file
      target: "#{scratch}/my_file"
      content: 'okay'
    .file
      target: "#{scratch}/my_cache_file"
      content: 'okay'
    .file.cache
      source: "#{scratch}/my_file"
      cache_file: "#{scratch}/my_cache_file"
      md5: 'df8fede7ff71608e24a5576326e41c75'
    , (err, {status}) ->
      status.should.be.false() unless err
      ('Hashes match, skipping' in logs).should.be.true() unless err
    .promise()

  they 'current cache file dont match provided hash', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/my_file"
      content: 'okay'
    .file
      target: "#{scratch}/my_cache_file"
      content: 'not okay'
    .file.cache
      source: "#{scratch}/my_file"
      cache_file: "#{scratch}/my_cache_file"
      md5: 'df8fede7ff71608e24a5576326e41c75'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'target file must match the hash', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/my_file"
      content: 'okay'
    .file.cache
      source: "#{scratch}/my_file"
      cache_dir: "#{scratch}/cache"
      md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      relax: true
    , (err) ->
      err.message.should.eql "Invalid Target Hash: target \"#{scratch}/cache/my_file\" got df8fede7ff71608e24a5576326e41c75 instead of xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    .promise()

  they 'into local cache_dir', ({ssh}) ->
    nikita
      ssh: ssh
    .file.cache
      source: "#{__filename}"
      cache_dir: "#{scratch}/my_cache_dir"
    , (err, {status, target}) ->
      status.should.be.true() unless err
      target.should.eql "#{scratch}/my_cache_dir/#{path.basename __filename}"
    .file.cache
      source: "#{__filename}"
      cache_dir: "#{scratch}/my_cache_dir"
    , (err, {status, target}) ->
      status.should.be.false() unless err
      target.should.eql "#{scratch}/my_cache_dir/#{path.basename __filename}"
    .file.assert
      target: "#{scratch}/my_cache_dir/#{path.basename __filename}"
    .promise()

  describe 'md5', ->

    they 'bypass cache if string match', ({ssh}) ->
      logs = []
      nikita
        ssh: ssh
      .on 'text', (log) -> logs.push "[#{log.level}] #{log.message}"
      .file
        target: "#{scratch}/source"
        content: "okay"
      .file
        target: "#{scratch}/target"
        content: "okay"
      # In file mode, md5 value will be calculated from source
      .file.cache
        source: "#{scratch}/source"
        cache_file: "#{scratch}/target"
        md5: true
      , (err, {status}) ->
        status.should.be.false() unless err
        ('[DEBUG] Hashes match, skipping' in logs).should.be.true() unless err
        logs = []
      .file.cache
        source: "#{scratch}/source"
        cache_file: "#{scratch}/target"
        md5: 'df8fede7ff71608e24a5576326e41c75'
      , (err, {status}) ->
        status.should.be.false() unless err
        ('[DEBUG] Hashes match, skipping' in logs).should.be.true() unless err
        logs = []
      .file.cache
        source: "#{scratch}/source"
        cache_file: "#{scratch}/target"
        md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        relax: true
      , (err) ->
        err.message.should.eql "Invalid Target Hash: target \"#{scratch}/target\" got df8fede7ff71608e24a5576326e41c75 instead of xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      .promise()
