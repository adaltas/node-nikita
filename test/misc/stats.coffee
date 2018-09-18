
nikita = require '../../src'
misc = require '../../src/misc'
{tags} = require '../test'

return unless tags.api

describe 'misc.stats', ->

  it 'directory is true', ->
    mode = parseInt '40755', 8
    misc.stats.isDirectory(mode).should.be.true()

  it 'directory is false', ->
    mode = parseInt '100644', 8
    misc.stats.isDirectory(mode).should.be.false()

  it 'file is true', ->
    mode = parseInt '100644', 8
    misc.stats.isFile(mode).should.be.true()

  it 'file is false', ->
    mode = parseInt '40755', 8
    misc.stats.isFile(mode).should.be.false()
