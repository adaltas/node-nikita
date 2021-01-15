
path = require 'path'
os = require 'os'
fs = require 'ssh2-fs'
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.api

describe 'plugins.metadata.tmpdir', ->
  
  describe 'validation', ->

    they 'invalid value', ({ssh}) ->
      nikita.call ssh: ssh, metadata: tmpdir: {}, (->)
      .should.be.rejectedWith
        code: 'METADATA_TMPDIR_INVALID'
        message: [
          'METADATA_TMPDIR_INVALID:'
          'the "tmpdir" metadata value must be a boolean or a string,'
          "got {}"
        ].join ' '
  
  describe 'cascade', ->

    they 'current action', ({ssh}) ->
      nikita
        ssh: ssh
      , ({ssh}) ->
        tmpdir = await @call
          metadata: tmpdir: true
        , ({metadata}) ->
          await fs.exists ssh, metadata.tmpdir
          .should.be.resolvedWith true
          metadata.tmpdir
        fs.exists ssh, tmpdir
        .should.be.resolvedWith false

    they 'in children', ({ssh}) ->
      nikita.call ssh: ssh, metadata: tmpdir: true, ({metadata, ssh})->
        parent = metadata.tmpdir
        @call -> @call ({tools}) ->
          child = await tools.find (action) ->
            action.metadata.tmpdir
          child.should.eql parent
  
  describe 'option tmpdir', ->

    they 'is a boolean', ({ssh}) ->
      nikita
        ssh: ssh
      .call metadata: tmpdir: true, ({metadata}) ->
        metadata.tmpdir
      .then (tmpdir) ->
        path.parse(tmpdir).name.should.match /^nikita-\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/

    they 'is a string', ({ssh}) ->
      nikita
        ssh: ssh
      .call metadata: tmpdir: './a_dir', ({metadata}) ->
        metadata.tmpdir
      .then (tmpdir) ->
        tmpdir.should.eql unless !!ssh
        then path.resolve os.tmpdir(), './a_dir'
        else path.posix.resolve '/tmp', './a_dir'

  describe 'option dirty', ->

    they 'is true', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @call metadata: tmpdir: true, dirty: true, (->)
        @fs.base.exists '{{siblings.0.metadata.tmpdir}}'
        .should.resolvedWith exists: true
        @fs.base.rmdir '{{siblings.0.metadata.tmpdir}}'

    they 'is false', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @call metadata: tmpdir: true, dirty: false, (->)
        @fs.base.exists '{{siblings.0.metadata.tmpdir}}'
        .should.finally.match exists: false
