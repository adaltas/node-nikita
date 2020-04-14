
fs = require 'ssh2-fs'
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.api

describe 'metadata "tmpdir"', ->

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
