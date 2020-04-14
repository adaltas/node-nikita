
fs = require 'ssh2-fs'
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.api

describe 'metadata "tmpdir"', ->

  they 'current action', ({ssh}) ->
    # TODO: inject SSH in nikita
    tmpdir = await nikita.call tmpdir: true, ({metadata})->
      await fs.exists ssh, metadata.tmpdir
      .should.be.resolvedWith true
      metadata.tmpdir
    fs.exists ssh, tmpdir
    .should.be.resolvedWith false

  they 'in children', ({ssh}) ->
    # TODO: inject SSH in nikita
    nikita.call tmpdir: true, ({metadata})->
      parent = metadata.tmpdir
      @call -> @call ({operations}) ->
        child = await operations.find (action) ->
          action.metadata.tmpdir
        child.should.eql parent
