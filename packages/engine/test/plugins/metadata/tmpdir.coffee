
path = require 'path'
os = require 'os'
fs = require 'ssh2-fs'
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.api

describe 'plugins.metadata.tmpdir', ->
  
  describe 'cascade', ->

    they 'current action', ({ssh}) ->
      tmpdir = await nikita.call ssh: ssh, tmpdir: true, ({metadata, ssh})->
        await fs.exists ssh, metadata.tmpdir
        .should.be.resolvedWith true
        metadata.tmpdir
      fs.exists ssh, tmpdir
      .should.be.resolvedWith false

    they 'in children', ({ssh}) ->
      nikita.call ssh: ssh, tmpdir: true, ({metadata, ssh})->
        parent = metadata.tmpdir
        @call -> @call ({operations}) ->
          child = await operations.find (action) ->
            action.metadata.tmpdir
          child.should.eql parent
  
  describe 'option tmpdir', ->

    they 'is a boolean', ({ssh}) ->
      nikita
        ssh: ssh
      .call tmpdir: true, ({metadata}) ->
        metadata.tmpdir
      .then (tmpdir) ->
        path.parse(tmpdir).name.should.match /^nikita_\d{6}_\d+_[\w\d]+$/

    they 'is a string', ({ssh}) ->
      nikita
        ssh: ssh
      .call tmpdir: './a_dir', ({metadata}) ->
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
        @call tmpdir: true, dirty: true, (->)
        @fs.base.exists '{{siblings.0.metadata.tmpdir}}'
        .should.resolvedWith true
        @fs.base.rmdir '{{siblings.0.metadata.tmpdir}}'

    they 'is true', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @call tmpdir: true, dirty: false, (->)
        @fs.base.exists '{{siblings.0.metadata.tmpdir}}'
        .should.resolvedWith false
