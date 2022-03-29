
path = require 'path'
os = require 'os'
fs = require 'ssh2-fs'
{tags, config} = require '../../test'
nikita = require '../../../src'
they = require('mocha-they')(config)

describe 'plugins.metadata.tmpdir', ->
  return unless tags.sudo

  they 'root ownership', ({ssh}) ->
    nikita
      $ssh: ssh
      $sudo: true
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {stats} = await @fs.base.stat tmpdir
      stats.should.match
        mode: 0o40744
        uid: 0
        gid: 0
  
