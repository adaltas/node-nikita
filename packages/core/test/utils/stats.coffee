
import stats from '@nikitajs/core/utils/stats'
import test from '../test.coffee'

describe 'utils.stats', ->
  return unless test.tags.api

  describe 'type', ->

    it 'directory is true', ->
      mode = parseInt '40755', 8
      stats.isDirectory(mode).should.be.true()

    it 'directory is false', ->
      mode = parseInt '100644', 8
      stats.isDirectory(mode).should.be.false()
      
  describe 'type', ->

    it 'file is true', ->
      mode = parseInt '100644', 8
      stats.isFile(mode).should.be.true()

    it 'file is false', ->
      mode = parseInt '40755', 8
      stats.isFile(mode).should.be.false()
      
  describe 'type', ->

    it 'file is false', ->
      stats.type(parseInt('40755', 8)).should.eql 'Directory'
      stats.type(parseInt('100644', 8)).should.eql 'File'
